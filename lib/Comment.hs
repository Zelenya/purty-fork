module Comment where

import "rio" RIO

import "prettyprinter" Data.Text.Prettyprint.Doc (Doc, hardline, pretty)

import qualified "purescript" Language.PureScript

data Comment
  = Block !Text
  | Line !Text
  deriving (Show)

doc :: Comment -> Doc a
doc = \case
  Block x -> "{-" <> pretty x <> "-}"
  Line x -> "--" <> pretty x <> hardline

fromPureScript :: Language.PureScript.Comment -> Comment
fromPureScript = \case
  Language.PureScript.BlockComment x -> Block x
  Language.PureScript.LineComment x -> Line x