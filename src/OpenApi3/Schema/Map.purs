module OpenApi3.Schema.Map where

import Prelude

import Data.Argonaut (Json, class EncodeJson, class DecodeJson, encodeJson, decodeJson, toObject, getFieldOptional, getField)
import Data.Either (Either, note)
import Data.FoldableWithIndex (foldlWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Map (Map, insert) as M
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype, unwrap)
import Data.Traversable (traverse)
import Foreign.Object (Object)

newtype Map a b = Map (M.Map a b)
derive instance responseNewtype :: Newtype (Map a b) _
derive instance responseGeneric :: Generic (Map a b) _

instance  mapShow :: (Show a, Show b) => Show (Map a b) where
    show = unwrap >>> show

instance mapDecodeJson :: (DecodeJson a) => DecodeJson (Map String a) where
  decodeJson j = do
    o :: Object a <- decodeJson j
    pure $ objectToMap o

instance mapEncodeJson :: (EncodeJson a) => EncodeJson (Map String a) where
  encodeJson (Map m) = encodeJson m

objectToMap :: forall a. Object a -> Map String a
objectToMap = Map <<< objectToMap'

objectToMap' :: forall a. Object a -> M.Map String a
objectToMap' = foldlWithIndex (\i b a -> M.insert i a b) mempty
