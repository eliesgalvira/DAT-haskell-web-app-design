{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_life (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,0,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/bin"
libdir     = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/lib/x86_64-linux-ghc-9.2.8/life-0.0.0.0-TsbZpPV7LlCOcOM6taxrz-exemple"
dynlibdir  = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/lib/x86_64-linux-ghc-9.2.8"
datadir    = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/share/x86_64-linux-ghc-9.2.8/life-0.0.0.0"
libexecdir = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/libexec/x86_64-linux-ghc-9.2.8/life-0.0.0.0"
sysconfdir = "/home/bigweld/Repos/DAT-haskell-web-app-design/lab2/dat-prj/.stack-work/install/x86_64-linux/61512f0f2d995b12a2d04bd30ec6068d08e57c6f21de2a1cc19b32b4d72b35ed/9.2.8/etc"

getBinDir     = catchIO (getEnv "life_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "life_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "life_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "life_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "life_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "life_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
