--   Tractament d'errors (amb el monad 'Maybe').

module Main where
import Instr2
import Ops

import System.Environment (getArgs)
import Text.Read -- exporta 'readMaybe :: (Read a) => String -> Maybe a'

main :: IO ()
main = do
    [filename] <- getArgs
    mainWith filename

mainWith :: String -> IO ()
mainWith filename = do -- Monad IO
    input <- readFile filename
    let r_err = do -- Monad Maybe
            is <- parseLine input
            runIProgram is
    case r_err of
        Just r  -> putStrLn $ "Ok: " <> show r
        Nothing -> putStrLn "Error"

parseLine :: String -> Maybe [Instr]
parseLine s = traverseList parseWord $ words s
    where
        parseWord :: String -> Maybe Instr
        parseWord "Add" = pure $ IBinOp Add
        parseWord "Sub" = pure $ IBinOp Sub
        parseWord "Mul" = pure $ IBinOp Mul
        parseWord "Div" = pure $ IBinOp Div
        parseWord "Mod" = pure $ IBinOp Mod
        parseWord "Neg" = pure $ IUnOp Neg
        parseWord w     = IConst <$> readMaybe w

traverseList :: Applicative m => (a -> m b) -> [a] -> m [b]
traverseList ... =
    -- A completar per l'estudiant
    ...

