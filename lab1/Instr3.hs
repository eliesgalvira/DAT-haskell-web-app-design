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
    error "runIProgram: A completar per l'estudiant"

type Stack = [Int]

{- A completar per l'estudiant:
    runTop :: Stack -> Either String Int
    runInstrs :: IProgram -> Stack -> Either String Stack
    runInstr1 :: Instr -> Stack -> Either String Stack
-}

