
module ESyntax
where
import Analitzador

import Control.Applicative
import Data.Char


data Expr = ELit Int
          | EApp String [Expr]
    deriving Show

exprP :: Analitzador Expr
exprP =
    (EApp <$> ident <*> some atomP) <|> atomP

atomP :: Analitzador Expr
atomP =
    (ELit <$> numero) <|> parens exprP

--------------------------------------------------

-- Aquests parsers (numero, simbol i ident) eliminen l'espai en blanc
-- que pugui haver-hi despres del text analitzat.

numero :: Analitzador Int
numero = eliminaEspais enterPosA

simbol :: String -> Analitzador String
simbol = eliminaEspais . cadenaA

ident :: Analitzador String
ident =
    eliminaEspais $
        (:) <$> complirA isAlpha <*> many (complirA isAlphaNum)


parens :: Analitzador a -> Analitzador a
parens p = simbol "(" *> p <* simbol ")"


-- Aplica l'analitzador indicat i elimina l'espai en blanc
-- que pugui haver-hi despres del text analitzat.
eliminaEspais :: Analitzador a -> Analitzador a
eliminaEspais p = p <* espaisEnBlanc

-- Multiples espais o comentaris
espaisEnBlanc :: Analitzador ()
espaisEnBlanc =
    many (espais <|> comentari) *> pure ()
  where
    espais = some (complirA isSpace) *> pure ()

comentari :: Analitzador ()
comentari =
    cadenaA "--" *> many (complirA (/= '\n')) *> complirA (=='\n') *> pure ()
