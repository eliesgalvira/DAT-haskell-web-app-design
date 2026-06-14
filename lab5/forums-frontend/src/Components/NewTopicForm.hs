
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Components.NewTopicForm
    ( mkComp )
where
import           ForumsApiSrv
import           Utils
import           Utils.Markdown

import           Miso
import           Miso.Html
import           Miso.Html.Property
import           Miso.JSON
import           Miso.String


mkComp :: ToJSON msg => Maybe (NewTopic -> msg) -> Component parent Model (Action msg)
mkComp onSubmit =
    component init_ update_ (view_ onSubmit)

-- Model
data Model
  = Model
      { mTitle :: MisoString
      , mMessage :: MisoString
      }
  deriving (Eq, Show)

init_ :: Model
init_ = Model{ mTitle = "", mMessage = "" }


-- View
view_ :: Maybe (NewTopic -> msg) -> Model -> View Model (Action msg)
view_ onSubmit _model =
  div_ []
    [ input_ [ class_ "edit", name_ "title"
             , onInput InputSubject
             ]
    , input_ [ class_ "edit", name_ "message"
             , onInput InputMessage
             ]
    , button_ [ onClick $ Submit onSubmit ]
        [ "New topic" ]
    ]


-- Update
data Action msg
  = InputSubject MisoString
  | InputMessage MisoString
  | Submit (Maybe (NewTopic -> msg))

update_ :: ToJSON msg => Action msg -> Effect parent Model (Action msg)
update_ (InputSubject value) =
    modify $ \ m -> m { mTitle = value }
update_ (InputMessage value) =
    modify $ \ m -> m { mMessage = value }
update_ (Submit mb_onSubmit) = do
    m <- get
    let nt = NewTopic (mTitle m) (Markdown $ mMessage m)
    case mb_onSubmit of
        Just onSubmit -> do
            mailParent $ onSubmit nt
            put $ Model "" ""
        Nothing -> pure ()

