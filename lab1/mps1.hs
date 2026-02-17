--   Us de la funcio 'fmap' que mapeja una funcio a un contenidor
--     o 'Functor'. Les funcions 'fmap' o '(<$>)' son mes generals
--     que la funcio 'map' i no nomes s'apliquen a llistes.

module Main where
import Instr1
import Ops

import System.Environment (getArgs)

main :: IO ()
main = do
    [filename] <- getArgs
    mainWith filename

mainWith :: String -> IO ()
mainWith filename = do
    input <- readFile filename
    let is = parseLine input
        r = runIProgram is
    putStrLn $ show r

parseLine :: String -> [Instr]
parseLine s = fmap parseWord $ words s
    where
        parseWord :: String -> Instr
        parseWord "Add" = IBinOp Add
        parseWord "Sub" = IBinOp Sub
        parseWord "Mul" = IBinOp Mul
        parseWord "Div" = IBinOp Div
        parseWord "Mod" = IBinOp Mod
        parseWord "Neg" = IUnOp Neg
        parseWord w     = IConst $ read w

