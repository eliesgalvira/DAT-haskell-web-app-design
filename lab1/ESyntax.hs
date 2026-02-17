
module ESyntax
where
import Analitzador

import Control.Applicative
import Data.Char


data Expr = ELit Int
          | EApp String [Expr]
    deriving Show

exprP :: Analitzador Expr
exprP = error "exprP: A completar per l'estudiant"

atomP :: Analitzador Expr
atomP = error "atomP: A completar per l'estudiant"

--------------------------------------------------

-- Aquests parsers (numero, simbol i ident) eliminen l'espai en blanc
-- que pugui haver-hi despres del text analitzat.

numero :: Analitzador Int
numero = error "numero: A completar per l'estudiant"
    -- usant eliminaEspais i enterPosA

simbol :: String -> Analitzador String
simbol = error "simbol: A completar per l'estudiant"
    -- usant eliminaEspais i cadenaA

ident :: Analitzador String
ident =
    eliminaEspais $
        (:) <$> complirA isAlpha <*> many (complirA isAlphaNum)


parens :: Analitzador a -> Analitzador a
parens p = error "parens: A completar per l'estudiant"


-- Aplica l'analitzador indicat i elimina l'espai en blanc
-- que pugui haver-hi despres del text analitzat.
eliminaEspais :: Analitzador a -> Analitzador a
eliminaEspais p = error "eliminaEspais: A completar per l'estudiant"

-- Multiples espais o comentaris
espaisEnBlanc :: Analitzador ()
espaisEnBlanc = error "espaisEnBlanc: A completar per l'estudiant"

comentari :: Analitzador ()
comentari =
    cadenaA "--" *> many (complirA (/= '\n')) *> complirA (=='\n') *> pure ()

