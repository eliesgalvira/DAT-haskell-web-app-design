
{-# LANGUAGE OverloadedStrings #-}

module Forums.App
where
import Forums.Config
import Forums.Found
import Forums.Model
import Forums.Handler

import Develop.DatFw

import Network.Wai

-- ---------------------------------------------------------------
-- Application initialization

makeApp :: IO Application
makeApp = do
    -- Open the database (the model state)
    db <- openDb forumsDbName
    toApp ForumsApp{ forumsDb = db } handle
    where
      handle route =
        case route of
            HomeR -> selectMethod
                [ onMethod "GET" getHomeR
                , onMethod "POST" postHomeR
                ]
            ForumR fid -> selectMethod
                [ onMethod "GET" $ getForumR fid
                , onMethod "POST" $ postForumR fid
                ]
            TopicR tid -> selectMethod
                [ onMethod "GET" $ getTopicR tid
                , onMethod "POST" $ postTopicR tid
                ]
            LoginR -> selectMethod
                [ onMethod "GET" getLoginR
                , onMethod "POST" postLoginR
                ]
            LogoutR -> selectMethod
                [ onAnyMethod handleLogoutR
                ]

