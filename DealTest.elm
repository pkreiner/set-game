module DealTest where

import Graphics.Element exposing (Element)
import ElmTest exposing (..)
import List exposing (..)

import Deal exposing (..)

sampleCardsWithSet : List Card
sampleCardsWithSet =
  [ (Red, One, Diamond, Solid)
  , (Green, Two, Diamond, Solid)
  , (Purple, Three, Diamond, Solid)
  ]
  |> List.map toCard
     
sampleCardsWithoutSet : List Card
sampleCardsWithoutSet =
  [ (Purple, One, Diamond, Open)
  , (Purple, Two, Diamond, Open)
  , (Purple, Two, Oval, Open)
  ]
  |> List.map toCard

allValidSetsTest : Test
allValidSetsTest  =
  suite "allValidSets test"
        [ test "Three-card list which is a set"
            (assertEqual [sampleCardsWithSet]
                         (allValidSets (cardsToModel sampleCardsWithSet)))
        , test "Three-card list which is not a set"
            (assertEqual []
                         (allValidSets (cardsToModel sampleCardsWithoutSet)))
        , test "Six-card list which contains a set"
            (assertEqual [sampleCardsWithSet]
                         (allValidSets
                            (cardsToModel
                               (sampleCardsWithSet ++ sampleCardsWithoutSet))))
        ]
        
       
allCombinationsTest : Test
allCombinationsTest =
  suite "allCombinations tests"
        [ test "Empty case"
            (assertEqual [[]] (allCombinations 0 []))
        , test "k=0 case"
            (assertEqual [[]] (allCombinations 0 [1]))
        , test "k=1 case"
            (assertEqual [[1], [2]] (allCombinations 1 [1, 2]))
        , test "k=2 case"
            (assertEqual [[1, 2], [1, 3], [2, 3]]
                         (allCombinations 2 [1, 2, 3]))
        , test "k=3 case"
            (assertEqual [[1, 2, 3], [1, 2, 4], [1, 3, 4], [2, 3, 4]]
                         (allCombinations 3 [1, 2, 3, 4]))
        , test "k>length case"
            (assertEqual [] (allCombinations 3 [1, 2]))
        ]

  
constructImageBasenameTest : Test
constructImageBasenameTest =
  test "constructImageBasename test"
       (assertEqual "red-one-diamond-solid.png"
          (constructImageBasename (toCard (Red, One, Diamond, Solid))))
    

reshapeTest : Test
reshapeTest =
  test "Reshape Test"
       (assertEqual [[1, 2], [3, 4]]
          (reshape 2 2 [1, 2, 3, 4]))
         
         
tests : Test
tests = suite "All tests"
        [ allCombinationsTest
        , allValidSetsTest
        , reshapeTest    
        ]
    
main : Element
main = elementRunner tests


-- HELPER FUNCTIONS

cardsToModel : List Card -> Model
cardsToModel someCards =
  { cards = someCards,
    selected = [],
    isSetSelected = False
  }

toCard : (Color, Number, Symbol, Shading) -> Card
toCard (c, n, s, h) =
  {color = c, number = n, symbol = s, shading = h}
