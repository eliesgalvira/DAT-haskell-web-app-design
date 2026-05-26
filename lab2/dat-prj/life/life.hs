
{-# LANGUAGE OverloadedStrings #-}

module Main where
import Life.Board
import Life.Draw

import Drawing
import Drawing.Activity
import Drawing.Vector

import Control.Exception (IOException, try)
import Control.Monad (when)
import Data.Aeson (eitherDecode, encode)
import qualified Data.ByteString.Lazy as B
import qualified Data.Text as T

-----------------------------------------------------
-- The game state

data Game = Game
        { gmBoard :: Board      -- last board generation
        , gmGridMode :: GridMode
        , gmZoom :: Double
        , gmShift :: Point
        , gmShowHelp :: Bool
        }

data GridMode = NoGrid | LivesGrid | ViewGrid
    deriving (Eq, Show)

-----------------------------------------------------
-- Initialization

viewWidth, viewHeight :: Double
viewWidth = 60.0
viewHeight = 30.0

main =
    activityOfIO 3708 viewWidth viewHeight initial update view

boardFile :: FilePath
boardFile = "board.json"

board0Cells =
    [(-5, 0), (-4, 0), (-3, 0), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]

initial = Game
    { gmBoard = foldr (setCell True) initBoard board0Cells
    , gmGridMode = NoGrid
    , gmZoom = 1.0
    , gmShift = (0.0, 0.0)
    , gmShowHelp = True
    }

-----------------------------------------------------
-- Update state

data Action =
          NextStep
        | SetCell Point
        | ChangeGridMode
        | ZoomOut
        | ZoomIn
        | AddShift Point
        | ToggleHelp
        | StartLoad
        | EndLoad Board
        | Save
        | NoOp
        deriving (Eq, Show)

update :: Action -> UpdateM Game Action ()
update NoOp =
    pure ()
update NextStep =               -- Next generation
    modify $
        \game -> game{ gmBoard = nextGeneration (gmBoard game) }
update ChangeGridMode =
    modify $
        \game -> game{ gmGridMode = nextGridMode (gmGridMode game) }
update ZoomOut = do
    game <- get
    when (gmZoom game > 0.25) $
        put game{ gmZoom = gmZoom game / 2.0 }
update ZoomIn = do
    game <- get
    when (gmZoom game < 2.0) $
        put game{ gmZoom = gmZoom game * 2.0 }
update (AddShift shift) =
    modify $
        \game -> game{ gmShift = gmShift game ^+^ shift }
update ToggleHelp =
    modify $
        \game -> game{ gmShowHelp = not $ gmShowHelp game }
update StartLoad =
    deferIO loadBoard
update (EndLoad board) =
    modify $
        \game -> game{ gmBoard = board }
update Save = do
    game <- get
    deferIO_ $ B.writeFile boardFile (encode $ gmBoard game)
update (SetCell point) =  do    -- Set live/dead cells
    game <- get
    let pos = pointToPos game point
        brd = gmBoard game
    put game{ gmBoard = setCell (not $ cellIsLive pos brd) pos brd }

loadBoard :: IO Action
loadBoard = do
    result <- try (B.readFile boardFile) :: IO (Either IOException B.ByteString)
    case result of
        Left _ ->
            pure NoOp
        Right bytes ->
            case eitherDecode bytes of
                Right board -> pure $ EndLoad board
                Left _ -> pure NoOp

pointToPos :: Game -> Point -> Pos
pointToPos game point =
    let (x, y) = (1.0 / gmZoom game) *^ point ^-^ gmShift game
    in (round x, round y)

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
keyMap "O" = Just ZoomOut
keyMap "I" = Just ZoomIn
keyMap "H" = Just ToggleHelp
keyMap "S" = Just Save
keyMap "L" = Just StartLoad
keyMap "ARROWUP" = Just $ AddShift (0, -1)
keyMap "ARROWDOWN" = Just $ AddShift (0, 1)
keyMap "ARROWRIGHT" = Just $ AddShift (-1, 0)
keyMap "ARROWLEFT" = Just $ AddShift (1, 0)
keyMap _   = Nothing

draw :: Game -> Drawing
draw game =
    drawWorld game <> drawHelp game

drawWorld :: Game -> Drawing
drawWorld game =
    dilated (gmZoom game) $
        translated shiftX shiftY $
            drawGridForMode game <> drawBoard (gmBoard game)
    where
        (shiftX, shiftY) = gmShift game

drawHelp :: Game -> Drawing
drawHelp game
    | gmShowHelp game = foldMap drawLine $ zip [0..] helpLines
    | otherwise = blank
    where
        drawLine (n, line) =
            translated (-viewWidth / 2 + 1) (viewHeight / 2 - 1 - fromIntegral n) $
                dilated 0.7 $
                    atext startAnchor (T.pack line)
        helpLines =
            [ "N: next generation"
            , "G: grid mode (" ++ show (gmGridMode game) ++ ")"
            , "I/O: zoom in/out (" ++ show (gmZoom game) ++ ")"
            , "Arrows: move view " ++ show (gmShift game)
            , "H: show/hide help"
            , "S/L: save/load board.json"
            ]

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
        viewMin = pointToPos game (-viewWidth / 2, -viewHeight / 2)
        viewMax = pointToPos game (viewWidth / 2, viewHeight / 2)
