{-# LANGUAGE ScopedTypeVariables #-}

module MigrateDB where

import           Control.Monad.Logger           ( runStdoutLoggingT )
import           Control.Monad.Reader           ( runReaderT )
import           System.Environment
import           Database.Persist.Postgresql    ( PostgresConf(..)
                                                , runMigrationUnsafe
                                                , withPostgresqlConn
                                                )

import           Models                       ( migrateAll )
import           Web.Heroku.Persist.Postgresql

main :: IO ()
main = do
  (PostgresConf connString poolSize) <- postgresConf 5
  runStdoutLoggingT $ withPostgresqlConn connString $ \backend ->
    runReaderT (runMigrationUnsafe migrateAll) backend

  
