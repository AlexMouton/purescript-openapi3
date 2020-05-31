module OpenApi3.Schema where

import Prelude
import Data.Maybe (Maybe)
import Data.Either (note)
import Data.Generic.Rep (class Generic)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, encodeJson, decodeJson, getField, getFieldOptional, toObject)
import Data.Newtype (class Newtype, unwrap, wrap)
import Foreign.Object (Object)
import OpenApi3.Schema.Refable (Refable)
import OpenApi3.Schema.SecurityRequirement (SecurityRequirement)
import OpenApi3.Schema.Map (Map, objectToMap)

-- Callback Object
-- A map of possible out-of band callbacks related to the parent operation. Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the path item object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.

newtype Callback = Callback (Map String PathItem)
derive instance callbackNewtype :: Newtype Callback _
derive instance callbackGeneric :: Generic Callback _
-- derive newtype instance callbackShow :: Show Callback

instance callbackEncodeJson :: EncodeJson Callback where
  encodeJson (Callback c) = encodeJson c

instance callbackDecodeJson :: DecodeJson Callback where
  decodeJson c = Callback <$> decodeJson c

-- Patterned Fields
-- Field Pattern Type Description
-- {expression} Path Item Object A Path Item Object used to define a callback request and expected responses. A complete example is available.
-- This object MAY be extended with Specification Extensions.

-- Key Expression
-- The key that identifies the Path Item Object is a runtime expression that can be evaluated in the context of a runtime HTTP request/response to identify the URL to be used for the callback request. A simple example might be $request.body#/url. However, using a runtime expression the complete HTTP message can be accessed. This includes accessing any part of a body that a JSON Pointer RFC6901 can reference.

-- For example, given the following HTTP request:

-- POST /subscribe/myevent?queryUrl=http://clientdomain.com/stillrunning HTTP/1.1
-- Host: example.org
-- Content-Type: application/json
-- Content-Length: 187

-- {
--   "failedUrl" : "http://clientdomain.com/failed",
--   "successUrls" : [
--     "http://clientdomain.com/fast",
--     "http://clientdomain.com/medium",
--     "http://clientdomain.com/slow"
--   ]
-- }

-- 201 Created
-- Location: http://example.org/subscription/1
-- The following examples show how the various expressions evaluate, assuming the callback operation has a path parameter named eventType and a query parameter named queryUrl.

-- Expression Value
-- $url http://example.org/subscribe/myevent?queryUrl=http://clientdomain.com/stillrunning
-- $method POST
-- $request.path.eventType myevent
-- $request.query.queryUrl http://clientdomain.com/stillrunning
-- $request.header.content-Type application/json
-- $request.body#/failedUrl http://clientdomain.com/failed
-- $request.body#/successUrls/2 http://clientdomain.com/medium
-- $response.header.Location http://example.org/subscription/1



-- Components Object
-- Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.

-- Fixed Fields
newtype Components = Components
  { schemas :: Maybe (Map String (Refable Schema)) -- An object to hold reusable Schema Objects.
  , responses :: Maybe (Map String (Refable Response)) -- An object to hold reusable Response Objects.
  , parameters :: Maybe (Map String (Refable Parameter)) -- An object to hold reusable Parameter Objects.
  , examples :: Maybe (Map String (Refable Example)) -- An object to hold reusable Example Objects.
  , requestBodies :: Maybe (Map String (Refable RequestBody)) -- An object to hold reusable Request Body Objects.
  , headers :: Maybe (Map String (Refable Header)) -- An object to hold reusable Header Objects.
  , securitySchemes :: Maybe (Map String (Refable SecurityScheme)) -- An object to hold reusable Security Scheme Objects.
  , links :: Maybe (Map String (Refable Link)) -- An object to hold reusable Link Objects.
  , callbacks :: Maybe (Map String (Refable Callback)) -- An object to hold reusable Callback Objects.
  }
derive instance componentsNewtype :: Newtype Components _
derive instance componentsGeneric :: Generic Components _
-- derive newtype instance componentsShow :: Show Components

instance componentsDecodeJson :: DecodeJson Components where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    schemas <- getFieldOptional o "schemas"
    responses <- getFieldOptional o "responses"
    parameters <- getFieldOptional o "parameters"
    examples <- getFieldOptional o "examples"
    requestBodies <- getFieldOptional o "requestBodies"
    headers <- getFieldOptional o "headers"
    securitySchemes <- getFieldOptional o "securitySchemes"
    links <- getFieldOptional o "links"
    callbacks <- getFieldOptional o "callbacks"

    pure $ Components { schemas, responses, parameters, examples, requestBodies, headers, securitySchemes, links, callbacks }

instance componentsEncodeJson :: EncodeJson Components where
  encodeJson = unwrap >>> encodeJson


-- This object MAY be extended with Specification Extensions.

-- All the fixed fields declared above are objects that MUST use keys that match the regular expression: ^[a-zA-Z0-9\.\-_]+$.

-- Field Name Examples:

-- User
-- User_1
-- User_Name
-- user-name
-- my.org.User

-- Contact Object
-- Contact information for the exposed API.

-- Fixed Fields
newtype Contact = Contact
  { name :: Maybe String -- The identifying name of the contact person/organization.
  , url :: Maybe String -- The URL pointing to the contact information. MUST be in the format of a URL.
  , email :: Maybe String -- The email address of the contact person/organization. MUST be in the format of an email address.
  }

-- This object MAY be extended with Specification Extensions.
derive instance contactNewtype :: Newtype Contact _
derive instance contactGeneric :: Generic Contact _
-- derive newtype instance contactShow :: Show Contact

instance contactDecodeJson :: DecodeJson Contact where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    name <- getFieldOptional o "name"
    url <- getFieldOptional o "url"
    email <- getFieldOptional o "email"

    pure $ Contact { name, url, email }

instance contactEncodeJson :: EncodeJson Contact where
  encodeJson = unwrap >>> encodeJson

-- When request bodies or response payloads may be one of a number of different schemas, a discriminator object can be used to aid in serialization, deserialization, and validation. The discriminator is a specific object in a schema which is used to inform the consumer of the specification of an alternative schema based on the value associated with it.

-- When using the discriminator, inline schemas will not be considered.

-- Fixed Fields
newtype Discriminator = Discriminator
  { propertyName :: String -- REQUIRED. The name of the property in the payload that will hold the discriminator value.
  , mapping :: Maybe (Map String String) -- An object to hold mappings between payload values and schema names or references.
  }
derive instance discriminatorNewtype :: Newtype Discriminator _
derive instance discrimlGeneric :: Generic Discriminator _
-- derive newtype instance discrimShow :: Show Discriminator

instance discriminatorDecodeJson :: DecodeJson Discriminator where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    propertyName <- getField o "propertyName"
    mapping <- getFieldOptional o "mapping"

    pure $ Discriminator { propertyName, mapping }

instance discriminatorlEncodeJson :: EncodeJson Discriminator where
  encodeJson = unwrap >>> encodeJson


-- The discriminator object is legal only when using one of the composite keywords oneOf, anyOf, allOf.

-- In OAS 3.0, a response payload MAY be described to be exactly one of any number of types:

-- MyResponseType:
--   oneOf:
--   - $ref: '#/components/schemas/Cat'
--   - $ref: '#/components/schemas/Dog'
--   - $ref: '#/components/schemas/Lizard'
-- which means the payload MUST, by validation, match exactly one of the schemas described by Cat, Dog, or Lizard. In this case, a discriminator MAY act as a "hint" to shortcut validation and selection of the matching schema which may be a costly operation, depending on the complexity of the schema. We can then describe exactly which field tells us which schema to use:

-- MyResponseType:
--   oneOf:
--   - $ref: '#/components/schemas/Cat'
--   - $ref: '#/components/schemas/Dog'
--   - $ref: '#/components/schemas/Lizard'
--   discriminator:
--     propertyName: petType
-- The expectation now is that a property with name petType MUST be present in the response payload, and the value will correspond to the name of a schema defined in the OAS document. Thus the response payload:

-- {
--   "id": 12345,
--   "petType": "Cat"
-- }
-- Will indicate that the Cat schema be used in conjunction with this payload.

-- In scenarios where the value of the discriminator field does not match the schema name or implicit mapping is not possible, an optional mapping definition MAY be used:

-- MyResponseType:
--   oneOf:
--   - $ref: '#/components/schemas/Cat'
--   - $ref: '#/components/schemas/Dog'
--   - $ref: '#/components/schemas/Lizard'
--   - $ref: 'https://gigantic-server.com/schemas/Monster/schema.json'
--   discriminator:
--     propertyName: petType
--     mapping:
--       dog: '#/components/schemas/Dog'
--       monster: 'https://gigantic-server.com/schemas/Monster/schema.json'
-- Here the discriminator value of dog will map to the schema #/components/schemas/Dog, rather than the default (implicit) value of Dog. If the discriminator value does not match an implicit or explicit mapping, no schema can be determined and validation SHOULD fail. Mapping keys MUST be string values, but tooling MAY convert response values to strings for comparison.

-- When used in conjunction with the anyOf construct, the use of the discriminator can avoid ambiguity where multiple schemas may satisfy a single payload.

-- In both the oneOf and anyOf use cases, all possible schemas MUST be listed explicitly. To avoid redundancy, the discriminator MAY be added to a parent schema definition, and all schemas comprising the parent schema in an allOf construct may be used as an alternate schema.

-- For example:

-- components:
--   schemas:
--     Pet:
--       type: object
--       required:
--       - petType
--       properties:
--         petType:
--           type: string
--       discriminator:
--         propertyName: petType
--         mapping:
--           dog: Dog
--     Cat:
--       allOf:
--       - $ref: '#/components/schemas/Pet'
--       - type: object
--         # all other properties specific to a `Cat`
--         properties:
--           name:
--             type: string
--     Dog:
--       allOf:
--       - $ref: '#/components/schemas/Pet'
--       - type: object
--         # all other properties specific to a `Dog`
--         properties:
--           bark:
--             type: string
--     Lizard:
--       allOf:
--       - $ref: '#/components/schemas/Pet'
--       - type: object
--         # all other properties specific to a `Lizard`
--         properties:
--           lovesRocks:
--             type: booleanean
-- a payload like this:

-- {
--   "petType": "Cat",
--   "name": "misty"
-- }
-- will indicate that the Cat schema be used. Likewise this schema:

-- {
--   "petType": "dog",
--   "bark": "soft"
-- }
-- will map to Dog because of the definition in the mappings element.


-- Example Object
-- Fixed Fields
newtype Example = Example
  { summary :: Maybe String -- Short description for the example.
  , description :: Maybe String -- Long description for the example. CommonMark syntax MAY be used for rich text representation.
  , value :: Maybe String -- Any Embedded literal example. The value field and externalValue field are mutually exclusive. To represent examples of media types that cannot naturally represented in JSON or YAML, use a string value to contain the example, escaping where necessary.
  , externalValue :: Maybe String -- A URL that points to the literal example. This provides the capability to reference examples that cannot easily be included in JSON or YAML documents. The value field and externalValue field are mutually exclusive.
}
-- This object MAY be extended with Specification Extensions.
derive instance exampleNewtype :: Newtype Example _
derive instance examplGeneric :: Generic Example _
-- derive newtype instance exampleShow :: Show Example

instance exampleDecodeJson :: DecodeJson Example where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    summary <- getFieldOptional o "summary"
    description <- getFieldOptional o "description"
    value <- getFieldOptional o "value"
    externalValue <- getFieldOptional o "externalValue"

    pure $ Example { summary, description, value, externalValue }

instance examplelEncodeJson :: EncodeJson Example where
  encodeJson = unwrap >>> encodeJson


-- In all cases, the example value is expected to be compatible with the type schema of its associated value. Tooling implementations MAY choose to validate compatibility automatically, and reject the example value(s) if incompatible.

-- External Documentation Object
-- Allows referencing an external resource for extended documentation.

-- Fixed Fields
newtype ExternalDocumentation = ExternalDocumentation
  { description :: Maybe String -- A short description of the target documentation. CommonMark syntax MAY be used for rich text representation.
  , url :: String -- REQUIRED. The URL for the target documentation. Value MUST be in the format of a URL.
}
-- This object MAY be extended with Specification Extensions.
derive instance externalDocumentationNewtype :: Newtype ExternalDocumentation _
derive instance externalDocumentationGeneric :: Generic ExternalDocumentation _
-- derive newtype instance externaldocumentationShow :: Show ExternalDocumentation

instance externalDocumentationDecodeJson :: DecodeJson ExternalDocumentation where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    description <- getFieldOptional o "description"
    url <- getField o "url"

    pure $ ExternalDocumentation { description, url }

instance externalDocumentationEncodeJson :: EncodeJson ExternalDocumentation where
  encodeJson = unwrap >>> encodeJson


-- Header Object
-- The Header Object follows the structure of the Parameter Object with the following changes:

-- name MUST NOT be specified, it is given in the corresponding headers map.
-- in MUST NOT be specified, it is implicitly in header.
-- All traits that are affected by the location MUST be applicable to a location of header (for example, style).

newtype Header = Header
  {
  -- If in is "path", the name field MUST correspond to a template expression occurring within the path field in the Paths Object. See Path Templating for further information.
  -- If in is "header" and the name field is "Accept", "Content-Type" or "Authorization", the parameter definition SHALL be ignored.
  -- For all other cases, the name corresponds to the parameter name used by the in property.
    description :: Maybe String -- A brief description of the parameter. This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
  , required :: Maybe Boolean -- Determines whether this parameter is mandatory. If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false.
  , deprecated :: Maybe Boolean -- Specifies that a parameter is deprecated and SHOULD be transitioned out of usage. Default value is false.
  , allowEmptyValue :: Maybe Boolean -- Sets the ability to pass empty-valued parameters. This is valid only for query parameters and allows sending a parameter with an empty value. Default value is false. If style is used, and if behavior is n/a (cannot be serialized), the value of allowEmptyValue SHALL be ignored. Use of this property is NOT RECOMMENDED, as it is likely to be removed in a later revision.
      -- The rules for serialization of the parameter are specified in one of two ways. For simpler scenarios, a schema and style can describe the structure and syntax of the parameter.
  , style :: Maybe String -- Describes how the parameter value will be serialized depending on the type of the parameter value. Default values (based on value of in): for query - form; for path - simple; for header - simple; for cookie - form.
  , explode :: Maybe Boolean -- When this is true, parameter values of type array or object generate separate parameters for each value of the array or key-value pair of the map. For other types of parameters this property has no effect. When style is form, the default value is true. For all other styles, the default value is false.
  , allowReserved :: Maybe Boolean -- Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. This property only applies to parameters with an in value of query. The default value is false.
  , schema :: Maybe (Refable Schema) -- The schema defining the type used for the parameter.
  , example :: Maybe Json -- Example of the parameter's potential value. The example SHOULD match the specified schema and encoding properties if present. The example field is mutually exclusive of the examples field. Furthermore, if referencing a schema that contains an example, the example value SHALL override the example provided by the schema. To represent examples of media types that cannot naturally be represented in JSON or YAML, a string value can contain the example with escaping where necessary.
  , examples :: Maybe (Map String (Refable Example)) -- Examples of the parameter's potential value. Each example SHOULD contain a value in the correct format as specified in the parameter encoding. The examples field is mutually exclusive of the example field. Furthermore, if referencing a schema that contains an example, the examples value SHALL override the example provided by the schema.
    -- For more complex scenarios, the content property can define the media type and schema of the parameter. A parameter MUST contain either a schema property, or a content property, but not both. When example or examples are provided in conjunction with the schema object, the example MUST follow the prescribed serialization strategy for the parameter.
  , content :: Maybe (Map String MediaType) -- A map containing the representations for the parameter. The key is the media type and the value describes it. The map MUST only contain one entry.
  }
derive instance headerNewtype :: Newtype Header _
derive instance headerGeneric :: Generic Header _
-- derive newtype instance headerShow :: Show Header

instance headerDecodeJson :: DecodeJson Header where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    description <- getFieldOptional o "description"
    required <- getFieldOptional o "required"
    deprecated <- getFieldOptional o "deprecated"
    allowEmptyValue <- getFieldOptional o "allowEmptyValue"
    style <- getFieldOptional o "style"
    explode <- getFieldOptional o "explode"
    allowReserved <- getFieldOptional o "allowReserved"
    schema <- getFieldOptional o "schema"
    example <- getFieldOptional o "example"
    examples <- getFieldOptional o "examples"
    content <- getFieldOptional o "content"

    pure $ Header { description, required, deprecated, allowEmptyValue, style, explode, allowReserved, schema, example, examples, content }

instance headerEncodeJson :: EncodeJson Header where
  encodeJson = unwrap >>> encodeJson

-- Info Object
-- The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience.

-- Fixed Fields
newtype Info = Info
  { title :: String -- REQUIRED. The title of the API.
  , description :: Maybe String -- A short description of the API. CommonMark syntax MAY be used for rich text representation.
  , termsOfService :: Maybe String -- A URL to the Terms of Service for the API. MUST be in the format of a URL.
  , contact :: Maybe Contact -- The contact information for the exposed API.
  , license :: Maybe License -- The license information for the exposed API.
  , version :: String -- REQUIRED. The version of the OpenAPI document (which is distinct from the OpenAPI Specification version or the API implementation version).
}
-- This object MAY be extended with Specification Extensions.
derive instance infoNewtype :: Newtype Info _
derive instance infoGeneric :: Generic Info _
-- derive newtype instance infoShow Json Show Info

instance infoDecodeJson :: DecodeJson Info where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    title <- getField o "title"
    description <- getFieldOptional o "description"
    termsOfService <- getFieldOptional o "termsOfService"
    contact <- getFieldOptional o "contact"
    license <- getFieldOptional o "license"
    version <- getField o "version"

    pure $ Info { title, description, termsOfService, contact, license, version }

instance infoEncodeJson :: EncodeJson Info where
  encodeJson = unwrap >>> encodeJson


-- License Object
-- License information for the exposed API.

-- Fixed Fields
newtype License = License
  { name :: String -- REQUIRED. The license name used for the API.
  , url :: Maybe String -- A URL to the license used for the API. MUST be in the format of a URL.
  }
-- This object MAY be extended with Specification Extensions.
derive instance licenseNewtype :: Newtype License _
derive instance licenselGeneric :: Generic License _
-- derive newtype instance licenseShow :: Show License

instance licenseDecodeJson :: DecodeJson License where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    name <- getField o "name"
    url <- getFieldOptional o "url"
    pure $ License { name, url }

instance licenseEncodeJson :: EncodeJson License where
  encodeJson = unwrap >>> encodeJson


-- Link Object
-- The Link object represents a possible design-time link for a response. The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.

-- Unlike dynamic links (i.e. links provided in the response payload), the OAS linking mechanism does not require link information in the runtime response.

-- For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation.

-- Fixed Fields
newtype Link = Link
  { operationRef :: Maybe String -- A relative or absolute URI reference to an OAS operation. This field is mutually exclusive of the operationId field, and MUST point to an Operation Object. Relative operationRef values MAY be used to locate an existing Operation Object in the OpenAPI definition.
  , operationId :: Maybe String -- The name of an existing, resolvable OAS operation, as defined with a unique operationId. This field is mutually exclusive of the operationRef field.
  , parameters :: Maybe (Map String Json) -- (Any | {expression}) -- A map representing parameters to pass to an operation as specified with operationId or identified via operationRef. The key is the parameter name to be used, whereas the value can be a constant or an expression to be evaluated and passed to the linked operation. The parameter name can be qualified using the parameter location [{in}.]{name} for operations that use the same parameter name in different locations (e.g. path.id).
  , requestBody :: Maybe Json -- Any | {expression} -- A literal value or {expression} to use as a request body when calling the target operation.
  , description :: Maybe String -- A description of the link. CommonMark syntax MAY be used for rich text representation.
  , server :: Maybe Server -- A server object to be used by the target operation.
}
-- This object MAY be extended with Specification Extensions.
derive instance linkNewtype :: Newtype Link _
derive instance linkGeneric :: Generic Link _
-- derive newtype instance linkShow :: Show Link

instance linkDecodeJson :: DecodeJson Link where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    operationRef <- getFieldOptional o "operationRef"
    operationId <- getFieldOptional o "operationId"
    parameters <- getFieldOptional o "parameters"
    requestBody <- getFieldOptional o "requestBody"
    description <- getFieldOptional o "description"
    server <- getFieldOptional o "server"
    pure $ Link { operationRef, operationId, parameters, requestBody, description, server }

instance linkEncodeJson :: EncodeJson Link where
  encodeJson = unwrap >>> encodeJson


-- A linked operation MUST be identified using either an operationRef or operationId. In the case of an operationId, it MUST be unique and resolved in the scope of the OAS document. Because of the potential for name clashes, the operationRef syntax is preferred for specifications with external references.

-- Examples
-- Computing a link from a request operation where the $request.path.id is used to pass a request parameter to the linked operation.

-- paths:
--   /users/{id}:
--     parameters:
--     - name: id
--       in: path
--       required: true
--       description: the user identifier, as userId
--       schema:
--         type: string
--     get:
--       responses:
--         '200':
--           description: the user being returned
--           content:
--             application/json:
--               schema:
--                 type: object
--                 properties:
--                   uuid: # the unique user id
--                     type: string
--                     format: uuid
--           links:
--             address:
--               # the target link operationId
--               operationId: getUserAddress
--               parameters:
--                 # get the `id` field from the request path parameter named `id`
--                 userId: $request.path.id
--   # the path item of the linked operation
--   /users/{userid}/address:
--     parameters:
--     - name: userid
--       in: path
--       required: true
--       description: the user identifier, as userId
--       schema:
--         type: string
--     # linked operation
--     get:
--       operationId: getUserAddress
--       responses:
--         '200':
--           description: the user's address
-- When a runtime expression fails to evaluate, no parameter value is passed to the target operation.

-- Values from the response body can be used to drive a linked operation.

-- links:
--   address:
--     operationId: getUserAddressByUUID
--     parameters:
--       # get the `uuid` field from the `uuid` field in the response body
--       userUuid: $response.body#/uuid
-- Clients follow all links at their discretion. Neither permissions, nor the capability to make a successful call to that link, is guaranteed solely by the existence of a relationship.

-- OperationRef Examples
-- As references to operationId MAY NOT be possible (the operationId is an optional field in an Operation Object), references MAY also be made through a relative operationRef:

-- links:
--   UserRepositories:
--     # returns array of '#/components/schemas/repository'
--     operationRef: '#/paths/~12.0~1repositories~1{username}/get'
--     parameters:
--       username: $response.body#/username
-- or an absolute operationRef:

-- links:
--   UserRepositories:
--     # returns array of '#/components/schemas/repository'
--     operationRef: 'https://na2.gigantic-server.com/#/paths/~12.0~1repositories~1{username}/get'
--     parameters:
--       username: $response.body#/username
-- Note that in the use of operationRef, the escaped forward-slash is necessary when using JSON references.

-- Runtime Expressions
-- Runtime expressions allow defining values based on information that will only be available within the HTTP message in an actual API call. This mechanism is used by Link Objects and Callback Objects.

-- The runtime expression is defined by the following ABNF syntax

--       expression = ( "$url" / "$method" / "$statusCode" / "$request." source / "$response." source )
--       source = ( header-reference / query-reference / path-reference / body-reference )
--       header-reference = "header." token
--       query-reference = "query." name
--       path-reference = "path." name
--       body-reference = "body" ["#" json-pointer ]
--       json-pointer    = *( "/" reference-token )
--       reference-token = *( unescaped / escaped )
--       unescaped       = %x00-2E / %x30-7D / %x7F-10FFFF
--          ; %x2F ('/') and %x7E ('~') are excluded from 'unescaped'
--       escaped         = "~" ( "0" / "1" )
--         ; representing '~' and '/', respectively
--       name = *( CHAR )
--       token = 1*tchar
--       tchar = "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "." /
--         "^" / "_" / "`" / "|" / "~" / DIGIT / ALPHA
-- Here, json-pointer is taken from RFC 6901, char from RFC 7159 and token from RFC 7230.

-- The name identifier is case-sensitive, whereas token is not.

-- The table below provides examples of runtime expressions and examples of their use in a value:

-- Examples
-- Source Location example expression notes
-- HTTP Method $method The allowable values for the $method will be those for the HTTP operation.
-- Requested media type $request.header.accept
-- Request parameter $request.path.id Request parameters MUST be declared in the parameters section of the parent operation or they cannot be evaluated. This includes request headers.
-- Request body property $request.body#/user/uuid In operations which accept payloads, references may be made to portions of the requestBody or the entire body.
-- Request URL $url
-- Response value $response.body#/status In operations which return payloads, references may be made to portions of the response body or the entire body.
-- Response header $response.header.Server Single header values only are available
-- Runtime expressions preserve the type of the referenced value. Expressions can be embedded into string values by surrounding the expression with {} curly braces.



-- Media Type Object
-- Each Media Type Object provides schema and examples for the media type identified by its key.

-- Fixed Fields
newtype MediaType = MediaType
  { schema :: Maybe (Refable Schema) -- The schema defining the content of the request, response, or parameter.
  , example :: Maybe Json -- Any -- Example of the media type. The example object SHOULD be in the correct format as specified by the media type. The example field is mutually exclusive of the examples field. Furthermore, if referencing a schema which contains an example, the example value SHALL override the example provided by the schema.
  , examples :: Maybe (Map String (Refable Example)) -- Examples of the media type. Each example object SHOULD match the media type and specified schema if present. The examples field is mutually exclusive of the example field. Furthermore, if referencing a schema which contains an example, the examples value SHALL override the example provided by the schema.
  , encoding :: Maybe (Map String Encoding) -- A map between a property name and its encoding information. The key, being the property name, MUST exist in the schema as a property. The encoding object SHALL only apply to requestBody objects when the media type is multipart or application/x-www-form-urlencoded.
}
-- This object MAY be extended with Specification Extensions.
derive instance mediaTypeVariableNewtype :: Newtype MediaType _
derive instance mediaTypeGeneric :: Generic MediaType _
-- derive newtype instance mediaTypeShow :: Show MediaType

instance mediaTypeDecodeJson :: DecodeJson MediaType where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    schema <- getFieldOptional o "schema"
    example <- getFieldOptional o "example"
    examples <- getFieldOptional o "examples"
    encoding <- getFieldOptional o "encoding"
    pure $ MediaType $ { schema, example, examples, encoding }

instance mediaTypeEncodeJson :: EncodeJson MediaType where
  encodeJson = unwrap >>> encodeJson

-- Encoding Object
-- A single encoding definition applied to a single schema property.

-- Fixed Fields
newtype Encoding = Encoding
  { contentType :: Maybe String -- The Content-Type for encoding a specific property. Default value depends on the property type: for string with format being binary – application/octet-stream; for other primitive types – text/plain; for object - application/json; for array – the default is defined based on the inner type. The value can be a specific media type (e.g. application/json), a wildcard media type (e.g. image/*), or a comma-separated list of the two types.
  , headers :: Maybe (Map String (Refable Header)) -- A map allowing additional information to be provided as headers, for example Content-Disposition. Content-Type is described separately and SHALL be ignored in this section. This property SHALL be ignored if the request body media type is not a multipart.
  , style :: Maybe String -- Describes how a specific property value will be serialized depending on its type. See Parameter Object for details on the style property. The behavior follows the same values as query parameters, including default values. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
  , explode :: Maybe Boolean -- When this is true, property values of type array or object generate separate parameters for each value of the array, or key-value-pair of the map. For other types of properties this property has no effect. When style is form, the default value is true. For all other styles, the default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
  , allowReserved :: Maybe Boolean -- Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. The default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded.
}
derive instance encodingNewtype :: Newtype Encoding _
derive instance encodignGeneric :: Generic Encoding _
-- derive newtype instance encodingShow :: Show Encoding

instance encodingDecodeJson :: DecodeJson Encoding where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    contentType <- getFieldOptional o "contentType"
    headers <- getFieldOptional o "headers"
    style <- getFieldOptional o "style"
    explode <- getFieldOptional o "explode"
    allowReserved <- getFieldOptional o "allowReserved"
    pure $ Encoding { contentType, headers, style, explode, allowReserved }

instance encodingEncodeJson :: EncodeJson Encoding where
  encodeJson (Encoding c)= encodeJson c

-- This object MAY be extended with Specification Extensions.


-- OAuth Flow Object
-- Configuration details for a supported OAuth Flow

-- Fixed Fields
newtype OAuthFlow = OAuthFlow
  { authorizationUrl :: String -- oauth2 ("implicit", "authorizationCode") -- REQUIRED. The authorization URL to be used for this flow. This MUST be in the form of a URL.
   -- TODO: This maybe not required? Changed test to include one
  , tokenUrl :: String -- oauth2 ("password", "clientCredentials", "authorizationCode") -- REQUIRED. The token URL to be used for this flow. This MUST be in the form of a URL.
  , refreshUrl :: Maybe String -- oauth2 -- The URL to be used for obtaining refresh tokens. This MUST be in the form of a URL.
  , scopes :: Map String String -- oauth2 -- REQUIRED. The available scopes for the OAuth2 security scheme. A map between the scope name and a short description for it. The map MAY be empty.
}
-- This object MAY be extended with Specification Extensions.
-- This object MAY be extended with Specification Extensions.
derive instance oAuthFlowNewtype :: Newtype OAuthFlow _
derive instance oauthflowGeneric :: Generic OAuthFlow _
-- derive newtype instance oauthflowlShow :: Show OAuthFlow

instance oauthflowDecodeJson :: DecodeJson OAuthFlow where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    authorizationUrl <- getField o "authorizationUrl"
    tokenUrl <- getField o "tokenUrl"
    refreshUrl <- getFieldOptional o "refreshUrl"
    scopes <- getField o "scopes"
    pure $ OAuthFlow $ { authorizationUrl, tokenUrl, refreshUrl, scopes }

instance oauthflowEncodeJson :: EncodeJson OAuthFlow where
  encodeJson = unwrap >>> encodeJson



-- OAuth Flows Object
-- Allows configuration of the supported OAuth Flows.

-- Fixed Fields
newtype OAuthFlows =  OAuthFlows
  { implicit :: Maybe OAuthFlow -- Configuration for the OAuth Implicit flow
  , password :: Maybe OAuthFlow -- Configuration for the OAuth Resource Owner Password flow
  , clientCredentials :: Maybe OAuthFlow -- Configuration for the OAuth Client Credentials flow. Previously called application in OpenAPI 2.0.
  , authorizationCode :: Maybe OAuthFlow -- Configuration for the OAuth Authorization Code flow. Previously called accessCode in OpenAPI 2.0.
}
-- This object MAY be extended with Specification Extensions.
derive instance oAuthFlowsNewtype :: Newtype OAuthFlows _
derive instance oauthflowsGeneric :: Generic OAuthFlows _
-- derive newtype instance oauthflowsShow :: Show OAuthFlows

instance oauthflowsDecodeJson :: DecodeJson OAuthFlows where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    implicit <- getFieldOptional o "implicit"
    password <- getFieldOptional o "password"
    clientCredentials <- getFieldOptional o "clientCredentials"
    authorizationCode <- getFieldOptional o "authorizationCode"
    pure $ OAuthFlows $ { implicit, password, clientCredentials, authorizationCode }

instance oauthflowsEncodeJson :: EncodeJson OAuthFlows where
  encodeJson = unwrap >>> encodeJson



-- OpenAPI Object
-- This is the root document object of the OpenAPI document.

-- Fixed Fields
newtype OpenApi = OpenApi
  { openapi :: String -- REQUIRED. This string MUST be the semantic version number of the OpenAPI Specification version that the OpenAPI document uses. The openapi field SHOULD be used by tooling specifications and clients to interpret the OpenAPI document. This is not related to the API info.version string.
  , info :: Info -- REQUIRED. Provides metadata about the API. The metadata MAY be used by tooling as required.
  , servers :: Maybe (Array Server) -- An array of Server Objects, which provide connectivity information to a target server. If the servers property is not provided, or is an empty array, the default value would be a Server Object with a url value of /.
  , paths :: Paths -- REQUIRED. The available paths and operations for the API.
  , components :: Maybe Components -- An element to hold various schemas for the specification.
  , security :: Maybe (Array SecurityRequirement) -- A declaration of which security mechanisms can be used across the API. The list of values includes alternative security requirement objects that can be used. Only one of the security requirement objects need to be satisfied to authorize a request. Individual operations can override this definition. To make security optional, an empty security requirement ({}) can be included in the array.
  , tags :: Maybe (Array Tag) -- A list of tags used by the specification with additional metadata. The order of the tags can be used to reflect on their order by the parsing tools. Not all tags that are used by the Operation Object must be declared. The tags that are not declared MAY be organized randomly or based on the tools' logic. Each tag name in the list MUST be unique.
  , externalDocs :: Maybe ExternalDocumentation -- Additional external documentation.
}
-- This object MAY be extended with Specification Extensions.
derive instance openapiNewtype :: Newtype OpenApi _
derive instance openapiGeneric :: Generic OpenApi _

instance openapiDecodeJson :: DecodeJson OpenApi where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    openapi <- getField o "openapi" -- REQUIRED. This string MUST be the semantic version number of the OpenAPI Specification version that the OpenAPI document uses. The openapi field SHOULD be used by tooling specifications and clients to interpret the OpenAPI document. This is not related to the API info.version string.
    info <- getField o "info" -- REQUIRED. Provides metadata about the API. The metadata MAY be used by tooling as required.
    paths <- getField o "paths" -- REQUIRED. The available paths and operations for the API.
    servers <- getFieldOptional o "servers" -- An array of Server Objects, which provide connectivity information to a target server. If the servers property is not provided, or is an empty array, the default value would be a Server Object with a url value of /.
    components <- getFieldOptional o "components" -- An element to hold various schemas for the specification.
    security <- getFieldOptional o "security"  -- A declaration of which security mechanisms can be used across the API. The list of values includes alternative security requirement objects that can be used. Only one of the security requirement objects need to be satisfied to authorize a request. Individual operations can override this definition. To make security optional, an empty security requirement ({}) can be included in the array.
    tags <- getFieldOptional o "tags" -- A list of tags used by the specification with additional metadata. The order of the tags can be used to reflect on their order by the parsing tools. Not all tags that are used by the Operation Object must be declared. The tags that are not declared MAY be organized randomly or based on the tools' logic. Each tag name in the list MUST be unique.
    externalDocs <- getFieldOptional o "externalDocs"  -- Additional external documentation.
    pure $ OpenApi $ { openapi, info, paths, servers, components,  security, tags,  externalDocs }
instance openapiEncodeJson :: EncodeJson OpenApi where
  encodeJson = unwrap >>> encodeJson

-- Operation Object
-- Describes a single API operation on a path.

-- Fixed Fields
newtype Operation = Operation
  { tags :: Maybe (Array String) -- A list of tags for API documentation control. Tags can be used for logical grouping of operations by resources or any other qualifier.
  , summary :: Maybe String -- A short summary of what the operation does.
  , description :: Maybe String -- A verbose explanation of the operation behavior. CommonMark syntax MAY be used for rich text representation.
  , externalDocs :: Maybe ExternalDocumentation -- Additional external documentation for this operation.
  , operationId :: Maybe String -- Unique string used to identify the operation. The id MUST be unique among all operations described in the API. The operationId value is case-sensitive. Tools and libraries MAY use the operationId to uniquely identify an operation, therefore, it is RECOMMENDED to follow common programming naming conventions.
  , parameters :: Maybe (Array (Refable Parameter)) -- A list of parameters that are applicable for this operation. If a parameter is already defined at the Path Item, the new definition will override it but can never remove it. The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location. The list can use the Reference Object to link to parameters that are defined at the OpenAPI Object's components/parameters.
  , requestBody :: Maybe (Refable RequestBody) -- The request body applicable for this operation. The requestBody is only supported in HTTP methods where the HTTP 1.1 specification RFC7231 has explicitly defined semantics for request bodies. In other cases where the HTTP spec is vague, requestBody SHALL be ignored by consumers.
  , responses :: Responses -- REQUIRED. The list of possible responses as they are returned from executing this operation.
  , callbacks :: Maybe (Map String (Refable Callback)) -- A map of possible out-of band callbacks related to the parent operation. The key is a unique identifier for the Callback Object. Each value in the map is a Callback Object that describes a request that may be initiated by the API provider and the expected responses.
  , deprecated :: Maybe Boolean -- Declares this operation to be deprecated. Consumers SHOULD refrain from usage of the declared operation. Default value is false.
  , security :: Maybe (Array SecurityRequirement) -- A declaration of which security mechanisms can be used for this operation. The list of values includes alternative security requirement objects that can be used. Only one of the security requirement objects need to be satisfied to authorize a request. To make security optional, an empty security requirement ({}) can be included in the array. This definition overrides any declared top-level security. To remove a top-level security declaration, an empty array can be used.
  , servers :: Maybe (Array Server) -- An alternative server array to service this operation. If an alternative server object is specified at the Path Item Object or Root level, it will be overridden by this value.
}
derive instance operationNewtype :: Newtype Operation _
derive instance operationGeneric :: Generic Operation _
-- derive newtype instance operationShow :: Show Operation

instance operationDecodeJson :: DecodeJson Operation where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    tags <- getFieldOptional o "tags"
    summary <- getFieldOptional o "summary"
    description <- getFieldOptional o "description"
    externalDocs <- getFieldOptional o "externalDocs"
    operationId <- getFieldOptional o "operationId"
    parameters <- getFieldOptional o "parameters"
    requestBody <- getFieldOptional o "requestBody"
    responses <- getField o "responses"
    callbacks <- getFieldOptional o "callbacks"
    deprecated <- getFieldOptional o "deprecated"
    security <- getFieldOptional o "security"
    servers <- getFieldOptional o "servers"

    pure $ Operation { tags, summary, description, externalDocs, operationId, parameters, requestBody, responses, callbacks, deprecated, security, servers }

instance operationEncodeJson :: EncodeJson Operation where
  encodeJson = unwrap >>> encodeJson


-- This object MAY be extended with Specification Extensions.



-- Parameter Object
-- Describes a single operation parameter.

-- A unique parameter is defined by a combination of a name and location.

-- Parameter Locations
-- There are four possible parameter locations specified by the in field:

-- path - Used together with Path Templating, where the parameter value is actually part of the operation's URL. This does not include the host or base path of the API. For example, in /items/{itemId}, the path parameter is itemId.
-- query - Parameters that are appended to the URL. For example, in /items?id=###, the query parameter is id.
-- header - Custom headers that are expected as part of the request. Note that RFC7230 states header names are case insensitive.
-- cookie - Used to pass a specific cookie value to the API.

-- Fixed Fields
newtype Parameter = Parameter
  { name :: String -- REQUIRED. The name of the parameter. Parameter names are case sensitive.
  -- If in is "path", the name field MUST correspond to a template expression occurring within the path field in the Paths Object. See Path Templating for further information.
  -- If in is "header" and the name field is "Accept", "Content-Type" or "Authorization", the parameter definition SHALL be ignored.
  -- For all other cases, the name corresponds to the parameter name used by the in property.
  , in :: String -- REQUIRED. The location of the parameter. Possible values are "query", "header", "path" or "cookie".
  , description :: Maybe String -- A brief description of the parameter. This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
  , required :: Maybe Boolean -- Determines whether this parameter is mandatory. If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false.
  , deprecated :: Maybe Boolean -- Specifies that a parameter is deprecated and SHOULD be transitioned out of usage. Default value is false.
  , allowEmptyValue :: Maybe Boolean -- Sets the ability to pass empty-valued parameters. This is valid only for query parameters and allows sending a parameter with an empty value. Default value is false. If style is used, and if behavior is n/a (cannot be serialized), the value of allowEmptyValue SHALL be ignored. Use of this property is NOT RECOMMENDED, as it is likely to be removed in a later revision.
      -- The rules for serialization of the parameter are specified in one of two ways. For simpler scenarios, a schema and style can describe the structure and syntax of the parameter.
  , style :: Maybe String -- Describes how the parameter value will be serialized depending on the type of the parameter value. Default values (based on value of in): for query - form; for path - simple; for header - simple; for cookie - form.
  , explode :: Maybe Boolean -- When this is true, parameter values of type array or object generate separate parameters for each value of the array or key-value pair of the map. For other types of parameters this property has no effect. When style is form, the default value is true. For all other styles, the default value is false.
  , allowReserved :: Maybe Boolean -- Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. This property only applies to parameters with an in value of query. The default value is false.
  , schema :: Maybe (Refable Schema) -- The schema defining the type used for the parameter.
  , example :: Maybe Json -- Example of the parameter's potential value. The example SHOULD match the specified schema and encoding properties if present. The example field is mutually exclusive of the examples field. Furthermore, if referencing a schema that contains an example, the example value SHALL override the example provided by the schema. To represent examples of media types that cannot naturally be represented in JSON or YAML, a string value can contain the example with escaping where necessary.
  , examples :: Maybe (Map String (Refable Example)) -- Examples of the parameter's potential value. Each example SHOULD contain a value in the correct format as specified in the parameter encoding. The examples field is mutually exclusive of the example field. Furthermore, if referencing a schema that contains an example, the examples value SHALL override the example provided by the schema.
    -- For more complex scenarios, the content property can define the media type and schema of the parameter. A parameter MUST contain either a schema property, or a content property, but not both. When example or examples are provided in conjunction with the schema object, the example MUST follow the prescribed serialization strategy for the parameter.

  , content :: Maybe (Map String MediaType) -- A map containing the representations for the parameter. The key is the media type and the value describes it. The map MUST only contain one entry.
  }
derive instance parameterNewtype :: Newtype Parameter _
derive instance parameterlGeneric :: Generic Parameter _
-- derive newtype instance parameterShow :: Show Parameter

instance parameterlDecodeJson :: DecodeJson Parameter where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    name <- getField o "name"
    i <- getField o "in"
    description <- getFieldOptional o "description"
    required <- getFieldOptional o "required"
    deprecated <- getFieldOptional o "deprecated"
    allowEmptyValue <- getFieldOptional o "allowEmptyValue"
    style <-  getFieldOptional o "style"
    explode <- getFieldOptional o "explode" -- TODO: default?
    allowReserved <- getFieldOptional o "allowReserved"
    schema <- getFieldOptional o "schema"
    example <- getFieldOptional o "example"
    examples <- getFieldOptional o "examples"
    content <-  getFieldOptional o "content"

    pure $ Parameter { name, "in": i, description, required, deprecated, allowEmptyValue, style, explode, allowReserved, schema, example, examples, content }

instance parameterEncodeJson :: EncodeJson Parameter where
  encodeJson = unwrap >>> encodeJson


-- Style Values
-- In order to support common ways of serializing simple parameters, a set of style values are defined.
-- style type in Comments
-- matrix primitive, array, object path Path-style parameters defined by RFC6570
-- label primitive, array, object path Label style parameters defined by RFC6570
-- form primitive, array, object query, cookie Form style parameters defined by RFC6570. This option replaces collectionFormat with a csv (when explode is false) or multi (when explode is true) value from OpenAPI 2.0.
-- simple array path, header Simple style parameters defined by RFC6570. This option replaces collectionFormat with a csv value from OpenAPI 2.0.
-- spaceDelimited array query Space separated array values. This option replaces collectionFormat equal to ssv from OpenAPI 2.0.
-- pipeDelimited array query Pipe separated array values. This option replaces collectionFormat equal to pipes from OpenAPI 2.0.
-- deepObject object query Provides a simple way of rendering nested objects using form parameters.
-- Style Examples
-- Assume a parameter named color has one of the following values:

--    string -> "blue"
--    array -> ["blue","black","brown"]
--    object -> { "R": 100, "G": 200, "B": 150 }
-- The following table shows examples of rendering differences for each value.

-- style explode empty string array object
-- matrix false ;color ;color=blue ;color=blue,black,brown ;color=R,100,G,200,B,150
-- matrix true ;color ;color=blue ;color=blue;color=black;color=brown ;R=100;G=200;B=150
-- label false . .blue .blue.black.brown .R.100.G.200.B.150
-- label true . .blue .blue.black.brown .R=100.G=200.B=150
-- form false color= color=blue color=blue,black,brown color=R,100,G,200,B,150
-- form true color= color=blue color=blue&color=black&color=brown R=100&G=200&B=150
-- simple false n/a blue blue,black,brown R,100,G,200,B,150
-- simple true n/a blue blue,black,brown R=100,G=200,B=150
-- spaceDelimited false n/a n/a blue%20black%20brown R%20100%20G%20200%20B%20150
-- pipeDelimited false n/a n/a blue|black|brown R|100|G|200|B|150
-- deepObject true n/a n/a n/a color[R]=100&color[G]=200&color[B]=150
-- This object MAY be extended with Specification Extensions.

-- A free-form query parameter, allowing undefined parameters of a specific type:

-- Path Item Object
-- Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.

-- Fixed Fields
newtype PathItem = PathItem
  { "$ref" :: Maybe String -- Allows for an external definition of this path item. The referenced structure MUST be in the format of a Path Item Object. In case a Path Item Object field appears both in the defined object and the referenced object, the behavior is undefined.
  , summary :: Maybe String -- An optional, string summary, intended to apply to all operations in this path.
  , description :: Maybe String -- An optional, string description, intended to apply to all operations in this path. CommonMark syntax MAY be used for rich text representation.
  , get :: Maybe Operation -- A definition of a GET operation on this path.
  , put :: Maybe Operation -- A definition of a PUT operation on this path.
  , post :: Maybe Operation -- A definition of a POST operation on this path.
  , delete :: Maybe Operation -- A definition of a DELETE operation on this path.
  , options :: Maybe Operation -- A definition of a OPTIONS operation on this path.
  , head :: Maybe Operation -- A definition of a HEAD operation on this path.
  , patch :: Maybe Operation -- A definition of a PATCH operation on this path.
  , trace :: Maybe Operation -- A definition of a TRACE operation on this path.
  , servers :: Maybe (Array Server) -- An alternative server array to service all operations in this path.
  , parameters :: Maybe (Array (Refable Parameter)) -- A list of parameters that are applicable for all the operations described under this path. These parameters can be overridden at the operation level, but cannot be removed there. The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location. The list can use the Reference Object to link to parameters that are defined at the OpenAPI Object's components/parameters.
  -- , examples :: Maybe (Map String Example)
}
derive instance pathItemNewtype :: Newtype PathItem _
derive instance pathItemGeneric :: Generic PathItem _
-- derive newtype instance pathitemShow :: Show PathItem

instance pathItemDecodeJson :: DecodeJson PathItem where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    ref <- getFieldOptional o "$ref"
    summary <- getFieldOptional o "summary"
    description <- getFieldOptional o "description"
    get <- getFieldOptional o "get"
    put <- getFieldOptional o "put"
    post <- getFieldOptional o "post"
    delete <- getFieldOptional o "delete"
    options <- getFieldOptional o "options"
    head <- getFieldOptional o "head"
    patch <- getFieldOptional o "patch"
    trace <- getFieldOptional o "trace"
    servers <- getFieldOptional o "servers"
    parameters <- getFieldOptional o "parameters"
    pure $ PathItem { "$ref": ref, summary, description, get, put, post, delete, options, head, patch,  trace, servers, parameters }

instance pathItemEncodeJson :: EncodeJson PathItem where
  encodeJson = unwrap >>> encodeJson


-- This object MAY be extended with Specification Extensions.


-- Paths Object
-- Holds the relative paths to the individual endpoints and their operations. The path is appended to the URL from the Server Object in order to construct the full URL. The Paths MAY be empty, due to ACL constraints.

newtype Paths = Paths (Map String PathItem)
derive instance pathsNewtype :: Newtype Paths _
derive instance pathslGeneric :: Generic Paths _
-- derive newtype instance pathsShow :: Show Paths

instance pathsDecodeJson :: DecodeJson Paths where
  decodeJson = decodeJson >>> (map wrap)

instance pathsEncodeJson :: EncodeJson Paths where
  encodeJson = unwrap >>> encodeJson


-- Patterned Fields
-- Field Pattern Type Description
-- /{path} Path Item Object A relative path to an individual endpoint. The field name MUST begin with a forward slash (/). The path is appended (no relative URL resolution) to the expanded URL from the Server Object's url field in order to construct the full URL. Path templating is allowed. When matching URLs, concrete (non-templated) paths would be matched before their templated counterparts. Templated paths with the same hierarchy but different templated names MUST NOT exist as they are identical. In case of ambiguous matching, it's up to the tooling to decide which one to use.
-- This object MAY be extended with Specification Extensions.

-- Path Templating Matching
-- Assuming the following paths, the concrete definition, /pets/mine, will be matched first if used:

--   /pets/{petId}
--   /pets/mine
-- The following paths are considered identical and invalid:

--   /pets/{petId}
--   /pets/{name}
-- The following may lead to ambiguous resolution:

--   /{entity}/me
--   /books/{id}


-- Request Body Object
-- Describes a single request body.

-- Fixed Fields
newtype RequestBody = RequestBody
  { description :: Maybe String -- A brief description of the request body. This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
  , content :: Map String MediaType -- REQUIRED. The content of the request body. The key is a media type or media type range and the value describes it. For requests that match multiple keys, only the most specific key is applicable. e.g. text/plain overrides text/*
  , required :: Maybe Boolean -- Determines if the request body is required in the request. Defaults to false.
  }
derive instance requestbodyNewtype :: Newtype RequestBody _
derive instance requestbodyGeneric :: Generic RequestBody _
-- derive newtype instance requestbodyShow :: Show RequestBody

instance requestBodyEncodeJson :: EncodeJson RequestBody where
  encodeJson = unwrap >>> encodeJson

instance requestBodyDecodeJson :: DecodeJson RequestBody where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    description <- getFieldOptional o "description"
    content <- getField o "content"
    required <- getFieldOptional o "required"
    pure $ RequestBody { description, content, required }




-- This object MAY be extended with Specification Extensions.

-- Response Object
-- Describes a single response from an API Operation, including design-time, static links to operations based on the response.

-- Fixed Fields
newtype Response = Response
  { description :: String -- REQUIRED. A short description of the response. CommonMark syntax MAY be used for rich text representation.
  , headers :: Maybe (Map String (Refable Header)) -- Maps a header name to its definition. RFC7230 states header names are case insensitive. If a response header is defined with the name "Content-Type", it SHALL be ignored.
  , content :: Maybe (Map String MediaType) -- A map containing descriptions of potential response payloads. The key is a media type or media type range and the value describes it. For responses that match multiple keys, only the most specific key is applicable. e.g. text/plain overrides text/*
  , links :: Maybe (Map String (Refable Link)) -- A map of operations links that can be followed from the response. The key of the map is a short name for the link, following the naming constraints of the names for Component Objects.
  }
derive instance responseNewtype :: Newtype Response _
derive instance responseGeneric :: Generic Response _
-- derive newtype instance responseShow :: Show Response

instance responseDecodeJson :: DecodeJson Response where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    description <- getField o "description"
    headers <- getFieldOptional o "headers"
    content <- getFieldOptional o "content"
    links <- getFieldOptional o "links"
    pure $ Response { description, headers, content, links }

instance responseEncodeJson :: EncodeJson Response where
  encodeJson = unwrap >>> encodeJson


-- This object MAY be extended with Specification Extensions.


-- Responses Object
-- A container for the expected responses of an operation. The container maps a HTTP response code to the expected response.

-- The documentation is not necessarily expected to cover all possible HTTP response codes because they may not be known in advance. However, documentation is expected to cover a successful operation response and any known errors.

-- The default MAY be used as a default response object for all HTTP codes that are not covered individually by the specification.

-- The Responses Object MUST contain at least one response code, and it SHOULD be the response for a successful operation call.

-- Fixed Fields
newtype Responses = Responses (Map String (Refable Response))
derive instance responsesNewtype :: Newtype Responses _
derive instance responsesGeneric :: Generic Responses _
-- derive newtype instance responsesShow :: Show Responses

instance responsesDecodeJson :: DecodeJson Responses where
  decodeJson j = Responses <$> decodeJson j

instance responsesEncodeJson :: EncodeJson Responses where
  encodeJson = unwrap >>> encodeJson

-- Patterned Fields
-- Field Pattern Type Description
-- HTTP Status Code Response Object | Reference Object Any HTTP status code can be used as the property name, but only one property per code, to describe the expected response for that HTTP status code. A Reference Object can link to a response that is defined in the OpenAPI Object's components/responses section. This field MUST be enclosed in quotation marks (for example, "200") for compatibility between JSON and YAML. To define a range of response codes, this field MAY contain the uppercase wildcard character X. For example, 2XX represents all response codes between [200-299]. Only the following range definitions are allowed: 1XX, 2XX, 3XX, 4XX, and 5XX. If a response is defined using an explicit code, the explicit code definition takes precedence over the range definition for that code.
-- This object MAY be extended with Specification Extensions.



-- Schema Object
-- The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is an extended subset of the JSON Schema Specification Wright Draft 00.

-- For more information about the properties, see JSON Schema Core and JSON Schema Validation. Unless stated otherwise, the property definitions follow the JSON Schema.

-- Properties
-- The following properties are taken directly from the JSON Schema definition and follow the same specifications:

-- title
-- multipleOf
-- maximum
-- exclusiveMaximum
-- minimum
-- exclusiveMinimum
-- maxLength
-- minLength
-- pattern (This string SHOULD be a valid regular expression, according to the Ecma-262 Edition 5.1 regular expression dialect)
-- maxItems
-- minItems
-- uniqueItems
-- maxProperties
-- minProperties
-- required
-- enum
-- The following properties are taken from the JSON Schema definition but their definitions were adjusted to the OpenAPI Specification.

-- type - Value MUST be a string. Multiple types via an array are not supported.
-- allOf - Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema.
-- oneOf - Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema.
-- anyOf - Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema.
-- not - Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema.
-- items - Value MUST be an object and not an array. Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema. items MUST be present if the type is array.
-- properties - Property definitions MUST be a Schema Object and not a standard JSON Schema (inline or referenced).
-- additionalProperties - Value can be booleanean or object. Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema. Consistent with JSON Schema, additionalProperties defaults to true.
-- description - CommonMark syntax MAY be used for rich text representation.
-- format - See Data Type Formats for further details. While relying on JSON Schema's defined formats, the OAS offers a few additional predefined formats.
-- default - The default value represents what would be assumed by the consumer of the input as the value of the schema if one is not provided. Unlike JSON Schema, the value MUST conform to the defined type for the Schema Object defined at the same level. For example, if type is string, then default can be "foo" but cannot be 1.
-- Alternatively, any time a Schema Object can be used, a Reference Object can be used in its place. This allows referencing definitions instead of defining them inline.

-- Additional properties defined by the JSON Schema specification that are not mentioned here are strictly unsupported.

-- Other than the JSON Schema subset fields, the following fields MAY be used for further schema documentation:

-- Fixed Fields
newtype Schema = Schema
  { title :: Maybe String
  , multipleOf :: Maybe String
  , maximum :: Maybe Number
  , exclusiveMaximum :: Maybe Number
  , minimum :: Maybe Number
  , exclusiveMinimum :: Maybe Number
  , maxLength :: Maybe Int
  , minLength :: Maybe Int
  , pattern :: Maybe String
  , maxItems :: Maybe Int -- natural
  , minItems :: Maybe Int -- natural
  -- , uniqueItems :: _
  , maxProperties :: Maybe Int -- natural
  , minProperties :: Maybe Int -- natural
  , required :: Maybe (Array String)
  -- , enum

  , type :: Maybe String
  , allOf :: Maybe (Array (Refable Schema))
  , oneOf :: Maybe (Array (Refable Schema))
  , anyOf :: Maybe (Array (Refable Schema))
  , not :: Maybe (Refable Schema)
  , items :: Maybe (Refable Schema)
  , properties :: Maybe (Refable Schema)
  -- , additionalProperties - Value can be booleanean or object. Inline or referenced schema MUST be of a Schema Object and not a standard JSON Schema. Consistent with JSON Schema, additionalProperties defaults to true.
  -- , description - CommonMark syntax MAY be used for rich text representation.
  -- , format - See Data Type Formats for further details. While relying on JSON Schema's defined formats, the OAS offers a few additional predefined formats.
  -- , default - The default value represents what would be assumed by the consumer of the input as the value of the schema if one is not provided. Unlike JSON Schema, the value MUST conform to the defined type for the Schema Object defined at the same level. For example, if type is string, then default can be "foo" but cannot be 1.
-- Alternatively, any time a Schema Object can be used, a Reference Object can be used in its place. This allows referencing definitions instead of defining them inline.

  , nullable :: Maybe Boolean -- A true value adds "null" to the allowed type specified by the type keyword, only if type is explicitly defined within the same Schema Object. Other Schema Object constraints retain their defined behavior, and therefore may disallow the use of null as a value. A false value leaves the specified or default type unmodified. The default value is false.
  , discriminator :: Maybe Discriminator -- Object Adds support for polymorphism. The discriminator is an object name that is used to differentiate between other schemas which may satisfy the payload description. See Composition and Inheritance for more details.
  , readOnly :: Maybe Boolean -- Relevant only for Schema "properties" definitions. Declares the property as "read only". This means that it MAY be sent as part of a response but SHOULD NOT be sent as part of the request. If the property is marked as readOnly being true and is in the required list, the required will take effect on the response only. A property MUST NOT be marked as both readOnly and writeOnly being true. Default value is false.
  , writeOnly :: Maybe Boolean -- Relevant only for Schema "properties" definitions. Declares the property as "write only". Therefore, it MAY be sent as part of a request but SHOULD NOT be sent as part of the response. If the property is marked as writeOnly being true and is in the required list, the required will take effect on the request only. A property MUST NOT be marked as both readOnly and writeOnly being true. Default value is false.
  , xml :: Maybe Xml -- Object This MAY be used only on properties schemas. It has no effect on root schemas. Adds additional metadata to describe the XML representation of this property.
  , externalDocs :: Maybe ExternalDocumentation --  Additional external documentation for this schema.
  , example :: Maybe Json -- A free-form property to include an example of an instance for this schema. To represent examples that cannot be naturally represented in JSON or YAML, a string value can be used to contain the example with escaping where necessary.
  , deprecated :: Maybe Boolean -- Specifies that a schema is deprecated and SHOULD be transitioned out of usage. Default value is false.
}
derive instance schemaNewtype :: Newtype Schema _
derive instance schemalGeneric :: Generic Schema _
-- derive newtype instance schemaShow :: Show Schema

instance schemaDecodeJson :: DecodeJson Schema where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    title <- getFieldOptional o "title"
    multipleOf <- getFieldOptional o "multipleOf"
    maximum <- getFieldOptional o "maximum"
    exclusiveMaximum <- getFieldOptional o "exclusiveMaximum"
    minimum <- getFieldOptional o "minimum"
    exclusiveMinimum <- getFieldOptional o "exclusiveMinimum"
    maxLength <- getFieldOptional o "maxLength"
    minLength <- getFieldOptional o "minLength"
    pattern <- getFieldOptional o "pattern"
    maxItems <- getFieldOptional o "maxItems"
    minItems <- getFieldOptional o "minItems"
    -- uniqueItems <- getField o "haa" _
    maxProperties <- getFieldOptional o "maxProperties"
    minProperties <- getFieldOptional o "minProperties"
    required <- getFieldOptional o "required"

    typ <- getFieldOptional o "type"
    allOf <- getFieldOptional o "allOf"
    oneOf <- getFieldOptional o "oneOf"
    anyOf <- getFieldOptional o "anyOf"
    not <- getFieldOptional o "not"
    items <- getFieldOptional o "items"
    properties <- getFieldOptional o  "properties"

    nullable <- getFieldOptional o "nullable"
    discriminator <- getFieldOptional o  "discriminator"
    readOnly <- getFieldOptional o  "readOnly"
    writeOnly <- getFieldOptional o  "writeOnly"
    xml <- getFieldOptional o  "xml"
    externalDocs <- getFieldOptional o  "externalDocs"
    example <-  getFieldOptional o "example"
    deprecated <- getFieldOptional o  "deprecated"

    pure $ Schema { title, multipleOf, maximum, exclusiveMaximum, minimum, exclusiveMinimum, maxLength, minLength, pattern, maxItems, minItems, maxProperties, minProperties, required
      , type: typ, allOf, oneOf, anyOf, not, items, properties
      ,nullable, discriminator, readOnly, writeOnly, xml, externalDocs, example, deprecated
      }

instance schemaEncodeJson :: EncodeJson Schema where
  encodeJson c = encodeJson $ unwrap c

-- This object MAY be extended with Specification Extensions.

-- Composition and Inheritance (Polymorphism)
-- The OpenAPI Specification allows combining and extending model definitions using the allOf property of JSON Schema, in effect offering model composition. allOf takes an array of object definitions that are validated independently but together compose a single object.

-- While composition offers model extensibility, it does not imply a hierarchy between the models. To support polymorphism, the OpenAPI Specification adds the discriminator field. When used, the discriminator will be the name of the property that decides which schema definition validates the structure of the model. As such, the discriminator field MUST be a required field. There are two ways to define the value of a discriminator for an inheriting instance.

-- Use the schema name.
-- Override the schema name by overriding the property with a new value. If a new value exists, this takes precedence over the schema name. As such, inline schema definitions, which do not have a given id, cannot be used in polymorphism.
-- XML Modeling
-- The xml property allows extra definitions when translating the JSON definition to XML. The XML Object contains additional information about the available options.



-- Security Scheme Object
-- Defines a security scheme that can be used by the operations. Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), OAuth2's common flows (implicit, password, client credentials and authorization code) as defined in RFC6749, and OpenID Connect Discovery.

-- Fixed Fields
-- TODO:  Three  separate types? -am

newtype SecurityScheme = SecurityScheme
  { ty :: String -- Any REQUIRED. The type of the security scheme. Valid values are "apiKey", "http", "oauth2", "openIdConnect".
  , description :: Maybe String -- Any A short description for security scheme. CommonMark syntax MAY be used for rich text representation.
  , name :: Maybe String -- apiKey REQUIRED. The name of the header, query or cookie parameter to be used.
  , location :: Maybe String -- TODO: parse as 'in' apiKey REQUIRED. The location of the API key. Valid values are "query", "header" or "cookie".
  , scheme :: Maybe String -- http REQUIRED. The name of the HTTP Authorization scheme to be used in the Authorization header as defined in RFC7235. The values used SHOULD be registered in the IANA Authentication Scheme registry.
  , bearerFormat :: Maybe String -- http ("bearer") A hint to the client to identify how the bearer token is formatted. Bearer tokens are usually generated by an authorization server, so this information is primarily for documentation purposes.
  , flows :: Maybe OAuthFlows -- Object oauth2 REQUIRED. An object containing configuration information for the flow types supported.
  , openIdConnectUrl :: Maybe String -- openIdConnect REQUIRED. OpenId Connect URL to discover OAuth2 configuration values. This MUST be in the form of a URL.
}
-- This object MAY be extended with Specification Extensions
derive instance securitySchemeNewtype :: Newtype SecurityScheme _
derive instance securityschemelGeneric :: Generic SecurityScheme _
-- derive newtype instance securityschemeShow :: Show SecurityScheme

instance securitySchemeDecodeJson :: DecodeJson SecurityScheme where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    ty <- getField o "type"
    description <- getFieldOptional o "description"
    name <- getFieldOptional o "name"
    location <- getFieldOptional o "location"
    scheme <- getFieldOptional o "scheme"
    bearerFormat <- getFieldOptional o "bearerFormat"
    flows <- getFieldOptional o "flows"
    openIdConnectUrl <- getFieldOptional o "openIdConnectUrl"

    pure $ SecurityScheme { ty, description, name, location, scheme, bearerFormat, flows, openIdConnectUrl }

instance securitySchemeEncodeJson :: EncodeJson SecurityScheme where
  encodeJson c = encodeJson $ unwrap c



-- Server Object
-- An object representing a Server.

-- Fixed Fields
newtype Server = Server
  { url :: String -- REQUIRED. A URL to the target host. This URL supports Server Variables and MAY be relative, to indicate that the host location is relative to the location where the OpenAPI document is being served. Variable substitutions will be made when a variable is named in {brackets}.
  , description :: Maybe String -- An optional string describing the host designated by the URL. CommonMark syntax MAY be used for rich text representation.
  , variables :: Maybe (Map String ServerVariable) -- A map between a variable name and its value. The value is used for substitution in the server's URL template.
}
derive instance serverNewtype :: Newtype Server _
derive instance serverGeneric :: Generic Server _
-- derive newtype instance serverShow :: Show Server

instance serverDecodeJson :: DecodeJson Server where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    url <- getField o "url"
    description <- getFieldOptional o "description"
    variables :: Maybe (Object ServerVariable) <- getFieldOptional o "variables"
    pure $ Server $ { url, description, variables: objectToMap <$> variables }

instance serverEncodeJson :: EncodeJson Server where
  encodeJson = unwrap >>> encodeJson

-- This object MAY be extended with Specification Extensions.


-- Server Variable Object
-- An object representing a Server Variable for server URL template substitution.

-- Fixed Fields
newtype ServerVariable = ServerVariable
  { enum :: Maybe (Array String) --  An enumeration of string values to be used if the substitution options are from a limited set. The array SHOULD NOT be empty.
  , default :: String --  REQUIRED. The default value to use for substitution, which SHALL be sent if an alternate value is not supplied. Note this behavior is different than the Schema Object's treatment of default values, because in those cases parameter values are optional. If the enum is defined, the value SHOULD exist in the enum's values.
  , description :: Maybe String --  An optional description for the server variable. CommonMark syntax MAY be used for rich text representation.
}
derive instance serverVariableNewtype :: Newtype ServerVariable _
derive instance servervariableGeneric :: Generic ServerVariable _
-- derive newtype instance servervariableShow :: Show ServerVariable

instance serverVariableDecodeJson :: DecodeJson ServerVariable where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    enum <- getFieldOptional o "enum"
    default <- getField o "default"
    description :: Maybe String <- getFieldOptional o "description"
    pure $ ServerVariable $ { enum, default, description }

instance serverVariableEncodeJson :: EncodeJson ServerVariable where
  encodeJson = unwrap >>> encodeJson

-- This object MAY be extended with Specification Extensions.

-- Tag Object
-- Adds metadata to a single tag that is used by the Operation Object. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances.

-- Fixed Fields
newtype Tag = Tag
  { name :: String -- REQUIRED. The name of the tag.
 , description :: Maybe String -- A short description for the tag. CommonMark syntax MAY be used for rich text representation, .
 , externalDocs :: Maybe ExternalDocumentation -- Additional external documentation for this tag.
  }
-- This object MAY be extended with Specification Extensions.
derive instance tagVariableNewtype :: Newtype Tag _
derive instance tagGeneric :: Generic Tag _
-- derive newtype instance tagShow :: Show Tag

instance tagDecodeJson :: DecodeJson Tag where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    name <- getField o "name"
    description <- getFieldOptional o "description"
    externalDocs <- getFieldOptional o "externalDocs"
    pure $ Tag $ { name, description, externalDocs }

instance tagEncodeJson :: EncodeJson Tag where
  encodeJson = unwrap >>> encodeJson


-- XML Object
-- A metadata object that allows for more fine-tuned XML model definitions.

-- When using arrays, XML element names are not inferred (for singular/plural forms) and the name property SHOULD be used to add that information. See examples for expected behavior.

-- Fixed Fields
newtype Xml = Xml
  { name :: Maybe String -- Replaces the name of the element/attribute used for the described schema property. When defined within items, it will affect the name of the individual XML elements within the list. When defined alongside type being array (outside the items), it will affect the wrapping element and only if wrapped is true. If wrapped is false, it will be ignored.
  , namespace :: Maybe String -- The URI of the namespace definition. Value MUST be in the form of an absolute URI.
  , prefix :: Maybe String -- The prefix to be used for the name.
  , attribute :: Maybe Boolean -- Declares whether the property definition translates to an attribute instead of an element. Default value is false.
  , wrapped :: Maybe Boolean -- MAY be used only for an array definition. Signifies whether the array is wrapped (for example, <books><book/><book/></books>) or unwrapped (<book/><book/>). Default value is false. The definition takes effect only when defined alongside type being array (outside the items).
  }
derive instance xmlNewtype :: Newtype Xml _
derive instance xmlGeneric :: Generic Xml _
-- derive newtype instance xmlShow :: Show Xml

instance xmlDecodeJson :: DecodeJson Xml where
  decodeJson j = do
    o <- note "not an object" $ toObject j
    name <- getFieldOptional o "name"
    namespace <- getFieldOptional o "namespace"
    prefix <- getFieldOptional o "prefix"
    attribute <- getFieldOptional o "attribute"
    wrapped <- getFieldOptional o "wrapped"

    pure $ Xml $ { name, namespace, prefix, attribute, wrapped }

instance xmlEncodeJson :: EncodeJson Xml where
  encodeJson = unwrap >>> encodeJson



-- This object MAY be extended with Specification Extensions.
