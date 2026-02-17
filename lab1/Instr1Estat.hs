
module Instr1Estat where
import Ops

type IProgram = [Instr]

data Instr = IConst Int
           | IUnOp UnOp
           | IBinOp BinOp
    deriving Show

runIProgram :: IProgram -> Int
runIProgram is =
    let (_, xs) = runICodeM (runInstrs is) []
    in runTop xs

type Stack = [Int]

runTop :: Stack -> Int
runTop (x : _) = x

newtype ICodeM a = ICodeM { runICodeM :: Stack -> (a, Stack) }

instance Functor ICodeM where
    -- fmap :: (a -> b) -> ICodeM a -> ICodeM b
    fmap g m = error "ICodeM.fmap: A completar per l'estudiant"

instance Applicative ICodeM where
    -- pure :: a -> ICodeM a
    pure x = error "ICodeM.pure: A completar per l'estudiant"
    -- (<*>) :: ICodeM (a -> b) -> ICodeM a -> ICodeM b
    mf <*> mx = ICodeM $ \ xs ->
        let (f, xs') = runICodeM mf xs
            (x, xs'') = runICodeM mx xs'
        in (f x, xs'')

instance Monad ICodeM where
    -- (>>=) :: ICodeM a -> (a -> ICodeM b) -> ICodeM b
    mx >>= k = error "ICodeM.>>=: A completar per l'estudiant"

runInstrs :: IProgram -> ICodeM ()
runInstrs is = mapM_ runInstr1 is

runInstr1 :: Instr -> ICodeM ()
runInstr1 = error "runInstr1: A completar per l'estudiant"
-- (usant push i pop)

push :: Int -> ICodeM ()
push x = ICodeM $ \ xs -> ((), x : xs)

pop :: ICodeM Int
pop = error "pop: A completar per l'estudiant"

