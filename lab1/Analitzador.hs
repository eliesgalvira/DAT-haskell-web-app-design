
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
    fmap g (Analitzador p) =
        Analitzador $ \input ->
            (\(x, rest) -> (g x, rest)) <$> p input

instance Applicative Analitzador where
    pure x = Analitzador $ \input -> Just (x, input)
    Analitzador pf <*> Analitzador px =
        Analitzador $ \input -> do
            (f, rest) <- pf input
            (x, rest') <- px rest
            pure (f x, rest')

instance Alternative Analitzador where
    empty = Analitzador $ const Nothing
    Analitzador p1 <|> Analitzador p2 =
        Analitzador $ \input ->
            case p1 input of
                Just r -> Just r
                Nothing -> p2 input

cadenaA :: String -> Analitzador String
cadenaA [] = pure []
cadenaA (c : cs) = (:) <$> caracterA c <*> cadenaA cs
