module DSLFFI where

import Foreign.C
import Foreign.StablePtr

import DSL (DSL)
import qualified DSL as D

import Data.IVar.Simple (IVar)
import qualified Data.IVar.Simple as IVar

import Control.Concurrent.STM

import System.IO.Unsafe

foreign export ccall output :: StablePtr (TChan (DSL ())) -> CString -> IO ()
foreign export ccall input  :: StablePtr (TChan (DSL ())) -> IO CString

output :: StablePtr (TChan (DSL ())) -> CString -> IO ()
output m cs = do
  s    <- peekCString cs
  chan <- deRefStablePtr m
  atomically . writeTChan chan $ do
    D.output s

input :: StablePtr (TChan (DSL ())) -> IO CString
input m = do
  ivar <- IVar.new
  chan <- deRefStablePtr m
  atomically . writeTChan chan $ do
    s <- D.input
    return $! (unsafePerformIO $ IVar.write ivar s)
  newCString $ IVar.read ivar
