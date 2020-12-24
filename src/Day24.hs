module Day24
    ( solve
    ) where

import NanoParsec
import Control.Applicative ( Alternative((<|>)) )
import Data.Set(empty, Set, insert, delete, member)
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
    print $ length $ foldl addPathToFlip empty ps

addPathToFlip :: Set HexCoord -> Path -> Set HexCoord
addPathToFlip s p = let c = coordFromPath p
             in if c `member` s
                then delete c s
                else insert c s

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
      string "e" *> return East
  <|> string "se" *> return Southeast
  <|> string "sw" *> return Southwest
  <|> string "w" *> return West
  <|> string "nw" *> return Northwest
  <|> string "ne" *> return Northeast

pathParser :: Parser Path
pathParser = do
    plus directionParser

fileParser :: Parser [Path]
fileParser = do
    plus $ pathParser <* spaces