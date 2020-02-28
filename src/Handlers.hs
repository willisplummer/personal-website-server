{-# LANGUAGE FlexibleContexts #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Time
import Database.Persist.Sql
import Models
import Types

subscriptionHandler :: (MonadReader AppState m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nsEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()

getBooksHandler :: (MonadReader AppState m) => m [Book]
getBooksHandler = do
  state <- ask
  return $ readingList state
