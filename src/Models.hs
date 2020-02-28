{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RankNTypes    #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE UndecidableInstances #-}

module Models where

import           Control.Monad.Reader
import           Data.Aeson
import           Data.Aeson.Casing
import           Data.Time ( UTCTime, getCurrentTime )
import           Database.Persist.Sql
import           Database.Persist.TH
import           GHC.Generics

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Subscription sql=subscriptions
    email String
    createdAt UTCTime
    updatedAt UTCTime
    deriving Show Generic
Book sql=books
    title String
    author String
    createdAt UTCTime
    updatedAt UTCTime
    deriving Show Generic
|]
instance ToJSON Book

data NewSubscription = NewSubscription {
    nsEmail :: String
} deriving (Show, Eq, Read, Generic)

instance FromJSON NewSubscription where
    parseJSON = genericParseJSON $ aesonPrefix camelCase

data NewBook = NewBook {
    nbTitle :: String
,   nbAuthor :: String
} deriving (Show, Eq, Read, Generic)

instance FromJSON NewBook where
    parseJSON = genericParseJSON $ aesonPrefix camelCase

runDb :: (MonadReader SqlBackend m, MonadIO m) => SqlPersistT IO b -> m b
runDb query = do
  conn <- ask
  liftIO $ runSqlConn query conn
