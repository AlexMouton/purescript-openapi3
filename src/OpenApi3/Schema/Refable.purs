module OpenApi3.Schema.Refable where

import Prelude

import Data.Either (Either(..), choose)

import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)

import OpenApi3.Schema.Reference (Reference)

data Refable a = Refable (Either Reference a)
instance refableShow :: Show a => Show (Refable a) where
  show (Refable e) = "(Refable " <> show e <> ")"

instance refableDecodeJson :: (DecodeJson a) => DecodeJson (Refable a) where
  decodeJson j =
    let esr = (decodeJson j :: Either String Reference) in
    let esa = (decodeJson j :: Either String a) in
    Refable <$> choose esr esa

instance refableEncodeJson :: (EncodeJson a) => EncodeJson (Refable a) where
  encodeJson (Refable (Left r)) = encodeJson r
  encodeJson (Refable (Right a)) = encodeJson a

