
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RankNTypes #-}

module Pages.NotFound
    ( view_ )
where
import           Utils

import           Data.Void
import           Miso hiding (page)
import           Miso.String
import           Miso.Html
import           Miso.Html.Property
import qualified Miso.CSS as CSS

-- | View function
view_ :: URI -> View model Void
view_ uri =
    div_ [ CSS.style_
             [ CSS.margin "100px"
             ]
         ]
      [ h1_ [class_ "title" ]
          [ "Not Found" ]
      , h2_ []
          [ text $ "Bad URI: " <> prettyURI uri ]
      ]

