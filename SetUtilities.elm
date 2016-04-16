module SetUtilities where

import List exposing (..)


allCombinations : Int -> List a -> List (List a)
allCombinations k list =
  if k <= 0 then [[]]
  else
    case list of
      []    -> []
      x::xs ->
        let withFirstElement =
              List.map ((::) x) (allCombinations (k-1) xs)
            withoutFirstElement =
              allCombinations k xs
        in
          withFirstElement ++ withoutFirstElement

allSameOrDifferent : List a -> Bool
allSameOrDifferent list = allSame list || allDifferent list
      
allSame : List a -> Bool
allSame list =
  case list of
    []         -> True
    (_::[])    -> True
    (x::y::ys) -> x == y && allSame (y::ys)

allDifferent : List a -> Bool
allDifferent xs = allDifferentHelper [] xs

allDifferentHelper : List a -> List a -> Bool
allDifferentHelper front back =
  case back of
    []      -> True
    (b::bs) -> (not (b `List.member` front)) &&
               allDifferentHelper (b::front) bs

reshape : Int -> Int -> List a -> List (List a)
reshape rows columns list =
  if length list == 0 then
    []
  else
    let thisRow = take columns list
        otherRows = reshape (rows - 1) columns (drop columns list)
    in
      thisRow :: otherRows
  
                                  
