module DSL where

-- | DSL internal stricture.
-- Commands are nested (like in Free f).
data DSL a
  = Return a
  | Output String (DSL a)
  | Input (String -> DSL a)

instance Monad DSL where
  return = Return
  Return x   >>= f = f x
  Output s m >>= f = Output s (m >>= f)
  Input g    >>= f = Input (\s -> g s >>= f)

-- | Output command.
output :: String -> DSL ()
output s = Output s $ return ()

-- | Input command.
input :: DSL String
input = Input return

-- | One possible interpretation for DSL.
runDSL :: DSL a -> IO a
runDSL (Return x)   = return x
runDSL (Output s m) = putStrLn s >> runDSL m
runDSL (Input g)    = getLine >>= runDSL . g

-- | Test program in DSL.
test :: DSL ()
test = do
  output "Hello! What's your name?"
  name <- input
  output $ "Goodbye, " ++ name ++ "!"

