module OpenApi3.Schema.SecurityRequirement where

import Prelude
import Data.Either (Either, note)
-- import Data.Map (Map)
import Data.Traversable (traverse)
import Data.Newtype (class Newtype, unwrap)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson, toObject)

import OpenApi3.Schema.Map (Map(..))

newtype SecurityRequirement = SecurityRequirement (Map String (Array String))
derive instance securityRequirementNewtype :: Newtype SecurityRequirement _
derive newtype instance securityrequirementShow :: Show SecurityRequirement

instance securityRequirementDecodeJson :: DecodeJson SecurityRequirement where
  decodeJson j = SecurityRequirement <$> decodeJson j

instance securityRequirementEncodeJson :: EncodeJson SecurityRequirement where
  encodeJson = unwrap >>> encodeJson

-- Security Requirement Object
-- Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.

-- Security Requirement Objects that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.

-- When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request.

-- Patterned Fields
-- Field Pattern Type Description
-- {name} [string] Each name MUST correspond to a security scheme which is declared in the Security Schemes under the Components Object. If the security scheme is of type "oauth2" or "openIdConnect", then the value is a list of scope names required for the execution, and the list MAY be empty if authorization does not require a specified scope. For other security scheme types, the array MUST be empty.
