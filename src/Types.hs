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
import           Data.Aeson (genericParseJSON, genericToJSON, FromJSON, ToJSON, toJSON, parseJSON)
import           Data.Aeson.Casing
import           Data.Char (toLower)
import           Database.Persist.Sql
import           Data.Time ( UTCTime, getCurrentTime )
import           GHC.Generics
import           Web.Internal.FormUrlEncoded

data NewSubscription = NewSubscription {
    nsEmail :: String
} deriving (Show, Eq, Read, Generic)

myOptions :: FormOptions
myOptions = FormOptions
 { fieldLabelModifier = map toLower . drop 2 }

instance FromForm NewSubscription where
    fromForm =
        genericFromForm myOptions

instance FromJSON NewSubscription where
    parseJSON = genericParseJSON $ aesonPrefix camelCase

data Book = Book {
    bTitle :: String
,   bAuthor :: String
} deriving (Show, Eq, Read, Generic)

instance FromJSON Book where
    parseJSON = genericParseJSON $ aesonPrefix camelCase

instance ToJSON Book where
    toJSON = genericToJSON $ aesonPrefix camelCase

data AppState = AppState {
  sql :: SqlBackend
, readingList :: [Book]
}
