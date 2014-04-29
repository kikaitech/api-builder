module APIBuilder.Examples.StackOverflow where

import APIBuilder
import Control.Applicative
import Data.Aeson
import Data.Monoid (mempty)
import Data.Text (Text)

data Question = Question { title :: Text
                         , isAnswered :: Bool
                         , score :: Int
                         , tags :: [Text] }
  deriving (Show, Eq)

newtype Questions = Questions [Question]
  deriving (Show, Eq)

instance FromJSON Question where
  parseJSON (Object o) =
    Question <$> o .: "title"
             <*> o .: "is_answered"
             <*> o .: "score"
             <*> o .: "tags"
  parseJSON _ = mempty

instance FromJSON Questions where
  parseJSON (Object o) = Questions <$> o .: "items"
  parseJSON _ = mempty

stackOverflow :: Builder
stackOverflow = basicBuilder "StackOverflow API" "http://api.stackexchange.com"

answersRoute :: Route
answersRoute = Route { fragments = [ "2.2", "questions" ]
                     , urlParams = [ "order" =. Just "desc"
                                   , "sort" =. Just "activity"
                                   , "site" =. Just "stackoverflow" ]
                     , httpMethod = GET }

getAnswers :: IO (Either (APIError ()) Questions)
getAnswers = runAPI stackOverflow () $ runRoute answersRoute