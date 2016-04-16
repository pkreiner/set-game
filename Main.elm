
import Deal exposing (init, update, view)
import CardGenerator exposing (cardListGen, sampleCardsWithSet)
import StartApp.Simple exposing (start)
import Random
import Signal.Time exposing (startTime)
import Debug exposing (log)

time = log "StartTime" startTime

seed = Random.initialSeed 3
cards = Random.generate cardListGen seed
     |> fst

        
main =
  start
    { model = init cards
    , update = update
    , view = view
    }



