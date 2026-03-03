
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
    fmap g mx = ICodeM $ \xs ->
        -- Un calcul d'ICodeM produeix dues coses: un valor i una pila nova.
        -- 'fmap' nomes transforma el valor produït; la pila resultant no es toca.
        let (x, xs') = runICodeM mx xs
        in (g x, xs')

instance Applicative ICodeM where
    -- pure :: a -> ICodeM a
    pure x = ICodeM $ \xs -> (x, xs)
    -- (<*>) :: ICodeM (a -> b) -> ICodeM a -> ICodeM b
    mf <*> mx = ICodeM $ \ xs ->
        let (f, xs') = runICodeM mf xs
            (x, xs'') = runICodeM mx xs'
        in (f x, xs'')

instance Monad ICodeM where
    -- (>>=) :: ICodeM a -> (a -> ICodeM b) -> ICodeM b
    mx >>= k = ICodeM $ \xs ->
        -- Primer executem el calcul inicial sobre la pila d'entrada.
        -- Despres, el calcul següent rep el valor obtingut i continua
        -- a partir de la pila actualitzada pel primer calcul.
        let (x, xs') = runICodeM mx xs
        in runICodeM (k x) xs'

runInstrs :: IProgram -> ICodeM ()
runInstrs is = mapM_ runInstr1 is

runInstr1 :: Instr -> ICodeM ()
runInstr1 (IConst x) =
    push x
runInstr1 (IUnOp op) = do
    x <- pop
    push $ doUnOp op x
runInstr1 (IBinOp op) = do
    -- La pila guarda l'ultim valor calculat al capdamunt.
    -- Per a una operacio binaria, el primer 'pop' dona l'operand dret
    -- i el segon 'pop' dona l'operand esquerre.
    x2 <- pop
    x1 <- pop
    push $ doBinOp op x1 x2

push :: Int -> ICodeM ()
push x = ICodeM $ \ xs -> ((), x : xs)

pop :: ICodeM Int
pop = ICodeM $ \ (x : xs) -> (x, xs)
