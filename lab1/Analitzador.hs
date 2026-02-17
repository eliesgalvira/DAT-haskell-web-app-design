
module Analitzador
where
import Control.Applicative
import Data.Char


newtype Analitzador a =
    Analitzador { execAnalitzador :: String -> Maybe (a, String) }

complirA :: (Char -> Bool) -> Analitzador Char
complirA predicat = Analitzador f
  where
    f [] = Nothing    -- falla si l'entrada es buida
    f (x:xs) =        -- Comprova si x compleix el predicat
        if predicat x then Just (x, xs) -- si es que si
                                   -- retorna x i la resta de 
                                   -- l'entrada (es a dir, xs)
                      else Nothing  -- altrament, falla

caracterA :: Char -> Analitzador Char
caracterA c = complirA (== c)

enterPosA :: Analitzador Int
enterPosA = Analitzador f
  where
    f xs = if null digits then Nothing
           else Just (read digits, elQueQueda)
      where (digits, elQueQueda) = span isDigit xs

fiTextA :: Analitzador ()
fiTextA = Analitzador f
  where
    f [] = pure ((), [])
    f _  = Nothing

instance Functor Analitzador where
    -- A completar per l'estudiant
    -- fmap :: (a -> b) -> Analitzador a -> Analitzador b

instance Applicative Analitzador where
    -- A completar per l'estudiant
    -- pure :: a -> Analitzador a
    -- (<*>) :: Analitzador (a -> b) -> Analitzador a -> Analitzador b
    (<*>) = error "(<*>): A completar per l'estudiant"

instance Alternative Analitzador where
    -- A completar per l'estudiant
    -- empty :: Analitzador a
    -- (<|>) :: Analitzador a -> Analitzador a -> Analitzador a

cadenaA :: String -> Analitzador String
cadenaA = error "cadenaA: A completar per l'estudiant"

