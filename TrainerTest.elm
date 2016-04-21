module TrainerTest where

import ElmTest exposing (..)
import List
import Random
import Graphics.Element exposing (Element)

import Trainer


tests : Test
tests = suite "All tests"
        [ validSetGeneratorTest
        , offByOneSetGeneratorTest
        ]

validSetGeneratorTest : Test
validSetGeneratorTest =
  let supposedlyValidSets =
        Random.generate (Random.list 100 Trainer.validSetGenerator)
                        (Random.initialSeed 0)
        |> fst
  in
    test "validSetGenerator produces valid sets"
         (assert (List.all Trainer.isValidSet supposedlyValidSets))
           
offByOneSetGeneratorTest : Test
offByOneSetGeneratorTest =
  let almostSets =
        Random.generate (Random.list 100 Trainer.offByOneSetGenerator)
                        (Random.initialSeed 0)
        |> fst
  in
    test "offByOneSetGenerator produces invalid sets"
         (assert (not (List.any Trainer.isValidSet almostSets)))
           
main : Element
main = elementRunner tests
