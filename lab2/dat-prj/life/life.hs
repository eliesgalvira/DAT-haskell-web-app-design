
{-# LANGUAGE OverloadedStrings #-}

module Main where
import Life.Board
import Life.Draw

import Drawing
import Drawing.Activity

import qualified Data.Text as T

-----------------------------------------------------
-- The game state

data Game = Game
        { gmBoard :: Board      -- last board generation
        , gmGridMode :: GridMode
        }

data GridMode = NoGrid | LivesGrid | ViewGrid
    deriving (Eq, Show)

-----------------------------------------------------
-- Initialization

viewWidth, viewHeight :: Double
viewWidth = 60.0
viewHeight = 30.0

main =
    activityOf 3708 viewWidth viewHeight initial update view

board0Cells =
    [(-5, 0), (-4, 0), (-3, 0), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]

initial = Game
    { gmBoard = foldr (setCell True) initBoard board0Cells
    , gmGridMode = NoGrid
    }

-----------------------------------------------------
-- Update state

data Action =
          NextStep
        | SetCell Point
        | ChangeGridMode
        deriving (Eq, Show)

update :: Action -> State Game ()
update NextStep =               -- Next generation
    modify $
        \game -> game{ gmBoard = nextGeneration (gmBoard game) }
update ChangeGridMode =
    modify $
        \game -> game{ gmGridMode = nextGridMode (gmGridMode game) }
update (SetCell point) =  do    -- Set live/dead cells
    game <- get
    let pos = pointToPos point
        brd = gmBoard game
    put game{ gmBoard = setCell (not $ cellIsLive pos brd) pos brd }

pointToPos :: Point -> Pos
pointToPos (x, y) = (round x, round y)

nextGridMode :: GridMode -> GridMode
nextGridMode NoGrid = LivesGrid
nextGridMode LivesGrid = ViewGrid
nextGridMode ViewGrid = NoGrid

-----------------------------------------------------
-- View state

view :: Game -> View Action
view game =
    drawingView
        [ onKeyDown' keyMap
        , onMouseDown SetCell
        ]
        $ draw game

keyMap :: T.Text -> Maybe Action
keyMap "N" = Just NextStep
keyMap "G" = Just ChangeGridMode
keyMap _   = Nothing

draw game =
    drawGridForMode game <> drawBoard (gmBoard game)

drawGridForMode :: Game -> Drawing
drawGridForMode game =
    case gmGridMode game of
        NoGrid ->
            blank
        LivesGrid ->
            drawGrid (minLiveCell board) (maxLiveCell board)
        ViewGrid ->
            drawGrid viewMin viewMax
    where
        board = gmBoard game
        viewMin = pointToPos (-viewWidth / 2, -viewHeight / 2)
        viewMax = pointToPos (viewWidth / 2, viewHeight / 2)
