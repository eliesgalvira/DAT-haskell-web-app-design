
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE StandaloneDeriving #-}

module Main
where
import qualified Pages.Forum as PForum
import qualified Pages.Topic as PTopic
import qualified Pages.NotFound as PNotFound
import qualified Components.UserComponent as User
import           Route
import           Utils

import           Data.Void
import           Miso
import qualified Miso.CSS as CSS
import           Miso.Html
import           Miso.Router (parseURI, route)


-- | Main entry point
main :: IO ()
main = do
    uri <- getURI
    startApp defaultEvents $ app uri

app :: URI -> App Model Action
app uri =
  let model = init_ uri
  in (component model update_ view_)
        { subs = [ uriSub SetURI ]
        }

-- | Model
data Model = Model
  { mShared :: ()
  , mRoute :: Either URI Route
  } deriving (Eq)

init_ :: URI -> Model
init_ uri =
  Model () (routing uri)

-- | Routing
routing :: URI -> Either URI Route
routing uri =
  case route uri of
      Right r -> Right r
      Left _ -> Left uri

-- | View function
view_ :: Model -> View Model Action
view_ model =
  case mRoute model of
    Left uri -> absurd <$> PNotFound.view_ uri
    Right r -> 
      div_ [ CSS.style_
             [ CSS.margin "50px"
             ]
           ]
        [ mount_ (User.mkComp r)
        , hr_ []
        , case r of
            ForumR -> "forum-view" +> PForum.mkComp
            TopicR url -> "topic-view" +> PTopic.mkComp url
        ]


-- | Action
data Action
    = SetURI URI

-- | Update your model
update_ :: Action -> Effect parent Model Action
update_ (SetURI uri) =
    modify $ \m -> m{ mRoute = routing uri }

