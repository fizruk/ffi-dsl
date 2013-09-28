module Foreign.DSL.Internal where

import Foreign.StablePtr
import Control.Concurrent.STM
import Control.Monad.Parallel (forkExec)
import System.IO.Unsafe

import qualified Data.IVar.Simple as IVar

type DSLChunks d = StablePtr (TChan (d ()))

genDSL :: (Monad d) => DSLChunks d -> d a -> IO a
genDSL ptr m = do
  ivar <- IVar.new
  chan <- deRefStablePtr ptr
  atomically . writeTChan chan $ do
    res <- m
    return $! (unsafePerformIO $ IVar.write ivar res)
  return $ IVar.read ivar

genDSL_ :: (Monad d) => DSLChunks d -> d a -> IO ()
genDSL_ ptr m = do
  chan <- deRefStablePtr ptr
  atomically . writeTChan chan $ m >> return ()

runForeignDSL :: (Monad d) => (DSLChunks d -> IO ()) -> IO (d ())
runForeignDSL ff = do
  chan <- atomically newTChan
  ptr  <- newStablePtr chan
  mprog <- forkExec $ ff ptr
  mres  <- forkExec $ readDSLChunks chan
  unsafeInterleaveIO mprog
  mres
  where
    readDSLChunks chan = do
      stmt <- atomically $ readTChan chan
      rest <- unsafeInterleaveIO $ readDSLChunks chan
      return $ stmt >> rest
