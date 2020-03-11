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
import           Types

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Subscription sql=subscriptions
    email String
    createdAt UTCTime
    updatedAt UTCTime
    deriving Show Generic
|]

runDb :: (MonadReader AppState m, MonadIO m) => SqlPersistT IO b -> m b
runDb query = do
  state <- ask
  liftIO $ runSqlConn query (sql state)
