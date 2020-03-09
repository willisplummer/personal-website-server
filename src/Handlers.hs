{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE BlockArguments     #-}
{-# LANGUAGE NamedFieldPuns     #-}

module Handlers where

import           Control.Monad.Reader
import           Control.Monad.Trans
import Data.Text (Text, pack)
import Data.Time
import Database.Persist.Sql
import Lucid
import Servant.HTML.Lucid
import Models
import Types
import qualified Data.Map.Strict as Map

subscriptionHandler :: (MonadReader AppState m, MonadIO m) => NewSubscription -> m ()
subscriptionHandler NewSubscription{ nsEmail = subscriptionEmail } = do
  now <- liftIO getCurrentTime
  runDb $ insert (Subscription subscriptionEmail now now)
  return ()

getBooksHandler :: (MonadReader AppState m) => m (BookMap)
getBooksHandler = do
  state <- ask
  return $ readingList state

headerNav :: Html ()
headerNav = do
  h1_ "Willis Plummer"
  nav_ do
    a_ [href_ "/"] "about"
    span_ " | "
    a_ [href_ "/writing"] "writing"
    span_ " | "
    a_ [href_ "/reading-list"] "reading"
    span_ " | "
    a_ [href_ "/code"] "code"

renderCodePage :: Html ()
renderCodePage = do
  html_ do
    head_ do
      title_ "Willis Plummer"
      link_ [rel_ "icon", href_ "/static/favicon.ico", type_ "image/x-icon"]
    body_ do
      headerNav
    p_ do
      span_ "I've got a lot of projects on my "
      a_ [href_ "https://github.com/willisplummer", target_ "blank"] "Github"
      span_ "."
    p_ "A few I'm proud of:"
    ul_ do
      li_ do
        span_ "This website is a Haskell server. The HTML is generated with Lucid,\
              \there's a postgresql database managed by Persistent to handle email\
              \subscriptions, and the API is setup using Servant. Check out "
        a_
          [href_ "https://github.com/willisplummer/personal-website-server", target_ "blank"]
          "the code"
        span_ "."
      li_ do
        span_ "I worked with my friend Luiza Dale to build a web app for 'publicly texting'.\
              \Basically, you can set up a new conversation by providing two phone numbers\
              \and then the server will text both of them via Twilio. Anything they reply to\
              \that message will be recorded to the database and then proxied along to the other person.\
              \This facilitates having a conversation over text message that is recorded and displayed\
              \online and in realtime. Check out "
        a_ [href_ "https://github.com/willisplummer/public-texting", target_ "blank"] "the code"
        span_ " and "
        a_ [href_ "https://public-texting.herokuapp.com/", target_ "blank"] "the site"
        span_ "."


renderBooksPage :: (MonadReader AppState m) => m (Html ())
renderBooksPage = do
  state <- ask
  let
    booksByYear :: [(String, [Book])]
    booksByYear = reverse . Map.toList . readingList $ state

    bookString :: Book -> String
    bookString book = bTitle book <> ", " <> bAuthor book

    renderBooksByYear :: (String, [Book]) -> Html ()
    renderBooksByYear (year, books) = do
      div_ . b_ . toHtml $ year
      ul_ $ mapM_  (li_ . toHtml . bookString) books

  return $ html_ do
    head_ do
      title_ "Willis Plummer | Reading List"
      link_ [rel_ "icon", href_ "/static/favicon.ico", type_ "image/x-icon"]
    body_ do
      headerNav
      mapM_ renderBooksByYear booksByYear

renderWritingPage :: (MonadReader AppState m) => m (Html ())
renderWritingPage = do
  state <- ask
  let
    links :: [(String, [WritingLink])]
    links = Map.toList $ writingLinks $ state

    renderLink :: WritingLink -> Html()
    renderLink WritingLink{wlText, wlHref} = li_ $ a_ [href_ . pack $ wlHref] (toHtml wlText)

    renderLinksByCategory :: (String, [WritingLink]) -> Html ()
    renderLinksByCategory (category, links) = do
      div_ . b_ . toHtml $ category
      ul_ $ mapM_  renderLink links

  return $ html_ do
    head_ do
      title_ "Willis Plummer | Writing"
      link_ [rel_ "icon", href_ "/static/favicon.ico", type_ "image/x-icon"]
    body_ do
      headerNav
      mapM_ renderLinksByCategory links

renderHomePage :: Html ()
renderHomePage = do
  html_ do
    head_ do
      title_ "Willis Plummer"
      link_ [rel_ "icon", href_ "/static/favicon.ico", type_ "image/x-icon"]
      script_ [src_ "/static/main.js"] ("" :: Text)
    body_ do
      headerNav
      p_ "Hi, I'm Willis. I live in Brookyln. I write code, poetry, and fiction."
      p_ do
        span_ "I'm a senior software engineer at "
        a_ [href_ "https://odeko.com/", target_ "blank"] "Odeko"
        span_ "."
      p_ do
        span_ "I sometimes contribute interviews to "
        a_ [href_ "https://thecreativeindependent.com/people/willis-plummer/", target_ "blank"] "The Creative Independent"
        span_ "."
      p_ do
        span_ "Feel free to send me an "
        a_ [href_  "mailto:willisplummer@gmail.com"] "email"
        span_ "."

      br_ []
      br_ []
      p_ "You should probably subscribe to my mailing list"
      input_ [id_ "email-input", type_ "text", name_ "email"]
      button_ [id_ "submit-button"] "subscribe"
