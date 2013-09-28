module Main where

import Foreign.C
import Foreign.DSL

import DSL (DSL)
import qualified DSL as D

foreign import ccall "test.h test"
  test_c :: DSLChunks DSL -> IO ()

main :: IO ()
main = do
  prg <- runForeignDSL test_c
  D.runDSL prg
