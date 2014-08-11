{-# LANGUAGE NoMonomorphismRestriction #-}

import Diagrams.Prelude
import Diagrams.Backend.SVG.CmdLine
import qualified Data.List as L

main = mainWith diagram


envArrow a b = connectPerim' opts a b (1/12 @@ turn) (30/32 @@ turn)
  where opts = with & arrowShaft .~ (arc (0 @@ turn) (1/6 @@ turn))
                    & arrowHead .~ tri
                    & headLength .~ large
                    & headStyle %~ fc black . opacity 0.5
                    & shaftStyle %~ lw veryThick . lc black . opacity 0.5

diagram = (cascadeEnvs [globalBinding, level1, level2]
          ) # envArrow "level1" "global" # envArrow "level2" "level1"

cascadeEnvs es = foldl (===) mempty $ L.intersperse (strutY 3) $ map offset $ zip es [0..]
  where offset (e, o) = strutX (6 * o) ||| e

globalBinding = description <> rect 8 4 # named "global" :: Diagram B R2
  where description = (text "parent: null" <> strutY (-1))
                      ===
                      (text "bindings: null" <> strutY 1)

level1 = description <> rect 8 4 # named "level1" :: Diagram B R2
  where description = (text "parent: null" <> strutY (-1))
                      ===
                      (text "bindings: null" <> strutY 1)

level2 = description <> rect 8 4 # named "level2" :: Diagram B R2
  where description = (text "parent: null" <> strutY (-1))
                      ===
                      (text "bindings: null" <> strutY 1)
