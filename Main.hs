module Main where

import Foreign.C
import Foreign.StablePtr

import DSL (DSL)
import qualified DSL as D

import Control.Concurrent.STM
import Control.Monad.Parallel (forkExec)

import Data.IVar.Simple

import Control.Monad

import System.IO.Unsafe

foreign import ccall "test.h test"
  test_c :: StablePtr (TChan (DSL ())) -> IO ()

test :: IO (DSL ())
test = do
  chan <- atomically newTChan
  ptr  <- newStablePtr chan
  mt <- forkExec $ test_c ptr
  mc <- forkExec $ readDSL chan
  unsafeInterleaveIO mt
  mc
  where
    readDSL chan = do
      stmt <- atomically $ readTChan chan
      rest <- unsafeInterleaveIO $ readDSL chan
      return $ stmt >> rest

main :: IO ()
main = do
  prg <- test
  D.runDSL prg
