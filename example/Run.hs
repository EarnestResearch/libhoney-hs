{-# LANGUAGE OverloadedStrings #-}
module Run (run) where

import Import
import Network.Monitoring.Honeycomb.Trace

import qualified RIO.Set as Set

innerProgram2 :: RIO App ()
innerProgram2 =
    withNewSpan "inner2" (const mempty) $ do
        logInfo "We're inside the application!"

innerProgram :: RIO App ()
innerProgram = withNewSpan "inner" (const mempty) $ do
    addField "test" ("test" :: Text)
    void $ concurrently innerProgram2 innerProgram2

run :: RIO App ()
run = 
    withNewRootSpan "test_service" "outer" Nothing (const mempty) $
        withInheritableFields (const $ Set.singleton "test") $
          void $ concurrently innerProgram innerProgram
