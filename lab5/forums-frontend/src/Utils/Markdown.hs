
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module Utils.Markdown
where
--import           Utils

--import qualified Commonmark as Md
import           Control.Monad.State
import qualified Data.Text as T
import           Miso
import           Miso.Html
import           Miso.JSON
import qualified Miso.From.Html as FH


newtype Markdown = Markdown { getMdText :: MisoString }
        deriving (Eq, Show)

instance FromJSON Markdown where
  parseJSON value = Markdown <$> parseJSON value

instance ToJSON Markdown where
  toJSON value = toJSON $ getMdText value


{--
markToHtml' :: Markdown -> Either MisoString (View m act)
markToHtml' (Markdown t) =
    case Md.commonmark "server" $ fromMisoString t of
        Left e -> Left $ ms $ show e
        --Right md -> Right $ parseHtml $ ms $ Md.renderHtml (md :: Md.Html ())
        Right md -> Right $ text $ ms $ show (md :: Md.Html ())

markToHtml :: Markdown -> View_ act
markToHtml md =
    case markToHtml' md of
        Left e -> text $ ms "Error: " <> e
        Right v -> v
--}


parseHtml' :: MisoString -> Either MisoString [View m act]
parseHtml' input =
  case FH.parse (manyParser FH.html) (FH.getTokens $ fromMisoString input) of
    Right hs ->
      Right $ convertHtml <$> hs
    Left e ->
      Left $ ms $ show e
  where
    convertHtml (FH.TextNode x) = text $ ms x
    convertHtml (FH.Node isOpen t as cs) =
      nodeHtml (ms t) (convertAttrs as) (convertHtml <$> cs)
    convertAttrs as = convertAttr <$> as
    convertAttr (FH.HTMLAttr n (Just v)) =
      prop (ms n) (ms v)
    convertAttr (FH.HTMLAttr n Nothing) =
      prop (ms n) (""::MisoString)

parseHtml :: MisoString -> [View m act]
parseHtml md =
    case parseHtml' md of
        Left e -> [text $ "Error: " <> e]
        Right v -> v

-----------------------------------------------------------------------------

manyParser :: FH.Parser a -> FH.Parser [a]
manyParser p = StateT $ \tokens ->
  case runStateT p tokens of
    [] -> pure ([], tokens)
    rs -> do
      (x, ts') <- rs
      (xs, ts'') <- runStateT (manyParser p) ts'
      pure (x : xs, ts'')

