module OpenApi3.Schema.Reference where

import Prelude

import Data.Either (note)
import Data.Newtype (class Newtype)

import Data.Argonaut (class DecodeJson, class EncodeJson, encodeJson, getField, toObject)

-- Reference Object
-- A simple object to allow referencing other components in the specification, internally and externally.

-- The Reference Object is defined by JSON Reference and follows the same structure, behavior and rules.

-- For this specification, reference resolution is accomplished as defined by the JSON Reference specification and not by the JSON Schema specification.

-- Fixed Fields
newtype Reference = Reference
  { "$ref" :: String -- REQUIRED. The reference string.
  }

derive instance referenceNewtype :: Newtype Reference _
derive newtype instance referenceShow :: Show Reference

instance referenceDecodeJson :: DecodeJson Reference where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    ref <- getField o "$ref"
    pure $ Reference { "$ref": ref }

instance referenceEncodeJson :: EncodeJson Reference where
  encodeJson (Reference c) = encodeJson c

