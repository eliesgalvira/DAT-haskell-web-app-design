
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DeriveGeneric #-}

module Pages.Forum
    ( mkComp )
where
import qualified Components.NewTopicForm as NewTopicForm
import           Route
import           ForumsApiSrv
import           Utils
import           Utils.Markdown

import           GHC.Generics
import           Miso hiding (Topic)
import           Miso.Html
import           Miso.Html.Property
import           Miso.JSON
import           Miso.Router (toURI)
import           Miso.String

mkComp :: Component parent Model Action
mkComp =
    (component init_ update_ view_)
        { mount = Just FetchForum
        , mailbox = receiveMail
        }

-- | Model
data Model
  = Model
      { mForum :: RsrcStatus Forum
      , mTopics :: RsrcStatus [Topic]
      }
  deriving (Eq, Show)

init_ :: Model
init_ =
    Model Loading Loading


-- | View function, with routing
view_ :: Model -> View Model Action
view_ Model {..} =
    div_ []
      [ h2_ []
          [ text $ "Fòrum (URL: " <> renderUrl forumUrl <> ")" ]
      , viewRsrcStatus mForum $ \ Forum{..} ->
          div_ []
            [ h3_ []
                [ text $ "Títol: " <> fTitle ]
            , h3_ []
                [ text $ "Descripció:" ]
            , div_[]
                (parseHtml fDescriptionHtml)
            ]
      , viewRsrcStatus mTopics $ \ topics ->
            table_ [ class_ "table is-striped" ]
              [ thead_ []
                  [ tr_ []
                      [ th_ [] [ "Títol" ]
                      , th_ [] [ "# missatges" ]
                      ]
                  ]
              , tbody_ [] $
                  viewTopicSummary <$> topics
              ]
      , hr_ []
      , mount_ (NewTopicForm.mkComp $ Just MNewTopic)
      ]

viewRsrcStatus :: RsrcStatus r -> (r -> View model Action) -> View model Action
viewRsrcStatus rs f =
  case rs of
    Loading ->
      div_ []
        [ "No data" ]
    Failed err ->
      div_ []
        [ text $ "Error: " <> err]
    Loaded r -> f r

viewTopicSummary :: Topic -> View model Action
viewTopicSummary t@Topic{..} =
  tr_ []
    [ td_ [] [ alocal_ ChangeRoute (TopicR tSelfLink) [ text tTitle ] ]
    , td_ [] [ text $ ms tPostsCount ]
    , td_ [] [ button_ [onClick $ DeleteTopic tSelfLink] [ "Delete" ] ]
    ]


-- | Action
data Action
  = FetchForum
  | SetForum (Either MisoString Forum)
  | SetForumTopics (Either MisoString [Topic])
  | AddTopic NewTopic
  | TopicsChanged (Either MisoString ())
  | DeleteTopic Url
  | ChangeRoute Route
  deriving (Show)

data Mail
  = MNewTopic NewTopic
  deriving (Show, Generic)
instance ToJSON Mail where
instance FromJSON Mail where

receiveMail :: Value -> Maybe Action
receiveMail value =
  case fromJSON value of
    Success (MNewTopic x) -> Just $ AddTopic x
    Error err -> Nothing

-- | Update your model
update_ :: Action -> Effect parent Model Action
update_ FetchForum =
    getApi forumUrl SetForum
update_ (SetForum apiInfo) =
    case apiInfo of
        Left err -> do
            modify $ \ m -> m { mForum = Failed err }
            io_ $ consoleError err
        Right forum -> do
            modify $ \ m -> m { mForum = Loaded forum }
            getApiArray (fTopicsLink forum) SetForumTopics
update_ (SetForumTopics apiInfo) =
    case apiInfo of
        Left err -> do
            modify $ \ m -> m { mTopics = Failed err }
            io_ $ consoleError err
        Right topics ->
            modify $ \ m -> m { mTopics = Loaded topics }

update_ (AddTopic newTopic) = do
    Model{..} <- get
    case mForum of
        Loaded forum -> postApi (fTopicsLink forum) newTopic TopicsChanged
        _ -> pure ()
update_ (TopicsChanged result) =
    case result of
        Left err ->
            io_ $ consoleError err
        Right _ -> do
            Model{..} <- get
            case mForum of
                Loaded forum ->
                    getApiArray (fTopicsLink forum) SetForumTopics
                _ -> pure ()

update_ (DeleteTopic tlink) = do
    Model{..} <- get
    case mForum of
        Loaded forum -> deleteApi tlink TopicsChanged
        _ -> pure ()

update_ (ChangeRoute route) =
    io_ $ pushURI $ toURI route

