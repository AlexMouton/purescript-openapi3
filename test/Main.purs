module Test.Main where

import Prelude (Unit, bind, discard, pure, show, unit, ($))
import Type.Proxy (Proxy(..))

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff (Aff, launchAff_)
import Effect.Console (log)

import Data.Argonaut (class DecodeJson, class EncodeJson)
import Data.Either (Either(..), isRight)
import Data.Identity (Identity)

import Node.Encoding (Encoding(..)) as N
import Node.FS.Aff (readTextFile)

import Yml (decodeYml)

import OpenApi3.Schema (OpenApi, Callback, Components, Contact, Encoding, Example, ExternalDocumentation, Header, Info, License, MediaType, OAuthFlow, Operation, Parameter, PathItem, Paths, RequestBody, Response, Responses, Schema, SecurityScheme, Server)
import OpenApi3.Schema.Reference (Reference)
import OpenApi3.Schema.Refable (Refable)
import OpenApi3.Schema.SecurityRequirement (SecurityRequirement)

import Test.Spec (Spec, SpecT, describe, it, itOnly, class FocusWarning)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

type  E a = Either String a
-- type  Es a = Array (Either String a)

ingest :: forall a. EncodeJson a => DecodeJson a => String -> Aff (Either String a)
ingest s = do
  file <- readTextFile N.UTF8 s
  let yml = decodeYml file :: Either String a
  -- log s
  -- log $ show $ encodeYml <$> yml
  pure yml

intestestImpl :: forall a. EncodeJson a => DecodeJson a => (String -> Aff Unit -> SpecT Aff Unit Identity Unit) -> (Proxy a) -> String -> Spec Unit
intestestImpl it _ file = do
  describe file do
    it "ingests" do
      res :: E a <- ingest file
      case res of
        Left l -> liftEffect $ log $ show l
        _ -> pure unit
      isRight res `shouldEqual` true

intestest :: forall a. EncodeJson a => DecodeJson a => Proxy a -> String -> SpecT Aff Unit Identity Unit
intestest = intestestImpl it

intestestOnly :: forall a. FocusWarning => EncodeJson a => DecodeJson a => Proxy a -> String -> SpecT Aff Unit Identity Unit
intestestOnly = intestestImpl itOnly

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "OpenApi" do
    intestest (Proxy :: Proxy OpenApi) "./examples/openapi/uspto.yaml"

  describe "Callback" do
    intestest (Proxy :: Proxy Callback) "./examples/callback/example.yaml"
    intestest (Proxy :: Proxy Callback) "./examples/callback/transaction.yaml"

  describe "Components" do
    intestest (Proxy :: Proxy Components) "./examples/components/components.yaml"
    intestest (Proxy :: Proxy Components) "./examples/components/uspto.yaml"

  describe "Contact" do
    intestest (Proxy :: Proxy Contact)  "./examples/contact/example.yaml"

  describe "Encoding" do
    intestest (Proxy :: Proxy Encoding)  "./examples/encoding/example.yaml"

  describe "Example" do
    intestest (Proxy :: Proxy Example)  "./examples/example/parameter.yaml"
    intestest (Proxy :: Proxy Example)  "./examples/example/requestbody.yaml"
    intestest (Proxy :: Proxy Example)  "./examples/example/response.yaml"

  describe "ExternalDocumentation" do
    intestest (Proxy :: Proxy ExternalDocumentation)  "./examples/externaldocumentation/example.yaml"

  describe "Header" do
    intestest (Proxy :: Proxy Header)  "./examples/header/example.yaml"

  describe "Info" do
    intestest (Proxy :: Proxy Info)  "./examples/info/example.yaml"
    intestest (Proxy :: Proxy Info)  "./examples/info/uspto.yaml"

  describe "License" do
    intestest (Proxy :: Proxy License)  "./examples/license/example.yaml"

  describe "MediaType" do
    intestest (Proxy :: Proxy MediaType)  "./examples/mediatype/example.yaml"

  describe "OAuthFlow" do
    intestest (Proxy :: Proxy OAuthFlow)  "./examples/oauthflow/authorizationCode.yaml"
    intestest (Proxy :: Proxy OAuthFlow)  "./examples/oauthflow/implicit.yaml"

  describe "Operation" do
    intestest (Proxy :: Proxy Operation)   "./examples/operation/example.yaml"

  describe "Parameter" do
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/skip.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/operation.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/complex.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/freeform.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/integerArray.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/optionalString.yaml"
    intestest (Proxy :: Proxy Parameter) "./examples/parameter/string.yaml"

  describe "PathItem" do
    intestest (Proxy :: Proxy PathItem)  "./examples/pathitem/example.yaml"

  describe "Paths" do
    intestest (Proxy :: Proxy Paths)  "./examples/paths/example.yaml"
    intestest (Proxy :: Proxy Paths)  "./examples/paths/uspto.yaml"

  describe "Reference" do
    intestest (Proxy :: Proxy Reference) "./examples/reference/doc.yaml"
    intestest (Proxy :: Proxy Reference) "./examples/reference/embeded.yaml"
    intestest (Proxy :: Proxy Reference) "./examples/reference/local.yaml"

  describe "Refable" do
    intestest (Proxy  :: Proxy (Refable Schema)) "./examples/schema/integer.yaml"
    intestest (Proxy  :: Proxy (Refable Schema)) "./examples/reference/local.yaml"
    intestest (Proxy  :: Proxy (Refable Schema)) "./examples/reference/doc.yaml"
    intestest (Proxy  :: Proxy (Refable Schema)) "./examples/reference/embeded.yaml"

  describe "RequestBody" do
    intestest (Proxy :: Proxy RequestBody)  "./examples/requestbody/arraystring.yaml"
    intestest (Proxy :: Proxy RequestBody)  "./examples/requestbody/referenced.yaml"

  describe "Response" do
    intestest (Proxy :: Proxy Response) "./examples/response/array.yaml"
    intestest (Proxy :: Proxy Response) "./examples/response/nil.yaml"
    intestest (Proxy :: Proxy Response) "./examples/response/string.yaml"
    intestest (Proxy :: Proxy Response) "./examples/response/textheaders.yaml"

  describe "Responses" do
    intestest (Proxy :: Proxy Responses)  "./examples/responses/example.yaml"

  describe "Schema" do
    intestest (Proxy :: Proxy Schema) "./examples/schema/int32.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/integer.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/additional.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/additionalref.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/errormodel.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/extendederrormodel.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/modelexample.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/cat.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/dog.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/pet.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/primitive.yaml"
    intestest (Proxy :: Proxy Schema) "./examples/schema/simple.yaml"

  describe "SecurityRequirement" do
    intestest (Proxy :: Proxy SecurityRequirement) "./examples/securityrequirement/apikey.yaml"
    intestest (Proxy :: Proxy SecurityRequirement) "./examples/securityrequirement/oauth2.yaml"
  -- has an array of SR? , "./examples/securityrequirement/oauth2optional.yaml"

  describe "SecurityScheme" do
    intestest (Proxy :: Proxy SecurityScheme)  "./examples/securityscheme/apikey.yaml"
    intestest (Proxy :: Proxy SecurityScheme)  "./examples/securityscheme/oauth2.yaml"

  describe "Server Array" do
    intestest (Proxy :: Proxy (Array Server))  "./examples/server/multiple.yaml"

  describe "Server" do
    intestest (Proxy :: Proxy Server) "./examples/server/single.yaml"
    intestest (Proxy :: Proxy Server) "./examples/server/variables.yaml"

  pure unit


