
import Deal exposing (init, update, view)
import CardGenerator exposing (cardListGen, sampleCardsWithSet)
import StartApp.Simple exposing (start)
import Random
import Signal.Time exposing (startTime)
import Debug exposing (log)

import Sandbox
import Trainer

-- main =
--   start
--     { model = init cards 3 4
--     , update = update
--     , view = view
--     }

main = Sandbox.main

-- main = Trainer.main
