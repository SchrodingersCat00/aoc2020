module Day24
    ( solve
    ) where

import NanoParsec
import Control.Applicative ( Alternative((<|>)) )
import Data.Set(empty, Set, insert, delete, member, fromList, intersection, union)
import Data.Functor ( ($>) )
import Day17 (neighbourCoords)

data Direction
    = East
    | Southeast
    | Southwest
    | West
    | Northwest
    | Northeast
    deriving ( Show )

type HexCoord = (Int, Int, Int)
type Path = [Direction]

solve :: IO ()
solve = do
    f <- readFile "data/day24.txt"
    let ps = runParser fileParser f
    putStr "Part1: "
    let w = foldl addPathToFlip empty ps
    print $ length w
    putStr "Part2: "
    print $ length $ nSimulationSteps w 1

nSimulationSteps :: Set HexCoord -> Int -> Set HexCoord
nSimulationSteps cs 0 = cs
nSimulationSteps cs n = nSimulationSteps (simulationStep cs) (n-1)

simulationStep :: Set HexCoord -> Set HexCoord
simulationStep s = foldl (processTile s) s s

-- base acc c newacc
processTile :: Set HexCoord -> Set HexCoord -> HexCoord -> Set HexCoord
processTile b acc c = listUnion $ map (processTile' b acc) (c:neighbourCoords c)

listUnion :: (Ord a) => [Set a] -> Set a
listUnion = foldl union empty

processTile' :: Set HexCoord -> Set HexCoord -> HexCoord -> Set HexCoord
processTile' b acc c
    | shouldFlip b c = flipTile acc c
    | otherwise = acc


flipTile :: Set HexCoord -> HexCoord -> Set HexCoord
flipTile s c = if c `member` s
               then delete c s
               else insert c s

shouldFlip :: Set HexCoord -> HexCoord -> Bool
shouldFlip s c = let nnbs = countBlackNeighbours s c
                 in if c `member` s
                    then nnbs == 0 || nnbs > 2
                    else nnbs == 2

countBlackNeighbours :: Set HexCoord -> HexCoord -> Int
countBlackNeighbours s c = let nbcs = fromList $ neighbourCoords c
                           in  length $ intersection nbcs s

addPathToFlip :: Set HexCoord -> Path -> Set HexCoord
addPathToFlip s p = let c = coordFromPath p
                    in flipTile s c

coordFromPath :: Path -> HexCoord
coordFromPath = foldl takeStep (0, 0, 0)

takeStep :: HexCoord -> Direction -> HexCoord
takeStep (x, y, z) East      = (x + 1, y - 1, z)
takeStep (x, y, z) Southeast = (x, y - 1, z + 1)
takeStep (x, y, z) Southwest = (x - 1, y, z + 1)
takeStep (x, y, z) West      = (x - 1, y + 1, z)
takeStep (x, y, z) Northwest = (x, y + 1, z - 1)
takeStep (x, y, z) Northeast = (x + 1, y, z - 1)

directionParser :: Parser Direction
directionParser =
      string "e"  $> East
  <|> string "se" $> Southeast
  <|> string "sw" $> Southwest
  <|> string "w"  $> West
  <|> string "nw" $> Northwest
  <|> string "ne" $> Northeast

pathParser :: Parser Path
pathParser = do
    plus directionParser

fileParser :: Parser [Path]
fileParser = do
    plus $ pathParser <* spaces