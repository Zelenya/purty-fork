module Error where

import "rio" RIO

import "lens" Control.Lens  (Prism', prism)
import "base" System.Exit   (exitFailure)
import "parsec" Text.Parsec (ParseError)

import qualified "this" AST

data Error
  = AST AST.Error
  | Parse ParseError

instance AST.IsMissingName Error where
  _MissingName = AST._Error.AST._MissingName

instance AST.IsError Error where
  _Error = prism AST $ \case
    AST x -> Right x
    x -> Left x

class (AST.IsError error, IsParseError error) => IsError error where
  _Error :: Prism' error Error

instance IsError Error where
  _Error = prism id Right

class IsParseError error where
  _ParseError :: Prism' error ParseError

instance IsParseError ParseError where
  _ParseError = prism id Right

instance IsParseError Error where
  _ParseError = prism Parse $ \case
    Parse x -> Right x
    x -> Left x

errors :: (HasLogFunc env, MonadIO f, MonadReader env f) => Error -> f a
errors = \case
  AST err -> do
    logError "Problem converting to our AST"
    logError (display err)
    liftIO exitFailure
  Parse err -> do
    logError "Problem parsing module"
    logError (displayShow err)
    liftIO exitFailure