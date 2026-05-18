
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import           Network.Wai
import           Network.HTTP.Types (SimpleQuery, parseSimpleQuery, ok200, seeOther303, methodNotAllowed405,
                                     hContentType, hLocation)
import           Network.Wai.Handler.Warp (runEnv)

import qualified Text.Blaze.Html5 as H
import           Text.Blaze.Html5.Attributes as A
import           Text.Blaze.Html.Renderer.Utf8 (renderHtmlBuilder)

import qualified Data.Text as T
import           Data.Text.Encoding as T
import           Data.ByteString.Builder (stringUtf8)
import qualified Data.ByteString as B
import           Data.IORef
import           Text.Read (readEither)

-- ****************************************************************

main :: IO ()
main = do
    valref <- newIORef 0
    -- runEnv :: Port -> Application -> IO ()
    runEnv 4050 (app valref)

-- ****************************************************************

app :: IORef Int -> Application
app valueRef req respond = do -- Monad IO
    value <- readIORef valueRef
    case requestMethod req of
        "GET" -> do
            respond $
                responseBuilder
                        ok200
                        [(hContentType, "text/html;charset=utf-8")]
                        (renderHtmlBuilder $ htmlView value Nothing)
        "POST" -> do
            query <- requestPostQuery req
            let eadd = do -- Monad (Either String)
                    svalue <- maybe (Left "Valor obligatori") (Right . T.decodeUtf8) $
                                lookup "add" query
                    readEither $ T.unpack svalue
            case eadd of
                Left err ->
                    respond $
                        responseBuilder
                            ok200
                            [(hContentType, "text/html;charset=utf-8")]
                            (renderHtmlBuilder $ htmlView value $ Just err)
                Right add -> do
                    writeIORef valueRef $ value + add
                    respond $
                        responseBuilder
                            seeOther303
                            [(hLocation, "#")]
                            mempty
        _ ->
            respond $
                responseBuilder
                        methodNotAllowed405
                        [(hContentType, "text/plain")]
                        (stringUtf8 "Invalid method")


requestPostQuery :: Request -> IO SimpleQuery
requestPostQuery req =
    if lookup hContentType (requestHeaders req) == Just "application/x-www-form-urlencoded" then
        parseSimpleQuery <$> getBody req
    else
        pure mempty
    where
        getBody req = do
            b <- getRequestBodyChunk req
            if B.null b then pure b
            else do
                bs <- getBody req
                pure $ b <> bs


htmlView :: Int -> Maybe String -> H.Html
htmlView value mberr =
    H.docTypeHtml $ do
        H.head $
            H.title "Acumulador"
        H.body $ do
            H.h1 $ H.text $ "Valor actual: " <> T.pack (show value)
            H.hr
            H.form H.! A.method "POST" H.! A.action "#" $ do
                H.p $ do
                    H.span "Qüantitat a afegir:"
                    H.input H.! A.name "add" H.! A.value "0"
                    case mberr of
                        Just err -> H.div H.! A.style "color:red" $ H.text (T.pack err)
                        Nothing -> mempty
                H.input H.! A.type_ "submit" H.! A.name "ok" H.! A.value "Afegeix"

