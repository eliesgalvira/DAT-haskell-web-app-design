--   Tractament d'errors (amb el monad 'Maybe').

module Instr2 where
import Ops

import Data.Foldable
    -- exporta
    --  'foldlM :: (Foldable t, Monad m) =>
    --             (b -> a -> m b) -> b -> t a -> m b'

type IProgram = [Instr]

data Instr = IConst Int
           | IUnOp UnOp
           | IBinOp BinOp
    deriving Show

runIProgram :: IProgram -> Maybe Int
runIProgram is = do -- Monad Maybe
    xs <- runInstrs is []
    runTop xs

type Stack = [Int]

runTop :: Stack -> Maybe Int
runTop [x] = Just x
runTop _   = Nothing

runInstrs :: IProgram -> Stack -> Maybe Stack
runInstrs is xs =
    foldlM (flip runInstr1) xs is

runInstr1 :: Instr -> Stack -> Maybe Stack
runInstr1 (IConst x) xs =
    Just $ x : xs
runInstr1 (IUnOp op) (x1 : xs) =
    Just $ doUnOp op x1 : xs
runInstr1 (IBinOp op) (x2 : x1 : xs) =
    Just $ doBinOp op x1 x2 : xs
runInstr1 _ _ =
    Nothing

