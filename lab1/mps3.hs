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
    case parseLine input >>= runIProgram of
        Right r  -> putStrLn $ "Ok: " <> show r
        Left err -> putStrLn $ "Error: " <> err

parseLine :: String -> Either String [Instr]
parseLine s =
    traverseList parseWord $ words s
  where
    parseWord :: String -> Either String Instr
    parseWord "Add" = pure $ IBinOp Add
    parseWord "Sub" = pure $ IBinOp Sub
    parseWord "Mul" = pure $ IBinOp Mul
    parseWord "Div" = pure $ IBinOp Div
    parseWord "Mod" = pure $ IBinOp Mod
    parseWord "Neg" = pure $ IUnOp Neg
    parseWord w =
        case readMaybe w of
            Just n -> pure $ IConst n
            Nothing -> Left $ "Unknown word: " <> w

traverseList :: Applicative f => (a -> f b) -> [a] -> f [b]
traverseList _ [] = pure []
traverseList f (x : xs) = (:) <$> f x <*> traverseList f xs
