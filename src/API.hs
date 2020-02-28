{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RankNTypes    #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}

module API (api, routes) where

import Control.Exception          (throwIO)
import           Control.Monad.Except
import Control.Monad.Trans.Reader (ReaderT, runReaderT)
import           Database.Persist.Sql
import Data.Proxy                 (Proxy (..))
import Network.Wai.Handler.Warp   (run)

import Servant
import Servant.Server

import Servant.API.Generic
import Servant.Server.Generic

import Handlers
import Models
import Types

data Routes route = Routes
    { _subscribe :: route :- "subscriptions" :> ReqBody '[JSON] NewSubscription :> Post '[JSON] ()
    , _getBooks :: route :- "books" :> Get '[JSON] [Book]
    }
  deriving (Generic)

api :: Proxy (ToServantApi Routes)
api = genericApi (Proxy :: Proxy Routes)

type AppT = ReaderT AppState (ExceptT ServerError IO)

routes :: ToServant Routes (AsServerT AppT)
routes = genericServerT Routes
    { _subscribe = subscriptionHandler
    , _getBooks = getBooksHandler
    }

