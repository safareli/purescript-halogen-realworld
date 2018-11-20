module Data.Article where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson, (.?))
import Data.Author (Author, decodeAuthor)
import Data.DateTime (DateTime)
import Data.Either (Either)
import Data.Formatter.DateTime (unformatDateTime)
import Data.Traversable (traverse)
import Data.Username (Username)
import Slug (Slug)

-- Next, we'll define our larger comment data type

type Article =
  { slug :: Slug 
  , title :: String
  , description :: String
  , body :: String
  , tagList :: Array String
  , createdAt :: DateTime
  , favorited :: Boolean
  , favoritesCount :: Int
  , author :: Author
  }

-- This manual instance is necessary because there is no instance  for an author
-- or datetime; we'll need additional information for decoding than the data type
-- alone, though generic decoding for records is supported.

decodeArticles :: Username -> Json -> Either String (Array Article)
decodeArticles u json = do
  arr <- decodeJson json 
  traverse (decodeArticle u) arr

decodeArticle :: Username -> Json -> Either String Article
decodeArticle u json = do
  obj <- decodeJson json
  slug <- obj .? "slug"
  title <- obj .? "title"
  body <- obj .? "body"
  description <- obj .? "description"
  tagList <- obj .? "tagList"
  favorited <- obj .? "favorited"
  favoritesCount <- obj .? "favoritesCount"
  createdAt <- unformatDateTime "X" =<< obj .? "createdAt"
  author <- decodeAuthor u =<< obj .? "author"

  pure 
    { slug
    , title
    , body
    , description
    , tagList 
    , createdAt
    , favorited
    , favoritesCount
    , author
    }