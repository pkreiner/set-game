import Html exposing (text)

type alias Index = Int

type Action = ToggleSelection Index

f : Action -> Int
f (ToggleSelection n) = n + 1

main = text <| toString <| f <| ToggleSelection 0
