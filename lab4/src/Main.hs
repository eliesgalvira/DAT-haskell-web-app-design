
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import Forums.App

import Network.Wai
import Network.Wai.Handler.Warp(run)

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
            -- Warp adapter
            run port app
        Nothing -> do
            prog <- getProgName
            putStrLn $ "Usage: " <> prog <> " PORT"

