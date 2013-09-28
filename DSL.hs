{-# LANGUAGE DeriveFunctor #-}
module DSL where

import Control.Monad.Free

data DSLF next
  = Output String next
  | Input (String -> next)
  deriving (Functor)

type DSL = Free DSLF

-- | Output command.
output :: String -> DSL ()
output s = liftF $ Output s ()

-- | Input command.
input :: DSL String
input = liftF $ Input id

-- | One possible interpretation for DSL.
runDSL :: DSL a -> IO a
runDSL = iterM runF
  where
    runF (Output s next) = putStrLn s >> next
    runF (Input    next) = getLine >>= next

