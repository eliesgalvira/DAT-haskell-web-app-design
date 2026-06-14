
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}

module Forums.View
where
import           Forums.Config
import           Forums.Found
import           Forums.Model

import           Develop.DatFw
import           Develop.DatFw.Widget
import           Develop.DatFw.Template
import           Develop.DatFw.Content

import           Control.Monad.IO.Class   -- imports liftIO
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import           Data.Time
import           Data.Semigroup
import           Text.Blaze
import           Language.Haskell.TH.Syntax

-- ---------------------------------------------------------------
-- Views
-- ---------------------------------------------------------------

loginView :: Widget ForumsApp -> Widget ForumsApp
loginView formw =
    $(widgetTemplFile $ templatesDir <> "/login.html")

changePassView :: Widget ForumsApp -> Widget ForumsApp
changePassView cformw = do
    $(widgetTemplFile $ templatesDir <> "/change-pass.html")


-- ---------------------------------------------------------------
-- Application Page Layout

appLayout :: Widget ForumsApp -> HandlerFor ForumsApp Html
appLayout widget = do
    mbmsg <- getMessage
    mbuser <- fmap (fmap snd) maybeAuth
    page <- widgetToPageContent $(widgetTemplFile $ templatesDir <> "/default-layout.html")
    applyUrlRenderTo $(htmlTemplFile $ templatesDir <> "/default-layout-wrapper.html")

