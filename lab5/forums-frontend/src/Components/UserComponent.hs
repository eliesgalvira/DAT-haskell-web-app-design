
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Components.UserComponent
    ( mkComp )
where
import           ForumsApiSrv
import           Route
import           Utils

import           Miso
import           Miso.Html
import           Miso.Html.Property
import           Miso.Router hiding (href_)
import           Miso.String


mkComp :: Route -> Component parent Model Action
mkComp route =
    (component init_ update_ (view_ route))
        { mount = Just $ FetchUser route
        }

-- Model
data Model
  = Model
      { mUserName :: Maybe MisoString
      }
  deriving (Eq, Show)

init_ :: Model
init_ = Model{ mUserName = Nothing }


-- View
view_ :: Route -> Model -> View Model act
view_ route model =
    case mUserName model of
        Nothing -> div_ []
            [ span_ [ class_ "fas fa-user-check"] []
            , a_ [ href_ $ withRedirect loginUrl ] [ "Login" ]
            ]
        Just uname -> div_ []
            [ span_ [ class_ "fas fa-user-circle"] []
            , "Usuari: "
            , b_ [] [ text uname ]
            , br_ []
            , span_ [ class_ "fas fa-user-alt-slash" ] []
            , a_ [ href_ $ withRedirect logoutUrl ] [ "Logout" ]
            ]
    where
        withRedirect :: Url -> MisoString
        withRedirect = renderUrl . addUrlQueryParam "redirect_url" (fullPrettyRoute route)


-- Update

data Action
  = FetchUser Route
  | SetUser (Either MisoString User)

update_ :: Action -> Effect parent Model Action
update_ (FetchUser r) =
    getApi userUrl SetUser
update_ (SetUser apiInfo) =
    case apiInfo of
        Left err -> do
            modify $ \ m -> m { mUserName = Nothing }
            io_ $ consoleError err
        Right user ->
            modify $ \ m -> m { mUserName = uName user }

