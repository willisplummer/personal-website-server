  
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module Main where

import           API
import           Models
import           Types

import           Control.Monad.Except
import           Control.Monad.Logger
import           Control.Monad.Reader
import           Data.Either
import           Database.Persist.Sqlite
import           Network.Wai (Middleware)
import           Network.Wai.Handler.Warp  (run)
import           Network.Wai.Middleware.Cors
import           Servant

import qualified Data.Yaml as Y
import qualified Data.Map.Strict as Map

corsWithContentType :: Middleware
corsWithContentType = cors (const $ Just policy)
    where
      policy = simpleCorsResourcePolicy
        { corsRequestHeaders = ["Content-Type"] }

main :: IO ()
main = runStdoutLoggingT . withSqliteConn ":memory:" $ \sqlite -> do
  flip runSqlConn sqlite $ runMigration migrateAll
  eBooks <- liftIO $ Y.decodeFileEither "./data/books.yml"
  eWritingLinks <- liftIO $ Y.decodeFileEither "./data/writing-links.yml"
  
  let
    parsedBooks :: Map.Map String [Book]
    parsedBooks = fromRight Map.empty eBooks
    parsedWritingLinks :: Map.Map String [WritingLink]
    parsedWritingLinks = fromRight Map.empty eWritingLinks
    appState = AppState { sql = sqlite, readingList = parsedBooks, writingLinks = parsedWritingLinks }
  liftIO $ putStrLn $ show parsedBooks 
  lift . run 8080 . corsWithContentType . serve api $ hoistServer api (runH appState) routes

  where
    runH appState = Handler . flip runReaderT appState
