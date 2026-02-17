
module Instr1 where
import Ops

type IProgram = [Instr]

data Instr = IConst Int
           | IBinOp BinOp
           | IUnOp UnOp
    deriving Show

runIProgram :: [Instr] -> Int
runIProgram is =
    let xs = runInstrs is []
    in runTop xs

type Stack = [Int]

runTop :: Stack -> Int
runTop (x : _) = x

runInstrs :: [Instr] -> Stack -> Stack
runInstrs is xs =
    foldl (flip runInstr1) xs is

runInstr1 :: Instr -> Stack -> Stack
runInstr1 (IConst x) xs =
    x : xs
runInstr1 (IBinOp op) (x2 : x1 : xs) =
    doBinOp op x1 x2 : xs
runInstr1 (IUnOp op) (x1 : xs) =
    doUnOp op x1 : xs

