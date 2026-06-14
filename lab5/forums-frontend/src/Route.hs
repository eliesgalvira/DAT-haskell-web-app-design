
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}

module Route
where
import           ForumsApiSrv
import           Utils

import           Miso.Router
import           Miso.String
import           Network.HTTP.Types (urlEncode, urlDecode)

appOrigin :: MisoString
appOrigin = "http://localhost:8008"

data Route = ForumR | TopicR Url
  deriving (Eq, Show)

instance Router Route where
  routeParser = routes [ (path "index.html" *> pure ForumR)
                       , (TopicR . fromQP) <$> (path "topic.html" *> queryParam) ]
    where
        fromQP :: QueryParam "url" MisoString -> Url
        fromQP (QueryParam (Just x)) = parseUrl $ ms $ urlDecode True $ fromMisoString x
  fromRoute ForumR = [ toPath "index.html" ]
  fromRoute (TopicR url) = [ toPath "topic.html"
                           , toQueryParam "url" $ ms $ urlEncode True $ fromMisoString $ renderUrl url ]

fullPrettyRoute :: Route -> MisoString
fullPrettyRoute route = appOrigin <> prettyRoute route

