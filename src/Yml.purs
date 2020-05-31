module Yml where

import Prelude ((<$>), (<=<))

import Data.Either (Either)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.Yaml (parseFromYaml, printToYaml)

decodeYml :: forall a. DecodeJson a => String -> Either String a
decodeYml = decodeJson <=< parseFromYaml

encodeYml :: forall a. EncodeJson a => a -> String
encodeYml = printToYaml <$> encodeJson
