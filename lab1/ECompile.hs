
module ECompile
where
import ESyntax
import Instr3
import Ops

import Control.Applicative


compila :: Expr -> Either String IProgram
compila (ELit x) =
    pure [IConst x]

compila (EApp name args) = do
    (np, i) <- case getOp name of
        Just p -> pure p
        Nothing -> Left $ "Undefined operator: " <> name
    if np == length args then pure ()
                         else Left $ "Expected "<>show np<>" arguments"
    -- En una maquina de pila, primer hem de deixar tots els arguments
    -- a la pila i nomes despres executar l'operacio.
    -- Per aixo compilem recursivament cada argument, concatenem el codi
    -- generat i finalment afegim la instruccio de l'operador al final.
    instrs <- traverse compila args
    pure $ concat instrs <> [i]

-- 'getOp name' obté 'Nothing' si 'name' no és una de les operacions definides ("add", "sub", ...),
-- o obté 'Just (np, i)' si correspon a la instrucció 'i' amb 'np' arguments.
getOp :: String -> Maybe (Int, Instr)
getOp name =
    -- 'Maybe' amb '<|>' ens permet provar diverses taules de noms.
    -- Si el nom correspon a una operacio binaria retornem aritat 2;
    -- si no, intentem interpretar-lo com una operacio unaria.
    ((2,) . IBinOp <$> binOps name) <|> ((1,) . IUnOp <$> unOps name)

binOps :: String -> Maybe BinOp
binOps "add" = Just Add
binOps "sub" = Just Sub
binOps "mul" = Just Mul
binOps "div" = Just Div
binOps "mod" = Just Mod
binOps _     = Nothing

unOps :: String -> Maybe UnOp
unOps "neg" = Just Neg
unOps _     = Nothing
