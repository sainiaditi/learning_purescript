module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Monoid (class Monoid)

data Shape = Circle Point Number
  | Rectangle Point Number Number
  | Line Point Point
  | Text Point String

data Point = Point { x :: Number, y :: Number}

createPoint :: Number -> Number -> Point
createPoint x y = Point {x, y}

exampleLine :: Shape
exampleLine = Line p1 p2
  where
    p1 :: Point
    p1 = Point { x: 0.0, y: 0.0 }

    p2 :: Point
    p2 = Point { x: 100.0, y: 50.0 }


anotherShape :: Shape
anotherShape = Circle (Point {x : 50.0, y : 50.0}) 100.0

moveXY :: Shape -> Number -> Number -> Shape
moveXY (Circle (Point {x,y}) radius) dx dy = (Circle (Point {x:(x + dx), y:(y + dy)}) radius)
moveXY (Rectangle (Point {x,y}) w h) dx dy = (Rectangle (Point {x:(x + dx), y:(y + dy)}) w h)
moveXY (Line (Point {x:x0, y:y0}) (Point {x:x1, y:y1})) dx dy = (Line (Point {x:(x0 + dx), y:(y0 + dy)}) (Point {x:(x1 + dx), y:(y1 + dy)}))
moveXY (Text (Point {x,y}) text) dx dy = (Text (Point {x:(x+dx), y:(y+dy)}) text)


instance showPoint :: Show Point where
  show :: Point -> String
  show (Point {x, y}) = "Point : x=" <> (show x) <> ", y=" <> (show y)

-- showPoint :: Point -> String
-- showPoint (Point {x, y}) = "Point : x=" <> (show x) <> ", y=" <> (show y)

instance showShape :: Show Shape where
    show :: Shape -> String
    show (Circle p@(Point {x,y}) radius) = "Circle, " <> (show p) <> " , radius=" <> (show radius)
    show (Rectangle p@(Point {x,y}) w h) = "Rectangle, " <> (show p) <> ", width=" <> (show w) <> ", height=" <> (show h)
    show (Line p0@(Point {x:x0, y:y0}) p1@(Point {x:x1, y:y1})) = "Line, " <> (show p0) <> ", " <> (show p1)
    show (Text p@(Point {x,y}) text) = "Text, " <> (show p) <> ", Text: " <> text

-- showShape :: Shape -> String
-- showShape (Circle p@(Point {x,y}) radius) = "Circle, " <> (show p) <> " , radius=" <> (show radius)
-- showShape (Rectangle p@(Point {x,y}) w h) = "Rectangle, " <> (show p) <> ", width=" <> (show w) <> ", height=" <> (show h)
-- showShape (Line p0@(Point {x:x0, y:y0}) p1@(Point {x:x1, y:y1})) = "Line, " <> (show p0) <> ", " <> (show p1)
-- showShape (Text p@(Point {x,y}) text) = "Text, " <> (show p) <> ", Text: " <> text


instance semiringPoint :: Semiring Point where
  add :: Point -> Point -> Point
  add (Point {x:x0, y:y0}) (Point {x:x1, y:y1}) = Point {x : (x0 + x1), y : (y0 + y1)}

  zero :: Point
  zero = Point {x:0.0, y:0.0}

  one :: Point
  one = Point {x:1.0, y:1.0}

  mul :: Point -> Point -> Point
  mul (Point {x:x0, y:y0}) (Point {x:x1, y:y1}) = Point {x : (x0 * x1), y : (y0 * y1)}

instance pointEq :: Eq Point where
  eq :: Point -> Point -> Boolean
  eq (Point {x:x0, y:y0}) (Point {x:x1, y:y1}) = (x0 == x1) && (y0 == y1)

instance shapeEq :: Eq Shape where
  eq :: Shape -> Shape -> Boolean
  eq (Circle p0 radius0) (Circle p1 radius1) = (p0 == p1) && (radius0 == radius1)
  eq (Rectangle p0 w0 h0) (Rectangle p1 w1 h1) = (p0 == p1) && (w0 == w1) && (h0 == h1)
  eq (Line p00 p01) (Line p10 p11) = (p00 == p10) && (p01 == p11)
  eq (Text p0 text0) (Text p1 text1) = (p0 == p1) && (text0 == text1)
  eq _ _ = false

instance pointOrd :: Ord Point where
  compare :: Point -> Point -> Ordering
  compare p0@(Point {x:x0, y:y0}) p1@(Point {x:x1, y:y1}) = if p0 == p1
                                                               then EQ
                                                               else if x0 > x1
                                                                        then GT
                                                                        else LT


instance semigroupPoint :: Semigroup Point where
  append :: Point -> Point -> Point
  append first second = first + second

-- in purescript-monoid package. so "bower install purescript-monoid --save"
instance monoidPoint :: Monoid Point where
  mempty :: Point
  mempty = Point {x:0.0, y:0.0}

class DoingCalc a where
  doCalc :: a -> Int

instance sCalc :: DoingCalc Shape where
  doCalc :: Shape -> Int
  doCalc (Circle p radius) = 1
  doCalc (Rectangle p w h) = 2
  doCalc (Line p0 p1) = 5
  doCalc (Text p text) = 4


instance shapeCalc :: DoingCalc Shape where
  doCalc :: Shape -> Int
  doCalc (Circle p radius) = 1
  doCalc (Rectangle p w h) = 2
  doCalc (Line p0 p1) = 3
  doCalc (Text p text) = 4

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = log $ show $ doCalc anotherShape
