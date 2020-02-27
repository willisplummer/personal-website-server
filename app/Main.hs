  
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Main where

import           API
import           Models

import           Control.Monad.Except
import           Control.Monad.Logger
import           Control.Monad.Reader
import           Database.Persist.Sqlite
import           Network.Wai.Handler.Warp  (run)
import           Servant

main :: IO ()
main = runStdoutLoggingT . withSqliteConn ":memory:" $ \sqlite -> do
  flip runSqlConn sqlite $ runMigration migrateAll
  lift . run 8080 . serve api $ hoistServer api (runH sqlite) routes

  where
    runH sqlite = Handler . flip runReaderT sqlite
