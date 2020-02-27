{-# LANGUAGE FlexibleContexts #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Time
import Database.Persist.Sql
import Models

subscriptionHandler :: (Monad m, MonadReader SqlBackend m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()
