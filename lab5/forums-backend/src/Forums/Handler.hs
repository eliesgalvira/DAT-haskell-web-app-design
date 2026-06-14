
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RecordWildCards #-}

module Forums.Handler
where
import           Forums.Found
import           Forums.Config
import           Forums.Model

import           Develop.DatFw
import           Develop.DatFw.Handler
import           Develop.DatFw.Widget
import           Develop.DatFw.Content

import           Network.Wai

import qualified CMark as Md
import           Control.Monad            -- imports forM_, ...
import           Control.Monad.IO.Class   -- imports liftIO
import           Control.Monad.Reader
import           Data.Aeson hiding (Key)
import           Data.Aeson.Types (Parser, parseEither)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.IO as T
import           Data.Maybe               -- imports isJust, isNothing, catMaybes, ...
import           Data.Monoid
import           Data.Bool                -- imports bool
import           Data.Time
import           Text.Read (readMaybe)

-- ---------------------------------------------------------------
-- Conversion to JSON representation
-- ---------------------------------------------------------------

instance ToJSON (Key a) where
    toJSON (Key k) = toJSON k

instance ToJSON Markdown where
  toJSON (Markdown t) = toJSON t

instance FromJSON Markdown where
  parseJSON = fmap Markdown . parseJSON

forumToJSON :: (ForumId, ForumD) -> HandlerFor ForumsApp Value
forumToJSON (fid, ForumD{..}) = do
    ur <- (. ApiR) <$> getUrlRenderNoParams
    moderName <- maybe "???" udName <$> runDbAction (getUser fdModeratorId)
    mb_lastPost <- maybe (pure Nothing) (runDbAction . getPost) fdLastPostId
    lastPostFields <- case mb_lastPost of
        Nothing -> pure []
        Just lastPost -> do
            lastPostUserName <- maybe "???" udName <$> runDbAction (getUser $ pdUserId lastPost)
            pure [ ("lastPosted", toJSON $ pdPosted lastPost), ("lastPostUser", toJSON lastPostUserName)
                 , ("lastPostLink", toJSON $ (ur . PostR) <$> fdLastPostId)
                 ]
    pure $ object $ [ ("id", toJSON fid), ("selfLink", toJSON $ ur $ ForumR fid)
                    , ("moderator", toJSON moderName), ("category", toJSON fdCategory)
                    , ("title", toJSON fdTitle)
                    , ("description", toJSON fdDescription)
                    , ("descriptionHtml", toJSON $ markdownToHtmlText fdDescription)
                    , ("created", toJSON fdCreated)
                    , ("topicsLink", toJSON $ ur $ ForumTopicsR fid), ("topicsCount", toJSON fdTopicCount)
                    , ("postsCount", toJSON fdPostCount)
                    ] <> lastPostFields

topicToJSON :: (TopicId, TopicD) -> HandlerFor ForumsApp Value
topicToJSON (tid, TopicD{..}) = do
    ur <- (. ApiR) <$> getUrlRenderNoParams
    posts <- runDbAction $ getPostList tid
    userName <- maybe "???" udName <$> runDbAction (getUser tdUserId)
    mb_lastPost <- maybe (pure Nothing) (runDbAction . getPost) tdLastPostId
    lastPostFields <- case mb_lastPost of
        Nothing -> pure []
        Just lastPost -> do
            lastPostUserName <- maybe "???" udName <$> runDbAction (getUser $ pdUserId lastPost)
            pure [ ("firstPostLink", toJSON $ (ur . PostR) <$> tdFirstPostId)
                 , ("lastPosted", toJSON $ pdPosted lastPost), ("lastPostUser", toJSON lastPostUserName)
                 , ("lastPostLink", toJSON $ (ur . PostR) <$> tdLastPostId)
                 ]
    pure $ object $ [ ("id", toJSON tid), ("selfLink", toJSON $ ur $ TopicR tid)
                    , ("forumLink", toJSON $ ur $ ForumR tdForumId)
                    , ("user", toJSON userName), ("started", toJSON tdStarted)
                    , ("title", toJSON tdSubject)
                    , ("postsLink", toJSON $ ur $ TopicPostsR tid), ("postsCount", toJSON tdPostCount)
                    ] <> lastPostFields

postToJSON :: (PostId, PostD) -> HandlerFor ForumsApp Value
postToJSON (pid, PostD{..}) = do
    ur <- (. ApiR) <$> getUrlRenderNoParams
    userName <- maybe "???" udName <$> runDbAction (getUser pdUserId)
    pure $ object [ ("id", toJSON pid), ("selfLink", toJSON $ ur $ PostR pid)
                  , ("topicLink", toJSON $ ur $ TopicR pdTopicId)
                  , ("user", toJSON userName), ("posted", toJSON pdPosted)
                  , ("message", toJSON pdMessage)
                  , ("messageHtml", toJSON $ markdownToHtmlText pdMessage)
                  ]

-- ---------------------------------------------------------------
-- Parsing JSON request body
-- ---------------------------------------------------------------

getRequestJSON :: (Object -> Parser a) -> HandlerFor ForumsApp a
getRequestJSON fromObject = do
    jval <- getRequestJSON'
    case parseEither (withObject "Request body as an object" fromObject) jval of
        Left err -> invalidArgs [T.pack err]
        Right v -> pure v

getRequestJSON' :: HandlerFor ForumsApp Value
getRequestJSON' = do
    req <- getRequest
    cType <- maybe (invalidArgs ["Request with content expected"])
                   (pure . T.decodeUtf8)
                   (lookup "content-type" (requestHeaders req))
    let isJson = "application/json" == fst (T.break (';' ==) cType)
    when (not isJson) $
        invalidArgs ["Request with application/json content type expected"]
    lbytes <- liftIO $ strictRequestBody req
    case eitherDecode lbytes of
        Left err -> invalidArgs [T.pack err]
        Right v -> pure v


-- ---------------------------------------------------------------
-- Handlers
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- User

getUserR :: HandlerFor ForumsApp Value
getUserR = do
    -- Get model info
    mbuser <- maybeAuth
    let val = maybe Null (toJSON . udName . snd) mbuser
    pure $ object [ ("name", val) ]

-- ---------------------------------------------------------------
-- Forums list

getForumsR :: HandlerFor ForumsApp Value
getForumsR = do
    -- Get model info
    forums <- runDbAction getForumList
    jforums <- forM forums forumToJSON
    pure $ object [("items", toJSON jforums)]

postForumsR :: HandlerFor ForumsApp Value
postForumsR = do
    user <- requireAuth
    newforum <- getRequestJSON $ \ obj -> do
        title <- obj .: "title"
        description <- obj .: "description"
        pure $ NewForum { nfTitle = title
                        , nfDescription = description
                        }
    fid <- runDbAction $ addForum (fst user) newforum
    getForumR fid

-- ---------------------------------------------------------------
-- Forum

getForumR :: ForumId -> HandlerFor ForumsApp Value
getForumR fid = do
    -- Get model info
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    forumToJSON (fid, forum)

deleteForumR :: ForumId -> HandlerFor ForumsApp Value
deleteForumR fid = do
    uid <- requireAuthId
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    when (uid /= fdModeratorId forum) (permissionDenied "User is not the moderator of this forum")
    runDbAction $ deleteForum fid
    pure $ object []

-- ---------------------------------------------------------------
-- Topics list

optionsForumTopicsR :: ForumId -> HandlerFor ForumsApp ()
optionsForumTopicsR _ = do
    pure ()

getForumTopicsR :: ForumId -> HandlerFor ForumsApp Value
getForumTopicsR fid = do
    -- Get model info
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    topics <- runDbAction $ getTopicList fid
    jqs <- forM topics topicToJSON
    pure $ object [("items", toJSON jqs)]

postForumTopicsR :: ForumId -> HandlerFor ForumsApp Value
postForumTopicsR fid = do
    uid <- requireAuthId
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    newtopic <- getRequestJSON $ \ obj -> do
        title <- obj .: "title"
        message <- obj .: "message"
        pure $ NewTopic { ntSubject = title
                        , ntMessage = message
                        }
    (tid, _) <- runDbAction $ addTopic fid uid newtopic
    getTopicR tid

-- ---------------------------------------------------------------
-- Topic

getTopicR :: TopicId -> HandlerFor ForumsApp Value
getTopicR tid = do
    -- Get model info
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    topicToJSON (tid, topic)

deleteTopicR :: TopicId -> HandlerFor ForumsApp Value
deleteTopicR tid = do
    user <- requireAuthId
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    forum <- runDbAction (getForum $ tdForumId topic) >>= maybe notFound pure
    when (user /= fdModeratorId forum) (permissionDenied "User is not the moderator of this forum")
    runDbAction $ deleteTopic (tdForumId topic) tid
    pure $ object []

-- ---------------------------------------------------------------
-- Posts list

getTopicPostsR :: TopicId -> HandlerFor ForumsApp Value
getTopicPostsR tid = do
    -- Get model info
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    posts <- runDbAction $ getPostList tid
    jas <- forM posts postToJSON
    pure $ object [("items", toJSON jas)]

postTopicPostsR :: TopicId -> HandlerFor ForumsApp Value
postTopicPostsR tid = do
    uid <- requireAuthId
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    newpost <- getRequestJSON $ \ obj ->
        obj .: "message"
    pid <- runDbAction $ addReply (tdForumId topic) tid uid newpost
    getPostR pid

-- ---------------------------------------------------------------
-- Post

getPostR :: PostId -> HandlerFor ForumsApp Value
getPostR pid = do
    -- Get model info
    post <- runDbAction (getPost pid) >>= maybe notFound pure
    postToJSON (pid, post)

deletePostR :: PostId -> HandlerFor ForumsApp Value
deletePostR pid = do
    user <- requireAuthId
    post <- runDbAction (getPost pid) >>= maybe notFound pure
    topic <- runDbAction (getTopic $ pdTopicId post) >>= maybe notFound pure
    forum <- runDbAction (getForum $ tdForumId topic) >>= maybe notFound pure
    when (user /= fdModeratorId forum) (permissionDenied "User is not the moderator of this forum")
    runDbAction $ deletePost (tdForumId topic) (pdTopicId post) pid
    pure $ object []


-- ---------------------------------------------------------------
-- Controller handlers: Markdown conversion

postMarkdownR :: HandlerFor ForumsApp Value
postMarkdownR = do
    md <- getRequestJSON $ \ obj ->
        obj .: "markdown"
    let html = Md.commonmarkToHtml [Md.optSafe] $ getMdText md
    pure $ object [("html", toJSON html)]


-- ---------------------------------------------------------------
-- Controller handlers: Static files

getStaticR :: [Text] -> [(Text, Text)] -> HandlerFor ForumsApp TypedContent
getStaticR ss _ = do
    staticView ss

staticView :: [Text] -> HandlerFor ForumsApp TypedContent
staticView [file] = do
    let fp = templatesDir <> "/static/" <> T.unpack file
    css <- liftIO (T.readFile fp)
    pure $ TypedContent "text/css" (toContent css)
staticView _ =
    notFound

