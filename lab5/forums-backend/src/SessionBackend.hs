
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE CPP #-}

-- #define DEBUG_SESSION

module SessionBackend
where
import           Control.Arrow (first)
import           Control.Monad (guard)
import           Data.ByteString (ByteString)
import qualified Data.ByteString as B
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Char8 as B8
import qualified Data.ByteString.Lazy as BL
import           Data.Int
import qualified Data.Map as M
#ifndef DEBUG_SESSION
import           Data.Serialize
#endif
import           Data.Text (Text)
import qualified Data.Text as T
#ifdef DEBUG_SESSION
import           Data.Text.Encoding as T
#endif
import           Data.Time
import           Develop.DatFw
import           Network.HTTP.Types as H
import           Network.Wai as W
import           System.Environment
#ifndef DEBUG_SESSION
import qualified Web.ClientSession as CS
#endif
import           Web.Cookie as W

sessionName :: B.ByteString -- ^ session cookie key
sessionName = "_SESSION"

sessionMaxAge :: NominalDiffTime
#ifdef DEBUG_SESSION
        -- ^ max age is 5 minutes
sessionMaxAge = 300
#else
        -- ^ max age is 1 hour
sessionMaxAge = 3600
#endif

type SessionBackend = Request -> IO (SessionMap, SaveSession)
type SessionMap = M.Map Text ByteString
type SaveSession = SessionMap -> IO [Header]

mkSessionBackend :: IO SessionBackend
mkSessionBackend = do
#ifdef DEBUG_SESSION
    let key = ()
#else
    key <- CS.getKey CS.defaultKeyFile
#endif
    pure $ sessionBackend key

sessionBackend :: CS_Key -> SessionBackend
sessionBackend key request = do
      -- NOTE: Avoids cookies from other apps in the same server (must be revised)
      env <- getEnvironment
      let path = maybe "/" B8.pack $ lookup "SCRIPT_NAME" env
      now <- getCurrentTime
      let expires  = sessionMaxAge `addUTCTime` now
      pure (loadSession now, saveSession path expires)
    where
        loadSession now = M.unions $ do -- List monad
            val <- [ cv | (hk, hv) <- requestHeaders request, hk == "Cookie",
                          (ck, cv) <- parseCookies hv, ck == sessionName ]
            maybe [] pure $ decodeSessionCookie key now val
        saveSession path expires sess = do
#ifdef DEBUG_SESSION
            let iv = ()
#else
            -- We should never cache the IV!  Be careful!
            iv <- CS.randomIV
#endif
            let cookieValue = encodeSessionCookie key iv expires sess
                setCookie = defaultSetCookie
                    { setCookieName = sessionName
                    , setCookieValue = cookieValue
                    , setCookiePath = Just path -- The application path from getenv("SCRIPT_NAME")
                    , setCookieExpires = Just expires
                    , setCookieHttpOnly = True
                    }
            pure [("Set-Cookie", BL.toStrict $ BB.toLazyByteString $ renderSetCookie setCookie)]

#ifdef DEBUG_SESSION
type CS_Key = ()
type CS_IV = ()
#else
type CS_Key = CS.Key
type CS_IV = CS.IV
#endif

encodeSessionCookie :: CS_Key
                    -> CS_IV
                    -> UTCTime  -- ^ expire time
                    -> SessionMap -- ^ session
                    -> ByteString -- ^ cookie value
#ifdef DEBUG_SESSION
encodeSessionCookie _ _ _ session =
    let pairs = M.toList session
        f (n,v) = (T.encodeUtf8 n, Just v)
    in urlEncode False $ H.renderQuery False (f <$> pairs)
#else
encodeSessionCookie key iv expires session =
    CS.encrypt key iv $ encode $ SessionCookie expires session
#endif

decodeSessionCookie :: CS_Key
                    -> UTCTime  -- ^ current time
                    -> ByteString -- ^ cookie value
                    -> Maybe SessionMap
#ifdef DEBUG_SESSION
decodeSessionCookie _ _ cookieValue =
    let pairs = do -- List monad
            (k, Just v) <- H.parseQuery $ urlDecode False cookieValue
            pure (T.decodeUtf8 k, v)
    in Just $ M.fromList pairs
#else
decodeSessionCookie key now cookieValue = do
    decrypted <- CS.decrypt key cookieValue
    SessionCookie expire session <-
        either (const Nothing) Just $ decode decrypted
    guard $ expire > now
    Just session
#endif

#ifndef DEBUG_SESSION
data SessionCookie = SessionCookie !UTCTime !SessionMap
    deriving (Show, Read)
instance Serialize SessionCookie where
    put (SessionCookie a b) = do
        put a
        put (map (first T.unpack) $ M.toList b)

    get = do
        a <- get
        b <- M.fromList . map (first T.pack) <$> get
        pure $ SessionCookie a b

instance Serialize UTCTime where
    put (UTCTime d t) =
        let d' = fromInteger  $ toModifiedJulianDay d
            t' = fromIntegral $ fromEnum (t / diffTimeScale)
        in put (d' * posixDayLength + min posixDayLength t')

    get = do
        val <- get
        let (d, t) = val `divMod` posixDayLength
            d' = ModifiedJulianDay $! fromIntegral d
            t' = fromIntegral t
        d' `seq` t' `seq` pure (UTCTime d' t')

posixDayLength :: Int64
posixDayLength = 86400

diffTimeScale :: DiffTime
diffTimeScale = 1e12
#endif

