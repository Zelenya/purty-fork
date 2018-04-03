{-# LANGUAGE QuasiQuotes #-}
module Main where

import "protolude" Protolude

import "path" Path (Path, Rel, File, (</>), relfile)
import "tasty" Test.Tasty (TestTree, testGroup, defaultMain)
import "tasty-golden" Test.Tasty.Golden (goldenVsString)
import "prettyprinter" Data.Text.Prettyprint.Doc.Render.Text (renderLazy)
import "path-io" Path.IO (getCurrentDir)

import "purty" Purty (purty, runPurty, defaultEnv)

main :: IO ()
main = defaultMain goldenTests

goldenTests :: TestTree
goldenTests =
  testGroup
    "golden"
    [ goldenVsString "newtype record" "test/golden/files/NewtypeRecord.purs" (testPurty [relfile|test/golden/files/NewtypeRecord.purs|])
    ]

testPurty :: Path Rel File -> IO LByteString
testPurty filePath = do
  cwd <- getCurrentDir
  result <- runPurty (defaultEnv $ cwd </> filePath) purty
  stream <- hush result
  pure (toS $ renderLazy stream)
