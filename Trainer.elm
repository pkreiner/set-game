module Trainer where

import Set
import Debug
import String
import Keyboard
import Char
import Text
import Graphics.Element exposing (..)
import Time
import Random
import Random.Extra
import Color
import List.Extra
import Signal.Extra

import SetUtilities

-- MODEL

(gameWidth, gameHeight) = (1000, 500)
(halfWidth, halfHeight) = (round <| gameWidth / 2,
                           round <| gameHeight / 2)

endRoundDelay = 0.5 * Time.second
betweenRoundsDelay = 0.5 * Time.second

type alias Card = List String

type State = InRound | AfterResponse | BetweenRounds
                
type Event = Input Response | InternalEvent InternalEvent

type alias Response = Bool

type InternalEvent = EndRound | StartNextRound


type alias Game =
  { cards              : List Card
  , cardsMakeSet       : Bool
  , state              : State
  , displayText        : String
  }

defaultGame : Game
defaultGame =
  { cards = []
  , cardsMakeSet = False    
  , state = InRound
  , displayText = "Starting game"
  }


-- UPDATE

update : (Time.Time, Event) -> Game -> Game
update (time, event) game =
  case event of
    
    Input response ->
      if game.state == InRound then
        if response == game.cardsMakeSet then
          { game | state = AfterResponse
                 , displayText = "Correct!" }
        else
          { game | state = AfterResponse
                 , displayText = "Nope, sorry." }
      else
        game
              
    InternalEvent event ->
      case event of

        EndRound ->
          { game | state = BetweenRounds
                 , displayText = "" }
            
        StartNextRound ->
          let newCards = makeNewCards time
          in
            { game | cards = newCards
                   , cardsMakeSet = isValidSet(newCards)
                   , state = InRound
                   , displayText = "SPACE for yes, any other key for no." }


-- VIEW

view : Game -> Element
view ({cards, cardsMakeSet, state, displayText} as g) =
  let banner : Element
      banner = displayText
               |> Text.fromString
               |> Text.color Color.black
               |> Text.height 50
               |> Graphics.Element.centered
      cardsElement : Element
      cardsElement = viewCards cards
  in
    case state of
      BetweenRounds -> Graphics.Element.show ""
      _             -> Graphics.Element.flow
                         Graphics.Element.down
                         [banner, cardsElement]
           
viewCards : List Card -> Element
viewCards cards = Graphics.Element.flow
                    Graphics.Element.right
                    (List.map viewCard cards)

viewCard : Card -> Element
viewCard card =
  let baseName = (String.join "-" card) ++ ".png"
      dirName = "images/cards/"
      fullPath = dirName ++ baseName
      w = 200
      h = 300
      img = Graphics.Element.image w h fullPath
  in
    img
    |> Debug.log ("showing card " ++ baseName)


-- SIGNALS

main : Signal Graphics.Element.Element
main = Signal.map view game

game : Signal Game
game = Signal.foldp update defaultGame (Time.timestamp events)

-- seed : Signal Random.Seed
-- seed = Signal.Time.startTime
--        |> Signal.map Time.inMilliseconds
--        |> Signal.map round
--        |> Signal.map Random.initialSeed


events : Signal Event
events = Signal.merge (Signal.map Input responses)
                      (Signal.map InternalEvent internalEvents)

-- A discrete signal of keypresses. If more than one key is pressed at
-- a time, this will throw all but one away.
keypresses : Signal Char.KeyCode
keypresses =
  Keyboard.keysDown
  |> Signal.Extra.deltas
  |> Signal.map (\ (old, new) -> new `Set.diff` old)
  |> Signal.map Set.toList
  |> Signal.filterMap List.head (Char.toCode ' ')
            
responses : Signal Response
responses =
  let
    spaceCode = Char.toCode ' '
    interpretKey : Char.KeyCode -> Response
    interpretKey keycode = keycode == spaceCode
      -- case keycode of
        -- spaceCode -> True
        -- _         -> False
  in
    keypresses
      |> Signal.map interpretKey

internalEvents : Signal InternalEvent
internalEvents =
  let endRoundSignal       = Time.delay endRoundDelay
                             <| Signal.map (\ _ -> EndRound)
                             <| responses
                                
      startNextRoundSignal = Time.delay
                             (betweenRoundsDelay + endRoundDelay)
                             <| Signal.map (\ _ -> StartNextRound)
                             <| responses
  in
    Signal.merge endRoundSignal startNextRoundSignal

clock : Signal Time.Time
clock = Time.every (100 * Time.millisecond)


-- HELPER FUNCTIONS

makeNewCards : Time.Time -> List Card
makeNewCards time =
  let seed : Random.Seed
      seed = time |> Time.inMilliseconds |> round |> Random.initialSeed
  in
    Random.generate (sometimesValidSetGenerator 0.2) seed |> fst

-- Generates a length-3 list that is a set with probability slightly
-- greater than p.
sometimesValidSetGenerator : Float -> Random.Generator (List Card)
sometimesValidSetGenerator setProb =
  let p = setProb
      q = 1 - p
  in
    Random.Extra.frequency
          [(p, validSetGenerator), (q, offByOneSetGenerator)]
          cardsGenerator
  
validSetGenerator : Random.Generator (List Card)
validSetGenerator = Random.Extra.keepIf isValidSet cardsGenerator

offByOneSetGenerator : Random.Generator (List Card)
offByOneSetGenerator =
  Random.map4
  (\ set i j k ->
     let transposedSet = List.Extra.transpose set
         defaultProperties = ["red", "red", "red"]
         propertiesToMutate = safeGetNth defaultProperties i
                              transposedSet
         elementToMutate = safeGetNth "red" j propertiesToMutate
     
         allProperties = [colors, numbers, symbols, shadings]
         relevantProperties = safeGetNth colors i allProperties
         possibleReplacements = relevantProperties
                                |> List.filter
                                   (\ elt -> elt /= elementToMutate)
         replacement = safeGetNth "red" k possibleReplacements

         mutatedProperties = replaceNth replacement j propertiesToMutate
         mutatedSet = replaceNth mutatedProperties i transposedSet
                      |> List.Extra.transpose
     in
       mutatedSet )
  validSetGenerator
  (Random.int 0 3)
  (Random.int 0 2)
  (Random.int 0 1)


replaceNth : a -> Int -> List a -> List a
replaceNth newVal index list =
  if index < List.length list then
    (List.take index list) ++ [newVal] ++ (List.drop (index + 1) list)
  else
    list
                    
cardsGenerator : Random.Generator (List Card)
cardsGenerator = Random.list 3 cardGenerator
      
cardGenerator : Random.Generator Card
cardGenerator =
  List.map2 randomlySelectFrom
      defaultCard
      [colors, numbers, symbols, shadings]
  |> Random.Extra.flattenList

randomlySelectFrom : a -> List a -> Random.Generator a
randomlySelectFrom default list =
  let indexGen : Random.Generator Int
      indexGen = Random.int 0 ((List.length list) - 1)
      valGen = indexGen
               |> Random.map (\ index -> safeGetNth default index list)
  in
    valGen
    
getNth : Int -> List a -> Maybe a
getNth index list = List.head <| List.drop index list

safeGetNth : a -> Int -> List a -> a
safeGetNth default index list =
  Maybe.withDefault default (getNth index list)
                               
constGen : a -> Random.Generator a
constGen val =
  Random.map (\_ -> val) Random.bool
          
colors = ["red", "green", "purple"]
numbers = ["one", "two", "three"]
symbols = ["diamond", "oval", "squiggle"]
shadings = ["solid", "striped", "open"]

defaultCard = ["red", "one", "diamond", "solid"]         


isValidSet : List Card -> Bool
isValidSet cards =
  cards
  |> List.Extra.transpose
  |> List.map SetUtilities.allSameOrDifferent
  |> List.all ((==) True)


     
