{-# LANGUAGE FlexibleContexts #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Time
import Database.Persist.Sql
import Models
import Types

subscriptionHandler :: (Monad m, MonadReader AppState m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nsEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()

getBooksHandler :: (MonadReader AppState m) => m [NewBook]
getBooksHandler = do
  state <- ask
  return $ readingList state

addBookHandler :: (Monad m, MonadReader AppState m, MonadIO m) => NewBook -> m ()
addBookHandler NewBook{ nbTitle = title, nbAuthor = author } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Book title author now now)
  return ()
