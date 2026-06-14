
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TemplateHaskell #-}

module Forums.Found
where
import           Forums.Config
import           Forums.Model
import           SessionBackend

import           Develop.DatFw
import           Develop.DatFw.Handler
import           Develop.DatFw.Widget

import           Network.Wai.Middleware.Approot(getApproot)

import           Data.Monoid
import           Data.Text (Text)
import qualified Data.Text.Encoding as T
import           Data.ByteString.Builder
import           Data.Int
import           Data.Time
import           Control.Monad.IO.Class   -- imports liftIO
import           Control.Monad.Trans.Maybe

-- ---------------------------------------------------------------
-- Definició dels tipus del site ForumsApp i de les corresponents rutes.

data ForumsApp =
    ForumsApp
        { forumsDb :: Connection }

data ApiR =
          ForumsR
        | ForumR ForumId | ForumTopicsR ForumId
        | TopicR TopicId | TopicPostsR TopicId
        | PostR PostId
        | UserR
        | MarkdownR

parseApiRoute :: ([Text], [(Text, Text)]) -> Maybe ApiR
parseApiRoute (["forums"], _) = Just ForumsR
parseApiRoute (["forums", fid], _) = ForumR <$> fromPathPiece fid
parseApiRoute (["forums", fid, "topics"], _) = ForumTopicsR <$> fromPathPiece fid
parseApiRoute (["topics", tid], _) = TopicR <$> fromPathPiece tid
parseApiRoute (["topics", tid, "posts"], _) = TopicPostsR <$> fromPathPiece tid
parseApiRoute (["posts", pid], _) = PostR <$> fromPathPiece pid
parseApiRoute (["user"], _) = Just UserR
parseApiRoute (["markdown"], _) = Just MarkdownR
parseApiRoute _ = Nothing

renderApiRoute :: ApiR -> ([Text], [(Text, Text)])
renderApiRoute ForumsR            = (["forums"], [])
renderApiRoute (ForumR fid)       = (["forums",toPathPiece fid], [])
renderApiRoute (ForumTopicsR fid) = (["forums",toPathPiece fid,"topics"], [])
renderApiRoute (TopicR tid)       = (["topics",toPathPiece tid], [])
renderApiRoute (TopicPostsR tid)  = (["topics",toPathPiece tid,"posts"], [])
renderApiRoute (PostR pid )       = (["posts",toPathPiece pid], [])
renderApiRoute UserR              = (["user"], [])
renderApiRoute MarkdownR          = (["markdown"], [])

instance HasRoute ForumsApp where
    data Route ForumsApp =
        -- API
        ApiR ApiR
        -- Authentication UI
        | LoginR | LogoutR | ChangePassR
        -- External resources
        | StaticR [Text] [(Text,Text)]

    -- RESTful API:
    parseRoute ("api" : apipath, qs) = ApiR <$> parseApiRoute (apipath, qs)
    -- Authentication interface:
    parseRoute (["login"], _) = Just LoginR
    parseRoute (["logout"], _) = Just LogoutR
    parseRoute (["changepass"], _) = Just ChangePassR
    -- Other:
    parseRoute ("static" : ss, qs) = Just $ StaticR ss qs
    parseRoute (_, _) = Nothing

    renderRoute (ApiR apir) =
        let (path, qs) = renderApiRoute apir
        in ("api":path, qs)
    renderRoute LoginR  = (["login"], [])
    renderRoute LogoutR = (["logout"], [])
    renderRoute ChangePassR = (["changepass"], [])
    renderRoute (StaticR ss qs) = ("static":ss, qs)

-- Nota: Els tipus ForumId, TopicId i PostId són alias de 'Key ...' (veieu el model)
instance PathPiece (Key a) where
    toPathPiece (Key k) = showToPathPiece k
    fromPathPiece p = Key <$> readFromPathPiece p

-- ---------------------------------------------------------------
-- Instancia de WebApp (configuracio del lloc) per a ForumsApp.

instance WebApp ForumsApp where
    appRoot _ req = T.decodeUtf8 $ getApproot req
    {--
    urlRenderOverride site r@(StaticR _ _) ps =
        let (segs, qs) = renderRoute r
        in Just $ joinPath site "http://soft0.upc.edu/~WEBprofe/practica4" segs (qs <> ps)
    urlRenderOverride _ _ _ = Nothing
    --}
    makeSessionBackend _ = Just <$> mkSessionBackend

-- ---------------------------------------------------------------
-- Utility: Run a database action inside a handler

runDbAction :: (MonadHandler m, HandlerSite m ~ ForumsApp) => DbM a -> m a
runDbAction f = do
    conn <- getsSite forumsDb
    liftIO $ runDbTran conn f

-- ---------------------------------------------------------------
-- Sistema d'autenticacio.

-- Utilitats a ser usades des dels handlers

authId_SESSION_KEY :: Text
authId_SESSION_KEY = "__AUTHID"

maybeAuthId :: (MonadHandler m) => m (Maybe UserId)
maybeAuthId = do
    mbsid <- lookupSession authId_SESSION_KEY
    return $ mbsid >>= fromPathPiece

requireAuthId :: (MonadHandler m, ForumsApp ~ HandlerSite m) => m UserId
requireAuthId = do
    mbaid <- maybeAuthId
    maybe notAuthenticated pure mbaid

maybeAuth :: (MonadHandler m, HandlerSite m ~ ForumsApp) => m (Maybe (UserId, UserD))
maybeAuth = runMaybeT $ do
    aid <- MaybeT maybeAuthId
    ae <- MaybeT $ runDbAction $ getUser aid
    pure (aid, ae)

requireAuth :: (MonadHandler m, HandlerSite m ~ ForumsApp) => m (UserId, UserD)
requireAuth = do
    mbp <- maybeAuth
    maybe notAuthenticated pure mbp

