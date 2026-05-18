
{-# LANGUAGE OverloadedStrings #-}

module Main
where
import           Network.Wai
import           Network.HTTP.Types (SimpleQuery, parseSimpleQuery, ok200, seeOther303, methodNotAllowed405,
                                     hContentType, hLocation)
import           Network.Wai.Handler.Warp (runEnv)

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
                        (stringUtf8 $ htmlView value Nothing)
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
                            (stringUtf8 $ htmlView value $ Just err)
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


htmlView :: Int -> Maybe String -> String
htmlView value mberr = unlines
    [ "<!DOCTYPE html"
    , "<head>"
    , "  <title>Acumulador</title>"
    , "</head><body>"
    , "  <h1>Valor actual: " <> show value <> "</h1>"
    , "  <hr>"
    , "  <form method='POST' action='#'"
    , "    <span>Qüantitat a afegir: </span><input type='text' name='add' value='0'>"
    ,      case mberr of
             Just err -> "<div style='color:red'>" <> err <> "</div>"
             Nothing -> ""
    , "    <input type='submit' name='ok' value='Afegeix'>"
    ]

