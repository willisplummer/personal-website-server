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
import qualified Data.Map.Strict as Map

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

type BookMap = Map.Map String [Book]

data WritingLink = WritingLink {
    wlText :: String
,   wlHref :: String
} deriving (Show, Eq, Read, Generic)

instance FromJSON WritingLink where
    parseJSON = genericParseJSON $ aesonPrefix camelCase

instance ToJSON WritingLink where
    toJSON = genericToJSON $ aesonPrefix camelCase

type WritingLinkMap = Map.Map String [WritingLink]

data AppState = AppState {
  sql :: SqlBackend
, readingList :: BookMap
, writingLinks :: WritingLinkMap
}
