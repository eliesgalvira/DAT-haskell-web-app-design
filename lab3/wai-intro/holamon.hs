
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import           Network.Wai
import           Network.HTTP.Types (ok200, hContentType)
import           Network.Wai.Handler.Warp (runEnv)

import           Data.ByteString.Builder (stringUtf8)

-- ****************************************************************

main :: IO ()
main =
    -- runEnv :: Port -> Application -> IO ()
    runEnv 4050 app

-- ****************************************************************

app :: Application
app _req respond =
    respond $
        responseBuilder
            ok200
            [(hContentType, "text/plain;charset=utf-8")]
            (stringUtf8 "Hola Món")

