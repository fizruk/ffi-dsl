module DSLFFI where

import Foreign.C
import Foreign.StablePtr

import DSL (DSL)
import qualified DSL as D

import Data.IVar.Simple (IVar)
import qualified Data.IVar.Simple as IVar

import Control.Concurrent.STM
import Control.Monad.Free

import System.IO.Unsafe

type DSLChanPtr = StablePtr (TChan (DSL ()))

foreign export ccall output :: DSLChanPtr -> CString -> IO ()
foreign export ccall input  :: DSLChanPtr -> IO CString

output :: DSLChanPtr -> CString -> IO ()
output m cs = do
  s <- peekCString cs
  genDSL_ m $ D.output s

input :: DSLChanPtr -> IO CString
input m = do
  s <- genDSL m D.input
  newCString s

genDSL :: DSLChanPtr -> DSL a -> IO a
genDSL ptr m = do
  ivar <- IVar.new
  chan <- deRefStablePtr ptr
  atomically . writeTChan chan $ do
    res <- m
    return $! (unsafePerformIO $ IVar.write ivar res)
  return $ IVar.read ivar

genDSL_ :: DSLChanPtr -> DSL a -> IO ()
genDSL_ ptr m = do
  chan <- deRefStablePtr ptr
  atomically . writeTChan chan $ m >> return ()

