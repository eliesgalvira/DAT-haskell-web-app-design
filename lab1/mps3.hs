--   Tractament d'errors (amb el monad 'Either String').

module Main where
import Instr3
import Ops

import System.Environment (getArgs)
import Text.Read

main :: IO ()
main = do
    [filename] <- getArgs
    mainWith filename

mainWith :: String -> IO ()
mainWith filename = do
    input <- readFile filename
    -- A completar per l'estudiant

parseLine :: String -> Either String [Instr]
parseLine s =
    -- A completar per l'estudiant

