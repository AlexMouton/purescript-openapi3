{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "purescript-openapi3"
, license = "MIT"
, repository = "https://github.com/AlexMouton/purescript-openapi3.git"
, dependencies =
  [ "argonaut"
  , "argonaut-generic"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "generics-rep"
  , "newtype"
  , "integers"
  , "node-buffer"
  , "node-fs-aff"
  , "ordered-collections"
  , "psci-support"
  , "yayamll"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
