  
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

corsWithContentType :: Middleware
corsWithContentType = cors (const $ Just policy)
    where
      policy = simpleCorsResourcePolicy
        { corsRequestHeaders = ["Content-Type"] }

main :: IO ()
main = runStdoutLoggingT . withSqliteConn ":memory:" $ \sqlite -> do
  flip runSqlConn sqlite $ runMigration migrateAll
  eBooks <- liftIO $ Y.decodeFileEither "books.yml"
  
  let
    parsedBooks = fromRight [] eBooks
    appState = AppState { sql = sqlite, readingList = parsedBooks }
  liftIO $ putStrLn $ show parsedBooks 
  lift . run 8080 . corsWithContentType . serve api $ hoistServer api (runH appState) routes

  where
    runH appState = Handler . flip runReaderT appState
