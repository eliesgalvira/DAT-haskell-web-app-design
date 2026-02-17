
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
    -- compila els arguments, obtenint les corresponents instruccions,
    -- i afegeix la instrucció 'i' al final
    error "compila: A completar per l'estudiant"

-- 'getOp name' obté 'Nothing' si 'name' no és una de les operacions definides ("add", "sub", ...),
-- o obté 'Just (np, i)' si correspon a la instrucció 'i' amb 'np' arguments.
getOp :: String -> Maybe (Int, Instr)
getOp name = error "getOp: A completar per l'estudiant"
    -- usant el fet que Maybe es instancia d'Alternative
    -- (useu binOps, unOps, fmap i (<|>))

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

