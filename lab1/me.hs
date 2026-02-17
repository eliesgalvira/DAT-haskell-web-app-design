
import ESyntax
import Analitzador
import ECompile
import Instr3
import Ops

import System.Environment
import System.IO

main = do
    [filename] <- getArgs
    mainWith filename

mainWith :: String -> IO ()
mainWith filename = do
    input <- readFile filename
    analitza input

analitza :: String -> IO ()
analitza input = do
    let r = execAnalitzador (espaisEnBlanc *> exprP <* fiTextA) input
    case r of
        Nothing -> putStrLn "Syntax error"
        Just (e, _) -> do
            print e
            tradueix e

tradueix :: Expr -> IO ()
tradueix e = do
    case compila e of
        Left err -> putStrLn $ "Error: " <> err
        Right is -> do
            print is
            executa is

executa :: IProgram -> IO ()
executa is =
    case runIProgram is of
        Right r  -> putStrLn $ "Ok: " <> show r
        Left err -> putStrLn $ "Error: " <> err

