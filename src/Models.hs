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
import           Data.Time ( UTCTime, getCurrentTime )
import           Database.Persist.Sql
import           Database.Persist.TH
import           GHC.Generics

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Subscription sql=subscriptions
    email String
    createdAt UTCTime
    updatedAt UTCTime
    deriving Show
|]

data NewSubscription = NewSubscription {
    nEmail :: String
} deriving (Show, Eq, Read, Generic)

instance FromJSON NewSubscription

runDb :: (MonadReader SqlBackend m, MonadIO m) => SqlPersistT IO b -> m b
runDb query = do
  conn <- ask
  liftIO $ runSqlConn query conn
