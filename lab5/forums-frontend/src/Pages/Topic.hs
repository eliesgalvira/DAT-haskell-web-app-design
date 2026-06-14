
{-# LANGUAGE OverloadedStrings #-}

module Pages.Topic
    ( mkComp )
where
import           Utils

import           Miso hiding (Topic)

data Model = Model
        { -- A completar per l'estudiant
        }
    deriving Eq

data Action
        -- A completar per l'estudiant

mkComp :: Url -> Component parent Model Action
mkComp _ =
    component init_ update_ view_
    where
        init_ :: Model
        init_ =
            -- A completar per l'estudiant
            Model

        update_ :: Action -> Effect parent Model Action
        update_ _ =
            -- A completar per l'estudiant
            undefined

        view_ :: Model -> View Model Action
        view_ _ =
            -- A completar per l'estudiant
            text "Topic page: TODO"

