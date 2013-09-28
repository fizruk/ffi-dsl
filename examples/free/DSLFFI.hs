module DSLFFI where

import Foreign.C
import Foreign.DSL

import DSL (DSL)
import qualified DSL as D

import Control.Monad.Free

foreign export ccall output :: DSLChunks DSL -> CString -> IO ()
foreign export ccall input  :: DSLChunks DSL -> IO CString

output :: DSLChunks DSL -> CString -> IO ()
output m cs = do
  s <- peekCString cs
  genDSL_ m $ D.output s

input :: DSLChunks DSL -> IO CString
input m = do
  s <- genDSL m D.input
  newCString s

