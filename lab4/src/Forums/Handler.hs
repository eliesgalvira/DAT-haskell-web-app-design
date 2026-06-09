
{-# LANGUAGE OverloadedStrings #-}

module Forums.Handler
where
import Forums.View
import Forums.Found
import Forums.Model

import Develop.DatFw
import Develop.DatFw.Form
import Develop.DatFw.Form.Fields

import Data.Text as T

-- ---------------------------------------------------------------

titleField :: Field (HandlerFor ForumsApp) Text
titleField = check
        (\ t -> if T.length t < minTitleLen then Left "Text massa curt"
                else if T.length t > maxTitleLen then Left "Text massa llarg"
                else Right t)
        textField

markdownField :: Field (HandlerFor ForumsApp) Markdown
markdownField = checkMap
        (\ t -> if T.length t < minPostLen then Left "Text massa curt"
                else if T.length t > maxPostLen then Left "Text massa llarg"
                else Right (Markdown t))
        getMdText
        textareaField

-- ---------------------------------------------------------------
-- Controller handlers: Home

newForumForm :: AForm (HandlerFor ForumsApp) NewForum
newForumForm =
    NewForum <$> freq titleField (withPlaceholder "Introduiu el títol del fòrum" "Titol") Nothing
             <*> freq markdownField (withPlaceholder "Introduiu la descripció del fòrum" "Descripció") Nothing

getHomeR :: HandlerFor ForumsApp Html
getHomeR = do
    -- Get authenticated user
    mbuser <- maybeAuth
    -- Get a fresh form
    fformw <- generateAFormPost newForumForm
    -- Return HTML content
    appLayout $ homeView mbuser fformw

postHomeR :: HandlerFor ForumsApp Html
postHomeR = do
    user <- requireAuth
    (fformr, fformw) <- runAFormPost newForumForm
    case fformr of
        FormSuccess newtheme -> do
            runDbAction $ addForum (fst user) newtheme
            redirect HomeR
        _ ->
            appLayout $ homeView (Just user) fformw

-- ---------------------------------------------------------------
-- Controller handlers: Forum

newTopicForm :: AForm (HandlerFor ForumsApp) NewTopic
newTopicForm =
    NewTopic <$> freq titleField (withPlaceholder "Introduiu l'assumpte de la pregunta" "Assumpte") Nothing
             <*> freq markdownField (withPlaceholder "Introduiu el contingut de la pregunta" "Contingut") Nothing

editForumForm :: ForumD -> AForm (HandlerFor ForumsApp) NewForum
editForumForm forum =
    NewForum <$> freq titleField "Titol" (Just $ fdTitle forum)
             <*> freq markdownField "Descripció" (Just $ fdDescription forum)

getForumR :: ForumId -> HandlerFor ForumsApp Html
getForumR fid = do
    -- Get requested forum from data-base.
    -- Short-circuit (responds immediately) with a 'Not found' status if forum don't exist
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    mbuser <- maybeAuth
    tformw <- generateAFormPost newTopicForm
    eformw <- generateAFormPost $ editForumForm forum
    -- Return HTML content
    appLayout $ forumView mbuser (fid, forum) tformw eformw

postForumR :: ForumId -> HandlerFor ForumsApp Html
postForumR fid = do
    forum <- runDbAction (getForum fid) >>= maybe notFound pure
    mbaction <- lookupPostParam "action"
    case mbaction of
        Just "new-topic" -> do
            user <- requireAuth
            (tformr, tformw) <- runAFormPost newTopicForm
            eformw <- generateAFormPost $ editForumForm forum
            case tformr of
                FormSuccess newtopic -> do
                    (tid, _) <- runDbAction $ addTopic fid (fst user) newtopic
                    redirect $ TopicR tid
                _ ->
                    appLayout $ forumView (Just user) (fid, forum) tformw eformw
        Just "edit-forum" -> do
            user <- requireAuth
            requireForumModerator user forum
            tformw <- generateAFormPost newTopicForm
            (eformr, eformw) <- runAFormPost $ editForumForm forum
            case eformr of
                FormSuccess newforum -> do
                    runDbAction $ editForum fid (nfTitle newforum) (nfDescription newforum)
                    redirect $ ForumR fid
                _ ->
                    appLayout $ forumView (Just user) (fid, forum) tformw eformw
        Just "delete-topic" -> do
            user <- requireAuth
            requireForumModerator user forum
            mbtid <- lookupPostParam "topic"
            case mbtid >>= fromPathPiece of
                Just tid -> do
                    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
                    if tdForumId topic == fid
                        then runDbAction (deleteTopic fid tid) >> redirect (ForumR fid)
                        else notFound
                Nothing ->
                    notFound
        Just "delete-forum" -> do
            user <- requireAuth
            requireForumModerator user forum
            runDbAction $ deleteForum fid
            redirect HomeR
        _ ->
            redirect $ ForumR fid

-- ---------------------------------------------------------------
-- Controller handlers: Topic

replyForm :: AForm (HandlerFor ForumsApp) Markdown
replyForm =
    freq markdownField (withPlaceholder "Introduiu la resposta" "Resposta") Nothing

getTopicR :: TopicId -> HandlerFor ForumsApp Html
getTopicR tid = do
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    forum <- runDbAction (getForum $ tdForumId topic) >>= maybe notFound pure
    mbuser <- maybeAuth
    rformw <- generateAFormPost replyForm
    appLayout $ topicView mbuser (tdForumId topic, forum) (tid, topic) rformw

postTopicR :: TopicId -> HandlerFor ForumsApp Html
postTopicR tid = do
    topic <- runDbAction (getTopic tid) >>= maybe notFound pure
    forum <- runDbAction (getForum $ tdForumId topic) >>= maybe notFound pure
    mbaction <- lookupPostParam "action"
    case mbaction of
        Just "reply" -> do
            user <- requireAuth
            (rformr, rformw) <- runAFormPost replyForm
            case rformr of
                FormSuccess message -> do
                    runDbAction $ addReply (tdForumId topic) tid (fst user) message
                    redirect $ TopicR tid
                _ ->
                    appLayout $ topicView (Just user) (tdForumId topic, forum) (tid, topic) rformw
        Just "delete-post" -> do
            user <- requireAuth
            requireForumModerator user forum
            mbpid <- lookupPostParam "post"
            case mbpid >>= fromPathPiece of
                Just pid -> do
                    post <- runDbAction (getPost pid) >>= maybe notFound pure
                    if pdTopicId post == tid
                        then runDbAction (deletePost (tdForumId topic) tid pid) >> redirect (TopicR tid)
                        else notFound
                Nothing ->
                    notFound
        _ ->
            redirect $ TopicR tid

requireForumModerator :: (UserId, UserD) -> ForumD -> HandlerFor ForumsApp ()
requireForumModerator (uid, _) forum =
    if uid == fdModeratorId forum
        then pure ()
        else permissionDenied "Nomes el moderador pot fer aquesta accio"


-- ---------------------------------------------------------------
-- Controller handlers: Autenticació

loginForm :: MonadHandler m => AForm m (Text, Text)
loginForm =
    (,) <$> freq textField "Nom d'usuari" Nothing
        <*> freq passwordField "Clau d'accés" Nothing

getLoginR :: HandlerFor ForumsApp Html
getLoginR = do
    setUltDestReferer
    -- Return HTML page
    (_, formw) <- runAFormPost loginForm
    appLayout $ loginView formw

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
                redirectUltDest HomeR
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
    setUltDestReferer
    deleteSession authId_SESSION_KEY
    redirectUltDest HomeR
