module Sandbox where

import String
import Time
import Html
import Keyboard
import Graphics.Element as Element
import Graphics.Collage as Collage
import Color
import Window
import Debug exposing (log)
import Random
import Mouse
import Signal.Time
import Signal.Extra

import Trainer


-- -- MODEL

-- (gameWidth, gameHeight) = (500, 500)
-- (halfWidth, halfHeight) = (250, 250)

-- type alias Ball =
--   { x : Float
--   , y : Float
--   , vx : Float
--   , vy : Float
--   }

-- type alias Game =
--   { ball : Ball
--   }

-- type alias Input =
--   { x : Int
--   , y : Int
--   , delta : Time.Time    
--   }

-- defaultGame : Game
-- defaultGame =
--   { ball = Ball 0 0 0 0 }
    

-- -- UPDATE

-- update : Input -> Game -> Game
-- update ({x, y, delta} as input) ({ball} as game) =
--   let inp = log "input" input
--       newBall = updateBall x y delta ball
--   in
--     { game | ball = newBall }
--       |> log "Game State"

-- updateBall : Int -> Int -> Time.Time -> Ball -> Ball
-- updateBall inpX inpY delta ball =
--   let a = 100
--       ax = a * inpX |> toFloat
--       ay = a * inpY |> toFloat
--       newBall =
--         { x = ball.x + delta * ball.vx
--         , y = ball.y + delta * ball.vy
--         , vx = ball.vx + delta * ax
--         , vy = ball.vy + delta * ay
--         }
--       wrappedBall = toroidalWrap (gameWidth, gameHeight) newBall
--   in
--     wrappedBall
      
-- toroidalWrap : (Int, Int) -> Ball -> Ball
-- toroidalWrap (w, h) ball =
--   let floatW = toFloat w
--       floatH = toFloat h
--   in
--     { ball | x = halfWidthWrap ball.x floatW
--            , y = halfWidthWrap ball.y floatH
--     }

-- halfWidthWrap : Float -> Float -> Float
-- halfWidthWrap x w =
--   x |> (+) (w/2)
--     |> (flip floatMod) w
--     |> (+) (-(w/2))
      
-- floatMod : Float -> Float -> Float
-- floatMod x y = x - (toFloat (floor (x / y))) * y

-- -- VIEW

-- view : (Int, Int) -> Game -> Element.Element
-- view (windowW, windowH) game =
--   let court : Collage.Form
--       court = Collage.rect gameWidth gameHeight
--                 |> Collage.filled Color.black
--       ball : Collage.Form
--       ball = Collage.circle 10
--                |> Collage.filled Color.white
--                |> Collage.move (game.ball.x, game.ball.y)
--   in
--     Element.container windowW windowH Element.middle <|
--     Collage.collage gameWidth gameHeight
--       [ court
--       , ball
--       ]


-- -- SIGNALS

-- main = Signal.map2 view Window.dimensions gameState

-- gameState : Signal Game
-- gameState = Signal.foldp update defaultGame input

-- timeDelta : Signal Time.Time
-- timeDelta = Signal.map Time.inSeconds (Time.fps 40)

-- input : Signal Input
-- input = Signal.map3 Input
--           (Signal.map .x Keyboard.arrows)
--           (Signal.map .y Keyboard.arrows)
--           timeDelta

type Event = A | B

type State = Up | Down
           

-- main :  Element.Element
main = Html.text <| toString <| (numberOfSets, n, fractionAreSets)

n = 100000
  
randomSets = Random.generate (Random.list n Trainer.cardsGenerator)
             (Random.initialSeed 0)
             |> fst

numberOfSets = List.length <| List.filter Trainer.isValidSet randomSets
                
fractionAreSets =
  (toFloat numberOfSets) / n
          
clickA : Signal Event
clickA = Mouse.clicks |> Signal.map (\_ -> A) |> Time.delay (Time.second)

clickB : Signal Event
clickB = Mouse.clicks |> Signal.map (\_ -> B) |> Time.delay (Time.second)

bothClicks : Signal Event
bothClicks = Signal.merge clickB clickA
       
