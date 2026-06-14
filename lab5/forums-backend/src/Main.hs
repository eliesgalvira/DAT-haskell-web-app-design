
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import Forums.App

import Network.Wai
import Network.Wai.Handler.Warp(run)
import Network.Wai.Middleware.Approot(envFallbackNamed, hardcoded,fromRequest)

import Control.Exception
import System.Environment

import Text.Read (readMaybe)

-- ****************************************************************

main :: IO ()
main = do
    args <- getArgs
    let mbport = case args of
            [arg1] -> readMaybe arg1
            _ -> Nothing
    -- La funcio 'makeApp' (definida en el modul 'Forums.App') construeix una aplicacio WAI
    -- a partir d'una aplicacio de tipus 'ForumsApp'
    app <- makeApp
    case mbport of
        Just port -> do
            putStrLn $ "HTTP port is " <> show port
            mw <- getApprootMiddleware
            -- Warp adapter
            run port $ mw app
        Nothing -> do
            prog <- getProgName
            putStrLn $ "Usage: " <> prog <> " PORT"

getApprootMiddleware :: IO Middleware
getApprootMiddleware =
    ---pure $ hardcoded $ B8.pack $ "http://soft0.upc.edu/~WEBprofe/practica4/forums-backend.cgi"
    ---envFallbackNamed "SCRIPT_NAME"
    pure fromRequest

