{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RankNTypes    #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}

module API (api, routes) where

import           Control.Monad.Except
import Control.Monad.Trans.Reader (ReaderT)

import Lucid
import Servant

import Servant.API.Generic
import Servant.Server.Generic
import Servant.Server.StaticFiles
import Servant.HTML.Lucid

import Handlers
import Types

data Routes route = Routes
    { _subscribe :: route :- "api" :> "subscriptions" :> ReqBody '[FormUrlEncoded, JSON] NewSubscription :> Post '[JSON] ()
    , _getBooks :: route :- "api" :> "books" :> Get '[JSON] [Book]
    , _getHome :: route :- Get '[HTML] (Html ())
    , _getReadingList :: route :- "books" :> Get '[HTML] (Html ())
    , _getStaticAssets :: route :- "static" :> Raw
    }
  deriving (Generic)

api :: Proxy (ToServantApi Routes)
api = genericApi (Proxy :: Proxy Routes)

type AppT = ReaderT AppState (ExceptT ServerError IO)

routes :: ToServant Routes (AsServerT AppT)
routes = genericServerT Routes
    { _subscribe = subscriptionHandler
    , _getBooks = getBooksHandler
    , _getHome = return renderHomePage
    , _getReadingList = renderBooksPage
    , _getStaticAssets = serveDirectoryWebApp "./static"
    }

