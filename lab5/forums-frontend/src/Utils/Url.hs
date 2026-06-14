
{-# LANGUAGE OverloadedStrings #-}

module Utils.Url
where
import           Data.Text.Encoding (encodeUtf8, decodeUtf8With)
import           Data.Text.Encoding.Error (lenientDecode)
import           Miso.JSON
import           Miso.String (MisoString, ms, fromMisoString)
import qualified Miso.String as MS
import           Network.HTTP.Types.URI


data Url = Url
    { urlOriginPath :: MisoString       -- URL encoded
    , urlQuery :: Maybe Query
    , urlFragment :: MisoString 
    }
    deriving (Eq, Show)

parseUrl :: MisoString -> Url
parseUrl t =
    let (t1, frag) = MS.break (== '#') t
        (base, qs) = MS.break (== '?') t1
        q = case MS.uncons qs of
            Just ('?', qs') ->
                Just $ parseQuery $ encodeUtf8 $ fromMisoString qs'
            Nothing -> Nothing
        
    in Url base q frag

addUrlQueryParam :: MisoString -> MisoString -> Url -> Url
addUrlQueryParam k v url =
    let p = (encodeUtf8 $ fromMisoString k, Just $ encodeUtf8 $ fromMisoString v)
        ps' = case urlQuery url of
            Nothing -> [p]
            Just ps -> ps <> [p]
    in url{ urlQuery = Just ps' }

addUrlFragment :: MisoString -> Url -> Url
addUrlFragment f url =
    url{ urlFragment = "#" <> f}

renderUrl :: Url -> MisoString
renderUrl url =
    urlOriginPath url <> qs (urlQuery url) <> urlFragment url
    where
        qs :: Maybe Query -> MisoString
        qs Nothing = ""
        qs (Just q) = ms (renderQuery True q)


instance FromJSON Url where
    parseJSON v = parseUrl <$> parseJSON v

