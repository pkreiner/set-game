module CardGeneratorTest where

import ElmTest exposing (..)
import Random
import CardGenerator

shuffleTest : Test
shuffleTest =
  test "shuffle test"
       let list = [1, 2, 3, 4]
       in
         (assertEqual (length list)
            (length (CardGenerator.shuffle list)))


tests : Test
tests = suite "All tests"
        [ shuffleTest
        ]
  

main : Element
main = elementRunner tests

main : Element
main = elementRunner tests
