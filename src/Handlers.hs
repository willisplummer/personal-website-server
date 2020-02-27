{-# LANGUAGE FlexibleContexts #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Time
import Database.Persist.Sql
import Models

subscriptionHandler :: (Monad m, MonadReader SqlBackend m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nsEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()

getBooksHandler :: (Monad m, MonadReader SqlBackend m, MonadIO m) => m [Book]
getBooksHandler = do
  bookEntities <- runDb $ selectList [] []
  return $ entityVal <$> bookEntities

addBookHandler :: (Monad m, MonadReader SqlBackend m, MonadIO m) => NewBook -> m ()
addBookHandler NewBook{ nbTitle = title, nbAuthor = author } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Book title author now now)
  return ()
