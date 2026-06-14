
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import Forums.App

import Network.Wai
import Network.Wai.Test
import Network.Wai.Middleware.Approot(envFallbackNamed, hardcoded,fromRequest)

import           Data.Monoid
import qualified Data.ByteString.Char8 as B8
import           Control.Monad.IO.Class
import           Control.Exception
import           System.Environment

-- ****************************************************************

main :: IO ()
main = do
    r <- try makeApp
    case r of
        Right app -> do
            -- CGI adapter
            mw <- appRootMiddleware --envFallbackNamed "SCRIPT_NAME"
            runSession test $ mw app
        Left exc -> do
            putStrLn "Exception on initialization (while excution of 'makeApp'): "
            putStrLn $ "    " ++ show (exc :: SomeException)

appRootMiddleware :: IO Middleware
appRootMiddleware = do
    return $ hardcoded $ B8.pack $ "http://soft0.upc.edu/~WEBprofe/practica4/forums-backend.cgi"
    ---return fromRequest

test :: Session ()
test = do
    let req = setPath defaultRequest "/api/forums"
    liftIO $ putStrLn $ show req
    resp <- request req
    liftIO $ putStrLn $ show resp

