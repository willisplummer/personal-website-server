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

module Types where

import           Control.Monad.Reader
import           Data.Aeson
import           Data.Aeson.Casing
import           Database.Persist.Sql
import           Data.Time ( UTCTime, getCurrentTime )
import           GHC.Generics

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

instance ToJSON NewBook where
    toJSON = genericToJSON $ aesonPrefix camelCase

data AppState = AppState {
  sql :: SqlBackend
, readingList :: [NewBook]
}
