
{-# LANGUAGE OverloadedStrings #-}

module Forums.AuthHandler
where
import Forums.Found
import Forums.View
import Forums.Model

import Develop.DatFw
import           Develop.DatFw.Form
import           Develop.DatFw.Form.Fields

import           Data.Text (Text)

-- ---------------------------------------------------------------
-- Controller handlers: Autenticació

loginDest, logoutDest :: Route ForumsApp
loginDest  = StaticR [""] []
logoutDest = StaticR [""] []

loginForm :: MonadHandler m => AForm m (Text, Text)
loginForm =
    (,) <$> freq textField "Nom d'usuari" Nothing
        <*> freq passwordField "Clau d'accés" Nothing

getLoginR :: HandlerFor ForumsApp Html
getLoginR = do
    setRedirect
    -- Return HTML page
    (_, formw) <- runAFormPost loginForm
    appLayout $ loginView formw

setRedirect :: HandlerFor ForumsApp ()
setRedirect = do
    mbredirect <- lookupGetParam "redirect_url"
    maybe setUltDestReferer setUltDest mbredirect

postLoginR :: HandlerFor ForumsApp Html
postLoginR = do
    (formr, formw) <- runAFormPost loginForm
    case formr of
        FormSuccess (name, password) -> do
            ok <- validatePassword name password
            if ok then do
                -- Good credentials
                Just uid <- runDbAction $ loginUser name
                setSession authId_SESSION_KEY $ toPathPiece uid
                redirectUltDest loginDest
            else do
                -- Login error
                setMessage "Error d'autenticaciò"
                redirect LoginR
        _ ->
            appLayout (loginView formw)
    where
        validatePassword :: Text -> Text -> HandlerFor ForumsApp Bool
        validatePassword name password = do
            mbuser <- runDbAction $ getUserByName name
            case mbuser of
                Nothing -> pure False
                Just (_, user) -> pure $ pHashValidate password $ udPassword user

handleLogoutR :: HandlerFor ForumsApp ()
handleLogoutR = do
    -- | After logout (from the browser), redirect to the referring page.
    setRedirect
    deleteSession authId_SESSION_KEY
    redirectUltDest logoutDest

-- ---------------------------------------------------------------
-- Controller handlers: User profile

data ChangePass = ChangePass { changePassOld :: Text, changePassNew1 :: Text, changePassNew2 :: Text }

changePassForm :: AForm (HandlerFor ForumsApp) ChangePass
changePassForm = ChangePass
        <$> freq passwordField (withPlaceholder "Introdueix la contrasenya actual" "Contrasenya actual") Nothing
        <*> freq passwordField (withPlaceholder "Introdueix la nova contrasenya" "Nova contrasenya") Nothing
        <*> freq passwordField (withPlaceholder "Introdueix la nova contrasenya" "Confirma") Nothing

getChangePassR :: HandlerFor ForumsApp Html
getChangePassR = do
    user <- requireAuth
    setUltDestReferer
    cformw <- generateAFormPost changePassForm
    -- Return HTML content
    appLayout $ changePassView cformw

postChangePassR :: HandlerFor ForumsApp Html
postChangePassR = do
    (uid, userd) <- requireAuth
    (cr, cformw) <- runAFormPost changePassForm
    case cr of
        FormSuccess chpass -> do
            let ok = pHashValidate (changePassOld chpass) $ udPassword userd
            if not ok then do
                setMessage "Error d'autenticació"
                appLayout $ changePassView cformw
            else if changePassNew1 chpass /= changePassNew2 chpass then do
                setMessage "Les contrasenyes no coincideixen"
                appLayout $ changePassView cformw
            else do
                runDbAction $ changeUserPassword uid $ changePassNew1 chpass
                setMessage "Contrasenya canviada"
                redirectUltDest loginDest
        _ ->
            appLayout $ changePassView cformw

