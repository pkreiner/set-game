module CardGenerator (cardGen, cardListGen, sampleCardsWithSet) where

import Deal exposing (Color(..), Number(..), Symbol(..), Shading(..), Card)
import Random
import Random.Extra

-- Some boilerplate for generating random cards. Unfortunately very
-- repetitive; I couldn't figure out how to get a random value of a
-- finite type.

colors = [Red, Green, Purple]
numbers = [One, Two, Three]
symbols = [Diamond, Oval, Squiggle]
shadings = [Solid, Striped, Open]

colorGen = Random.Extra.selectWithDefault Red colors
numberGen = Random.Extra.selectWithDefault One numbers
symbolGen = Random.Extra.selectWithDefault Diamond symbols
shadingGen = Random.Extra.selectWithDefault Solid shadings

cardGen : Random.Generator Card
cardGen = Random.map4
            (\ c n s h ->
               { color = c, number = n, symbol = s, shading = h })
            colorGen numberGen symbolGen shadingGen

-- cardGen = Random.map4 Card colorGen numberGen symbolGen shadingGen

numberOfCards = 12

cardListGen = Random.list numberOfCards cardGen


sampleCardsWithSet : List Card
sampleCardsWithSet =
  [ (Red, One, Diamond, Solid)
  , (Green, Two, Diamond, Solid)
  , (Purple, Three, Diamond, Solid)
  ]
  |> List.map toCard

toCard : (Color, Number, Symbol, Shading) -> Card
toCard (c, n, s, h) =
  {color = c, number = n, symbol = s, shading = h}
  

shuffle : List a -> Random.Generator (List a)
shuffle data =
  let -- if π is the permutation that sends ys to sorted(ys),
      -- (reorder xs ys) returns π(xs).
      reorder : List a -> List comparable -> List a
      reorder xs ys = List.map2 (,) xs ys
                    |> (List.sortBy snd)
                    |> List.map fst
      floatsGen = Random.list (List.length data) (Random.float 0 1)

  in
    Random.map (reorder data) floatsGen
