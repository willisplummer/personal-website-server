{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE OverloadedStrings     #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Time
import Database.Persist.Sql
import Lucid
import Servant.HTML.Lucid
import Models
import Types

subscriptionHandler :: (MonadReader AppState m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nsEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()

getBooksHandler :: (MonadReader AppState m) => m [Book]
getBooksHandler = do
  state <- ask
  return $ readingList state

renderBooksPage :: (MonadReader AppState m) => m (Html ())
renderBooksPage = do
  state <- ask
  let
    books = readingList state

    bookString :: Book -> String
    bookString book = bTitle book <> ", " <> bAuthor book

  return $ do
    h1_ "I've read these:"
    ul_ (mapM_ (li_ . toHtml . bookString) books)

renderHomePage :: Html ()
renderHomePage = do
        h1_ "Willis Plummer"
        p_ $ b_ "I'm a coder and a poet etc"
        p_ $ i_ "Check me out on the internet"
        -- TODO: how do i make this a safe link using servant-lucid
        p_ $ a_ [href_ "/books"] "i've been keeping a reading list"
        p_ "You should probably subscribe to my mailing list"
        -- can i make this safe too?
        form_ [method_ "post", action_ "/api/subscriptions"] $ do
          input_ [type_ "text", name_ "email"]
          button_ "subscribe"
