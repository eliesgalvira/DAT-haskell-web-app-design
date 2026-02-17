
module Ops where

data BinOp = Add | Sub | Mul | Div | Mod
           | Eq | Le
    deriving (Show, Read, Eq, Enum, Bounded)

data UnOp = Neg
          | Not
    deriving (Show, Read, Eq, Enum, Bounded)

doBinOp :: BinOp -> Int -> Int -> Int
doBinOp Add = (+)
doBinOp Sub = (-)
doBinOp Mul = (*)
doBinOp Div = div
doBinOp Mod = mod

doBinOp Eq = \x y -> if x == y then 1 else 0
doBinOp Le = \x y -> if x <= y then 1 else 0

doUnOp :: UnOp -> Int -> Int
doUnOp Neg = negate

doUnOp Not = \x -> if x == 0 then 1 else 0

