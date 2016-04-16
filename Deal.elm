module Deal where

import List exposing (..)
import String
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Debug exposing (log)
import Color exposing (..)
import Graphics.Element exposing (..)

import SetUtilities exposing (..)


-- MODEL

type Color = Red | Green | Purple
type Number = One | Two | Three
type Symbol = Diamond | Oval | Squiggle
type Shading = Solid | Striped | Open

type alias Card =
  { color : Color
  , number : Number
  , symbol : Symbol
  , shading : Shading
  }

type alias Index = Int
                
type alias Model =
    { cards : List Card
    , selected : List Index
    , isSetSelected : Bool    
    -- , rows : Int
    -- , columns : Int    
    }

init : List Card -> Model
init cardList =
    { cards = cardList
    , selected = []
    , isSetSelected = False    
    }


-- UPDATE

type Action = ToggleSelection Index

update : Action -> Model -> Model

update (ToggleSelection index) model =
  if List.member index model.selected then
    { model | selected = List.filter (\x -> x /= index) model.selected }
  else
    if List.length model.selected < 3 then
      { model | selected = index :: model.selected }
      |> setChecker
      |> resetModelIfSetFound
    else
      model

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let cardsWithAddressAndSelection :
        List (Maybe (Signal.Address Action, Index, Bool), Card)
      cardsWithAddressAndSelection =
        model.cards
          |> List.indexedMap (,)
          |> List.map
             (\ (i, card) ->
                (Just (address, i, (List.member i model.selected)), card))
                         
      cardViewList : List Element
      cardViewList = List.map viewCard cardsWithAddressAndSelection
      cardViewMatrix : List (List Element)
      cardViewMatrix = reshape 3 4 cardViewList
      cardViewGrid : Element
      cardViewGrid = flow down (map (flow right) cardViewMatrix)
  in
    fromElement cardViewGrid
      

viewCard : (Maybe (Signal.Address Action, Index, Bool), Card) -> Element
viewCard (msgAndSelectionInfo, card) =
  let imagePath = cardToImagePath card
      width = 148
      height = 210
  in
    case msgAndSelectionInfo of
      Nothing ->
        div [ imgStyle imagePath ] []
          |> toElement width height
            
      Just (address, index, isSelected) ->
        div [ imgStyle imagePath
            , onClick address (ToggleSelection index)
            ]
          []
          |> toElement width height
          |> if isSelected then addGreyBackground else identity

            
addGreyBackground : Element -> Element
addGreyBackground element =
  element |> opacity 0.5
          |> color grey
       

imgStyle : String -> Attribute
imgStyle filePath =
  let initialSize = (296, 421)
      scaling = 0.5
      size = initialSize
             |> (\ (w, h) -> (scaling * w, scaling * h))
  in
    style
      [ ("background-image", ("url('" ++ filePath ++ "')"))
      , ("background-size", "cover")
      , ("background-position", "center center")
      , ("display", "inline-block")
      , ("width", (toString <| fst size) ++ "px")
      , ("height", (toString <| snd size) ++ "px")    
      ]


-- HELPER FUNCTIONS

cardsOfIndices : Model -> List Index -> List Card
cardsOfIndices model indices =
  model.cards
    |> List.indexedMap (,)
    |> List.filter (\ (index, card) -> index `List.member` indices)
    |> List.map (\ (index, card) -> card)

cardToImagePath : Card -> String
cardToImagePath card =
  let dirName = "images/cards/"
      baseName = cardToImageBasename card
  in
    dirName ++ baseName
        
cardToImageBasename : Card -> String
cardToImageBasename card =
  [ toString card.color
  , toString card.number
  , toString card.symbol
  , toString card.shading
  ] |> List.map String.toLower
    |> String.join "-"
    |> (flip String.append) ".png"


resetModelIfSetFound : Model -> Model
resetModelIfSetFound model =
  if model.isSetSelected then
    { model | selected = [] }
  else
    model
  
allValidSets : Model -> List (List Card)
allValidSets = allCardTriples >> List.filter isValidSet
                                  
allCardTriples : Model -> List (List Card)
allCardTriples model =
  allCombinations 3 model.cards

isValidSet : List Card -> Bool
isValidSet cards =
     List.length cards == 3                          
  && (allSameOrDifferent <| List.map .color   cards)
  && (allSameOrDifferent <| List.map .number  cards)
  && (allSameOrDifferent <| List.map .symbol  cards)
  && (allSameOrDifferent <| List.map .shading cards)

selectedCards : Model -> List Card
selectedCards model =
  cardsOfIndices model model.selected

setChecker : Model -> Model
setChecker model =
  { model | isSetSelected =
      isValidSet (selectedCards model)
  }

      
                  
