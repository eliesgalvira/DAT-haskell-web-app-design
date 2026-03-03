--   Tractament d'errors (amb el monad 'Either String').

module Instr3 where
import Ops

import Data.Foldable
    -- exporta
    --  'foldlM :: (Foldable t, Monad m) => (b -> a -> m b) -> b -> t a -> m b'

type IProgram = [Instr]

data Instr = IConst Int
           | IUnOp UnOp
           | IBinOp BinOp
    deriving Show

runIProgram :: IProgram -> Either String Int
runIProgram is =
    do
        xs <- runInstrs is []
        runTop xs

type Stack = [Int]

runTop :: Stack -> Either String Int
runTop [x] = Right x
runTop _ = Left "La pila no conté exactament un valor"

runInstrs :: IProgram -> Stack -> Either String Stack
runInstrs is xs =
    foldlM (flip runInstr1) xs is

runInstr1 :: Instr -> Stack -> Either String Stack
runInstr1 (IConst x) xs =
    Right $ x : xs
runInstr1 (IUnOp op) (x1 : xs) =
    Right $ doUnOp op x1 : xs
runInstr1 (IBinOp op) (x2 : x1 : xs) =
    Right $ doBinOp op x1 x2 : xs
runInstr1 _ _ =
    Left "No hi ha prou elements a la pila"
