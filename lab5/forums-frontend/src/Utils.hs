
module Utils
    ( RsrcStatus(..), isLoaded, whenLoaded
    , module Utils.Url
    , alocal_
    )
where
import           Utils.Url

import           Control.Monad.RWS
import           Miso
import qualified Miso.Html as H
import qualified Miso.Html.Property as HP
import qualified Miso.Router as R

---------------------------------------------------

-- Status type for a backend's resource

data RsrcStatus a = Loading | Loaded a | Failed MisoString
    deriving (Eq, Show)

isLoaded :: RsrcStatus a -> Bool
isLoaded (Loaded _) = True
isLoaded _          = False

whenLoaded :: Monad m => RsrcStatus a -> (a -> m ()) -> m ()
whenLoaded (Loaded x) f = f x
whenLoaded _          _ = pure ()

---------------------------------------------------

alocal_ :: R.Router route => (route -> act) -> route -> [View m act] -> View m act
alocal_ actf route children =
  -- H.button_ [ H.onClick $ actf route ] children
  H.a_ [ HP.href_ $ R.prettyRoute route
       , H.onClickWithOptions preventDefault $ actf route
       ] children

