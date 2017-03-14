{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Data.JSONResumeSpec (main, spec) where

import Test.Hspec
import qualified Data.ByteString.Lazy as BL
import Data.ByteString.Lazy (ByteString)
import Data.String.Here.Uninterpolated (here, hereFile)
import Data.Aeson (FromJSON, ToJSON, decode, encode)
import Data.Time (UTCTime(..), fromGregorian)

import Data.JSONResume

addressJSON :: ByteString
addressJSON = [here|
{"address": "2712 Broadway St",
 "postalCode": "CA 94115",
 "city": "San Francisco",
 "countryCode": "US",
 "region": "California"
}
|]

addressParsed :: Address
addressParsed = Address
  { address = Just "2712 Broadway St"
  , postalCode = Just "CA 94115"
  , city = Just "San Francisco"
  , countryCode = Just "US"
  , region = Just "California"
  }

profileJSON :: ByteString
profileJSON = [here|
{"network": "Twitter",
 "username": "neutralthoughts",
 "url": ""
}
|]

profileParsed :: Profile
profileParsed = Profile
  { network = Just "Twitter"
  , username = Just "neutralthoughts"
  , url = Just ""
  }

basicsJSON :: ByteString
basicsJSON = [here|
{
    "name": "test",
    "label": "Programmer",
    "picture": "",
    "email": "test4@test.com",
    "phone": "(912) 555-4321",
    "website": "http://richardhendricks.com",
    "summary": "Richard hails from Tulsa. He has earned degrees from the University of Oklahoma and Stanford. (Go Sooners and Cardinals!) Before starting Pied Piper, he worked for Hooli as a part time software developer. While his work focuses on applied information theory, mostly optimizing lossless compression schema of both the length-limited and adaptive variants, his non-work interests range widely, everything from quantum computing to chaos theory. He could tell you about it, but THAT would NOT be a \"length-limited\" conversation!",
    "location": {
      "address": "2712 Broadway St",
      "postalCode": "CA 94115",
      "city": "San Francisco",
      "countryCode": "US",
      "region": "California"
    },
    "profiles": [
      {
        "network": "Twitter",
        "username": "neutralthoughts",
        "url": ""
      },
      {
        "network": "SoundCloud",
        "username": "dandymusicnl",
        "url": "https://soundcloud.com/dandymusicnl"
      }
    ]
  }
|]

basicsParsed :: Basics
basicsParsed = Basics
  { name = Just "test"
  , label = Just "Programmer"
  , picture = Just ""
  , email = Just "test4@test.com"
  , phone = Just "(912) 555-4321"
  , website = Just "http://richardhendricks.com"
  , summary = Just "Richard hails from Tulsa. He has earned degrees from the University of Oklahoma and Stanford. (Go Sooners and Cardinals!) Before starting Pied Piper, he worked for Hooli as a part time software developer. While his work focuses on applied information theory, mostly optimizing lossless compression schema of both the length-limited and adaptive variants, his non-work interests range widely, everything from quantum computing to chaos theory. He could tell you about it, but THAT would NOT be a \"length-limited\" conversation!"
  , location = Just addressParsed
  , profiles = [profileParsed
               , Profile {network = Just "SoundCloud"
                         , username = Just "dandymusicnl"
                         , url = Just "https://soundcloud.com/dandymusicnl"
                         }
               ]
  }

workJSON :: ByteString
workJSON = [here|
{"company": "Pied Piper",
 "position": "CEO/President",
 "website": "http://piedpiper.com",
 "startDate": "2013-12-01",
 "endDate": "2014-12-01",
 "summary": "Pied Piper is a multi-platform technology based on a proprietary universal compression algorithm that has consistently fielded high Weisman Scores that are not merely competitive, but approach the theoretical limit of lossless compression.",
 "highlights": [
   "Build an algorithm for artist to detect if their music was violating copy right infringement laws",
   "Successfully won Techcrunch Disrupt",
   "Optimized an algorithm that holds the current world record for Weisman Scores"
 ]
}
|]

workParsed :: Work
workParsed = Work $ Organization
  {orgName = Just "Pied Piper"
  , orgPosition = Just "CEO/President"
  , orgSite = Just "http://piedpiper.com"
  , orgStartDate = Just $ UTCTime (fromGregorian 2013 12 01) 0
  , orgEndDate = Just $ UTCTime (fromGregorian 2014 12 01) 0
  , orgSummary = Just "Pied Piper is a multi-platform technology based on a proprietary universal compression algorithm that has consistently fielded high Weisman Scores that are not merely competitive, but approach the theoretical limit of lossless compression."
  , orgHighlights = ["Build an algorithm for artist to detect if their music was violating copy right infringement laws","Successfully won Techcrunch Disrupt","Optimized an algorithm that holds the current world record for Weisman Scores"]
  }

volunteerJSON :: ByteString
volunteerJSON = [here|
    {
      "organization": "CoderDojo",
      "position": "Teacher",
      "website": "http://coderdojo.com/",
      "startDate": "2012-01-01",
      "endDate": "2013-01-01",
      "summary": "Global movement of free coding clubs for young people.",
      "highlights": [
        "Awarded 'Teacher of the Month'"
      ]
    }
|]

volunteerParsed :: Volunteer
volunteerParsed = Volunteer $ Organization
  { orgName = Just "CoderDojo"
  , orgPosition = Just "Teacher"
  , orgSite = Just "http://coderdojo.com/"
  , orgStartDate = Just $ UTCTime (fromGregorian 2012 1 1) 0
  , orgEndDate = Just $ UTCTime (fromGregorian 2013 1 1) 0
  , orgSummary = Just "Global movement of free coding clubs for young people."
  , orgHighlights = ["Awarded 'Teacher of the Month'"]
  }

educationJSON :: ByteString
educationJSON = [here|
{
      "institution": "University of Oklahoma",
      "area": "Information Technology",
      "studyType": "Bachelor",
      "startDate": "2011-06-01",
      "endDate": "2014-01-01",
      "gpa": "4.0",
      "courses": [
        "DB1101 - Basic SQL",
        "CS2011 - Java Introduction"
      ]
    }
|]

educationParsed :: Education
educationParsed = Education
  { institution = Just "University of Oklahoma"
  , area = Just "Information Technology"
  , studyType = Just "Bachelor"
  , startDate = Just $ UTCTime (fromGregorian 2011 6 1) 0
  , endDate = Just $ UTCTime (fromGregorian 2014 1 1) 0
  , gpa = Just "4.0"
  , courses = ["DB1101 - Basic SQL","CS2011 - Java Introduction"]}

awardJSON :: ByteString
awardJSON = [here|
    {
      "title": "Digital Compression Pioneer Award",
      "date": "2014-11-01",
      "awarder": "Techcrunch",
      "summary": "There is no spoon."
    }
|]

awardParsed :: Award
awardParsed = Award
  { title = Just "Digital Compression Pioneer Award"
  , date = Just $ UTCTime (fromGregorian 2014 11 1) 0
  , awarder = Just "Techcrunch"
  , awardSummary = Just "There is no spoon."
  }

publicationJSON :: ByteString
publicationJSON = [here|
    {
      "name": "Video compression for 3d media",
      "publisher": "Hooli",
      "releaseDate": "2014-10-01",
      "website": "http://en.wikipedia.org/wiki/Silicon_Valley_(TV_series)",
      "summary": "Innovative middle-out compression algorithm that changes the way we store data."
    }
|]

publicationParsed :: Publication
publicationParsed = Publication
  { pubName = Just "Video compression for 3d media"
  , publisher = Just "Hooli"
  , pubReleaseDate = Just $ UTCTime (fromGregorian 2014 10 1) 0
  , pubSite = Just "http://en.wikipedia.org/wiki/Silicon_Valley_(TV_series)"
  , pubSummary = Just "Innovative middle-out compression algorithm that changes the way we store data."
  }

skillJSON :: ByteString
skillJSON = [here|
    {
      "name": "Web Development",
      "level": "Master",
      "keywords": [
        "HTML",
        "CSS",
        "Javascript"
      ]
    }
|]

skillParsed :: Skill
skillParsed = Skill
  { skillName = Just "Web Development"
  , skillLevel = Just "Master"
  , skillKeywords = ["HTML","CSS","Javascript"]
  }

languageJSON :: ByteString
languageJSON = [here|
    {
      "language": "English",
      "fluency": "Native speaker"
    }
|]

languageParsed :: Language
languageParsed = Language
  { language = Just "English"
  , fluency = Just "Native speaker"}

interestJSON :: ByteString
interestJSON = [here|
    {
      "name": "Wildlife",
      "keywords": [
        "Ferrets",
        "Unicorns"
      ]
    }
|]

interestParsed :: Interest
interestParsed = Interest {interestName = Just "Wildlife", interestKeywords = ["Ferrets","Unicorns"]}

referenceJSON :: ByteString
referenceJSON = [here|
    {
      "name": "Erlich Bachman",
      "reference": "It is my pleasure to recommend Richard, his performance working as a consultant for Main St. Company proved that he will be a valuable addition to any company."
    }
|]

referenceParsed :: Reference
referenceParsed = Reference
  { refName = Just "Erlich Bachman"
  , refReference = Just "It is my pleasure to recommend Richard, his performance working as a consultant for Main St. Company proved that he will be a valuable addition to any company."
  }

resumeJSON :: ByteString
resumeJSON = [hereFile|test/resume.json|]

resumeParsed :: Resume
resumeParsed = Resume b w v e a p s l i r m
  where
    b = Just basicsParsed
    w = [workParsed]
    v = [volunteerParsed]
    e = [educationParsed]
    a = [awardParsed]
    p = [publicationParsed]
    s = [skillParsed, Skill {skillName = Just "Compression", skillLevel = Just "Master", skillKeywords = ["Mpeg","MP4","GIF"]}]
    l = [languageParsed]
    i = [interestParsed]
    r = [referenceParsed]
    m = Nothing

main :: IO ()
main = hspec spec

verifyJSON :: (ToJSON a, FromJSON a, Eq a, Show a) => ByteString -> a -> Spec
verifyJSON json parsed = do
  it "can be parsed from JSON" $
    decode json `shouldBe` Just parsed
  it "can be round-tripped" $
    decode (encode parsed) `shouldBe` Just parsed

spec :: Spec
spec = do
  describe "Address" $
    verifyJSON addressJSON addressParsed
  describe "Basics" $
    verifyJSON basicsJSON basicsParsed
  describe "Profile" $
    verifyJSON profileJSON profileParsed
  describe "Work" $
    verifyJSON workJSON workParsed
  describe "Volunteer" $
    verifyJSON volunteerJSON volunteerParsed
  describe "Education" $
    verifyJSON educationJSON educationParsed
  describe "Award" $
    verifyJSON awardJSON awardParsed
  describe "Publication" $
    verifyJSON publicationJSON publicationParsed
  describe "Skill" $
    verifyJSON skillJSON skillParsed
  describe "Interest" $
    verifyJSON interestJSON interestParsed
  describe "Reference" $
    verifyJSON referenceJSON referenceParsed
  describe "Resume" $ do
    verifyJSON resumeJSON resumeParsed
