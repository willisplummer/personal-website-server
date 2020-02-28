{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RankNTypes    #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}

module API (api, routes) where

import           Control.Monad.Except
import Control.Monad.Trans.Reader (ReaderT)

import Servant

import Servant.API.Generic
import Servant.Server.Generic

import Handlers
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

