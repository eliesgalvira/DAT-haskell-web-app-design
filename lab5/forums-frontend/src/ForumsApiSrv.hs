
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module ForumsApiSrv
where
import           Utils
import           Utils.Markdown

import           Control.Monad.RWS
import           Data.Int
import           GHC.Generics

import           Miso hiding (defaultOptions, Topic)
import qualified Miso.Fetch as X
import           Miso.JSON
import           Miso.String


backendUrl :: MisoString -> Url
backendUrl path = parseUrl $ site <> path
  where
    site = "http://localhost:5001"

loginUrl, logoutUrl :: Url
loginUrl = backendUrl "/login"
logoutUrl = backendUrl "/logout"

userUrl :: Url
userUrl = backendUrl "/api/user"

forumUrl :: Url
forumUrl = backendUrl "/api/forums/1"


newtype User = User
        { uName :: Maybe MisoString
        }
        deriving (Eq, Show, Generic)

instance FromJSON User where
    parseJSON = withObject "User" $ \v -> User
        <$> v .: "name"


data Forum = Forum
        { fSelfLink :: Url
        , fTitle :: MisoString
        , fDescription :: Markdown
        , fDescriptionHtml :: MisoString
        , fTopicsLink :: Url
        , fTopicsCount :: Int
        , fPostsCount :: Int
        }
        deriving (Eq, Show, Generic)

instance FromJSON Forum where
    parseJSON = withObject "Forum" $ \v -> Forum
        <$> v .: "selfLink"
        <*> v .: "title"
        <*> v .: "description"
        <*> v .: "descriptionHtml"
        <*> v .: "topicsLink"
        <*> v .: "topicsCount"
        <*> v .: "postsCount"


data Topic = Topic
        { tSelfLink :: Url
        , tForumLink :: Url
        , tTitle :: MisoString
        , tPostsLink :: Url
        , tPostsCount :: Int
        }
        deriving (Eq, Show)

instance FromJSON Topic where
    parseJSON = withObject "Topic" $ \v -> Topic
        <$> v .: "selfLink"
        <*> v .: "forumLink"
        <*> v .: "title"
        <*> v .: "postsLink"
        <*> v .: "postsCount"


data NewTopic = NewTopic
        { ntTitle :: MisoString
        , ntMessage :: Markdown
        }
        deriving (Eq, Show)

instance ToJSON NewTopic where
    toJSON NewTopic{..} = object [("title", toJSON ntTitle), ("message", toJSON ntMessage)]

instance FromJSON NewTopic where
    parseJSON = withObject "NewTopic" $ \obj ->
        NewTopic <$> obj .: "title" <*> obj .: "message"


data Post = Post
        { pSelfLink :: Url
        , pMessage :: Markdown
        , pMessageHtml :: MisoString
        }
        deriving (Eq, Show)

instance FromJSON Post where
    parseJSON = withObject "Post" $ \v -> Post
        <$> v .: "selfLink"
        <*> v .: "message"
        <*> v .: "messageHtml"


newtype NewPost = NewPost
        { npMessage :: Markdown
        }
        deriving (Eq, Show)

instance ToJSON NewPost where
    toJSON NewPost{..} = object [("message", toJSON npMessage)]

instance FromJSON NewPost where
    parseJSON = withObject "NewPost" $ \obj ->
        NewPost <$> obj .: "message"


getApi :: FromJSON a => Url -> (Either MisoString a -> action) -> Effect parent model action
getApi url act =
    X.getJSON (renderUrl url) [] successful errorful
    where
        successful resp = act $ Right $ body resp
        errorful resp = act $ Left $ body resp

newtype ListOf a = ListOf [a]
    deriving (Eq, Show, Read)

instance FromJSON a => FromJSON (ListOf a) where
    parseJSON = withObject "ListOf" $ \v -> ListOf
        <$> v .: "items"

getApiArray :: FromJSON a => Url -> (Either MisoString [a] -> action) -> Effect parent model action
getApiArray url act =
    let unwrap (ListOf items) = items
    in getApi url (act . fmap unwrap)

postApi :: ToJSON a => Url -> a -> (Either MisoString () -> action) -> Effect parent model action
postApi url param act =
    X.postJSON (renderUrl url) param [] successful errorful
    where
        successful resp = act $ Right $ body resp
        errorful resp = act $ Left $ body resp

postApi' :: (ToJSON a, FromJSON b) => Url -> a -> (Either MisoString b -> action) -> Effect parent model action
postApi' url param act =
    X.postJSON' (renderUrl url) param [] successful errorful
    where
        successful resp = act $ Right $ body resp
        errorful resp = act $ Left $ body resp

deleteApi :: Url -> (Either MisoString () -> action) -> Effect parent model action
deleteApi url act =
    withSink $ \sink ->
        X.fetch (renderUrl url) "DELETE" Nothing [] (successful sink) (errorful sink) NONE
    where
        successful sink resp = sink $ act $ Right $ body resp
        errorful sink resp = sink $ act $ Left $ body resp

