
{-# LANGUAGE OverloadedStrings #-}

module Forums.App
where
import Forums.Config
import Forums.Found
import Forums.Model
import Forums.Handler
import Forums.AuthHandler

import Develop.DatFw
import Develop.DatFw.Dispatch

import Network.Wai

-- ---------------------------------------------------------------
-- Application initialization

makeApp :: IO Application
makeApp = do
    -- Open the database (the model state)
    db <- openDb forumsDbName
    toApp ForumsApp{ forumsDb = db } handle
      where
        -- RESTful API:
        handle (ApiR apiR) = handleApi apiR
        -- Authentication interface:
        handle LoginR = selectMethod
                [ onMethod "GET" getLoginR
                , onMethod "POST" postLoginR
                ]
        handle LogoutR = selectMethod
                [ onAnyMethod handleLogoutR
                ]
        handle ChangePassR = selectMethod
                [ onMethod "GET" getChangePassR
                , onMethod "POST" postChangePassR
                ]
        -- Static
        handle (StaticR ss ps) = selectMethod
                [ onMethod "GET" $ getStaticR ss ps
                ]
        --------
        handleApi ForumsR = selectMethod
                [ onMethod "GET" $ addCORSHeader getForumsR
                , onMethod "POST" postForumsR
                ]
        handleApi (ForumR fid) = selectMethod
                [ onMethod "GET" $ addCORSHeader $ getForumR fid
                , onMethod "DELETE" $ deleteForumR fid
                ]
        handleApi (ForumTopicsR fid) = selectMethod
                [ onMethod "GET" $ addCORSHeader $ getForumTopicsR fid
                , onMethod "POST" $ postForumTopicsR fid
                , onMethod "OPTIONS" $ optionsForumTopicsR fid
                ]
        handleApi (TopicR tid) = selectMethod
                [ onMethod "GET" $ addCORSHeader $ getTopicR tid
                , onMethod "DELETE" $ deleteTopicR tid
                ]
        handleApi (TopicPostsR tid) = selectMethod
                [ onMethod "GET" $ addCORSHeader $ getTopicPostsR tid
                , onMethod "POST" $ postTopicPostsR tid
                ]
        handleApi (PostR pid) = selectMethod
                [ onMethod "GET" $ addCORSHeader $ getPostR pid
                , onMethod "DELETE" $ deletePostR pid
                ]
        --------
        handleApi UserR = selectMethod
                [ onMethod "GET" $ addCORSHeader getUserR
                ]
        --------
        handleApi MarkdownR = selectMethod
                [ onMethod "POST" $ postMarkdownR
                ]

addCORSHeader :: HandlerFor a res -> HandlerFor a res
addCORSHeader handler = do
    mborig <- lookupHeader "Origin"
    addHeader "Access-Control-Allow-Origin" $ maybe "*" id mborig
    addHeader "Vary" "Origin"
    handler

