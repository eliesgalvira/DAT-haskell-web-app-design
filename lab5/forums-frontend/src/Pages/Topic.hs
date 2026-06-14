
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Pages.Topic
    ( mkComp )
where
import           Route
import           ForumsApiSrv
import           Utils
import           Utils.Markdown

import           Miso hiding (Topic)
import           Miso.Html
import           Miso.Html.Property
import           Miso.Router (toURI)
import           Miso.String

data Model = Model
        { mTopic :: RsrcStatus Topic
        , mPosts :: RsrcStatus [Post]
        , mMessage :: MisoString
        }
    deriving (Eq, Show)

data Action
        = FetchTopic
        | SetTopic (Either MisoString Topic)
        | SetPosts (Either MisoString [Post])
        | InputMessage MisoString
        | AddPost
        | PostsChanged (Either MisoString ())
        | DeletePost Url
        | ChangeRoute Route
        deriving (Show)

mkComp :: Url -> Component parent Model Action
mkComp topicUrl =
    (component init_ update_ view_)
        { mount = Just FetchTopic
        }
    where
        init_ :: Model
        init_ =
            Model Loading Loading ""

        update_ :: Action -> Effect parent Model Action
        update_ FetchTopic =
            getApi topicUrl SetTopic
        update_ (SetTopic apiInfo) =
            case apiInfo of
                Left err -> do
                    modify $ \ m -> m { mTopic = Failed err }
                    io_ $ consoleError err
                Right topic -> do
                    modify $ \ m -> m { mTopic = Loaded topic }
                    getApiArray (tPostsLink topic) SetPosts
        update_ (SetPosts apiInfo) =
            case apiInfo of
                Left err -> do
                    modify $ \ m -> m { mPosts = Failed err }
                    io_ $ consoleError err
                Right posts ->
                    modify $ \ m -> m { mPosts = Loaded posts }
        update_ (InputMessage value) =
            modify $ \ m -> m { mMessage = value }
        update_ AddPost = do
            Model{..} <- get
            case mTopic of
                Loaded topic ->
                    postApi (tPostsLink topic) (NewPost $ Markdown mMessage) PostsChanged
                _ ->
                    pure ()
        update_ (PostsChanged result) =
            case result of
                Left err ->
                    io_ $ consoleError err
                Right _ -> do
                    modify $ \ m -> m { mMessage = "" }
                    getApi topicUrl SetTopic
        update_ (DeletePost postUrl) =
            deleteApi postUrl PostsChanged
        update_ (ChangeRoute route) =
            io_ $ pushURI $ toURI route

        view_ :: Model -> View Model Action
        view_ Model{..} =
            div_ []
                [ viewRsrcStatus mTopic $ \ Topic{..} ->
                    div_ []
                        [ p_ [] [ alocal_ ChangeRoute ForumR [ "Torna al fòrum" ] ]
                        , h2_ [] [ text tTitle ]
                        , p_ [] [ text $ "Missatges: " <> ms tPostsCount ]
                        ]
                , h3_ [] [ "Missatges" ]
                , viewRsrcStatus mPosts $ \ posts ->
                    div_ [] (viewPost <$> posts)
                , h3_ [] [ "Nova resposta" ]
                , input_ [ class_ "edit"
                         , name_ "message"
                         , value_ mMessage
                         , onInput InputMessage
                         ]
                , button_ [ onClick AddPost ] [ "Reply" ]
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

viewPost :: Post -> View model Action
viewPost Post{..} =
    div_ [ class_ "border rounded p-3 mb-3" ]
        [ div_ [] (parseHtml pMessageHtml)
        , button_ [ onClick $ DeletePost pSelfLink ] [ "Delete" ]
        ]
