  
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE ScopedTypeVariables  #-}

module Main where

import           API
import           Types

import           Control.Monad.Except
import           Control.Monad.Logger
import           Control.Monad.Reader
import           Data.Either
import           Database.Persist.Postgresql

import           Network.Wai.Handler.Warp  (run)
import           Servant
import           System.Environment


import qualified Data.Yaml as Y
import qualified Data.Map.Strict as Map
import Web.Heroku.Persist.Postgresql

main :: IO ()
main = do
  (port :: Int) <- read <$> getEnv "PORT"
  pgConf <- postgresConf 5

  eBooks <- liftIO $ Y.decodeFileEither "./data/books.yml"
  eWritingLinks <- liftIO $ Y.decodeFileEither "./data/writing-links.yml"

  putStrLn $ "running on " <> show port

  let
    connString = pgConnStr pgConf

    parsedBooks :: Map.Map String [Book]
    parsedBooks = fromRight Map.empty eBooks

    parsedWritingLinks :: Map.Map String [WritingLink]
    parsedWritingLinks = fromRight Map.empty eWritingLinks

  runStdoutLoggingT $ withPostgresqlConn connString $ \db -> do
    let
      appState = AppState { sql = db, readingList = parsedBooks, writingLinks = parsedWritingLinks }
      runH s = Handler . flip runReaderT s

    liftIO $ putStrLn $ show parsedBooks
    lift . run port . serve api $ hoistServer api (runH appState) routes
