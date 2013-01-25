{-#LANGUAGE NoImplicitPrelude, TemplateHaskell, FlexibleInstances #-}

module DX1
  ( -- * Format
    -- $format
    DX1Entry
    -- ** Calculations
  , sumCounts
  , frequencies
  , sortByFrequency
    -- * Parser
  , parseDX1
    -- * Example Program
  , main
  ) where

import Control.Applicative
import Control.Lens
import Control.Monad ((>=>), forM, liftM, join)
import Data.Function (on)
import Data.List (group, intersperse, sort, sortBy)
import System.Environment
import Text.ParserCombinators.Parsec hiding ((<|>), many, count)
import Text.Parsec.Prim (ParsecT)
import Prelude hiding (words)

{- Format -}

-- $format Every line of a @.dx1@ file contains a word, its number of
-- occurrences (in the corpus it originates from), and its pronunciation (as a
-- sequence of phonemes). Typically, this data is encoded in the form of a
-- space-separated string. For example:
--
-- > A 23310 AH0
-- > AARON 8 EH1 R AH0 N
-- > ABANDON 18 AH0 B AE1 N D AH0 N
-- > ABANDONED 26 AH0 B AE1 N D AH0 N D
--
-- In the interest of robustness, this library supports tab-separation between
-- a word's name, count, and pronunciation, as well as both @DOS@- and
-- @UNIX@-style newlines.


{- Datatype -}

-- | Stores a word, its number of occurrences, and its phonemes.
data DX1Entry a b = DX1Entry
  { _name      :: String
  , _count     :: Int
  , _phonemes  :: [String]
  , _frequency :: a
  , _rank      :: b }
  deriving (Eq)

makeLenses ''DX1Entry


{- Instances -}

-- NOTE: This uses the 'ParsecRead' trick specialized to 'DX1Entry' so as not to
-- require FlexibleInstances and UndecidableInstances.

-- | Read a @.dx1@ format 'DX1Entry' (uses 'Parsec' internally).
instance Read (DX1Entry () ()) where
  readsPrec _ = either (const []) id . parse parsecRead "" where
    parsecRead = do a <- dx1Entry; rest <- getInput; return [(a, rest)]

-- | Show a 'DX1Entry' in @.dx1@ format.
instance Show (DX1Entry () ()) where
  show (DX1Entry name count phonemes _ _) =
    name       ++ " " ++
    show count ++ " " ++
    unwords phonemes

instance Show (DX1Entry Float ()) where
  show (DX1Entry name count phonemes frequency _) =
    show frequency ++ " " ++ show (DX1Entry name count phonemes () ())

instance Show (DX1Entry Float Int) where
  show (DX1Entry name count phonemes frequency rank) =
    show rank ++ " " ++ show (DX1Entry name count phonemes frequency ())


{- Calculations -}

-- | Sum the counts of each 'DX1Entry' in a list.
sumCounts :: [DX1Entry a b] -> Int
sumCounts = sumOf (folded . count)

-- | Calculate the frequency of each 'DX1Entry' in a list.
frequencies :: [DX1Entry a b] -> [DX1Entry Float b]
frequencies entries =
    let n = fromIntegral $ sumCounts entries
    in  fmap (\e -> let c = fromIntegral $ e ^. count
                        f = c / n
                    in  (frequency .~ f) e
             ) entries

-- | /O(nlog n)/. Sort each 'DX1Entry' in a list by its frequency.
sortByFrequency :: [DX1Entry Float a] -> [DX1Entry Float a]
sortByFrequency = reverse . sortBy (compare `on` (^. frequency))

-- | Ranks each 'DX1Entry' in a list according to its position in the list (most
-- useful if you've preprocessed the list with 'sortByFrequency').
ranks :: [DX1Entry a b] -> [DX1Entry a Int]
ranks entries = zipWith (\e r -> (rank .~ r) e) entries [1..]

zipfConstant :: DX1Entry Float Int -> Float
zipfConstant e =
  let f = e ^. frequency
      r = fromIntegral $ e ^. rank
  in  f * r

averageZipfConstant :: [DX1Entry Float Int] -> Float
averageZipfConstant entries =
  let n  = fromIntegral $ length entries
      zs = map zipfConstant entries
  in  sum zs / n


{- Parsers -}

-- | Matches a 'DX1Entry'.
dx1Entry = pure DX1Entry
  <*> word   <* sep
  <*> digits <* sep
  <*> words  <* eol
  <*> pure ()
  <*> pure ()
                        
-- | Matches many 'DX1Entry's.
dx1File = dx1Entry `manyTill` eof

-- | Parses a @.dx1@ file to a list of 'DX1Entry's (uses 'Parsec' internally).
parseDX1 :: String -> Either ParseError [DX1Entry () ()]
parseDX1 = parse dx1File ""

-- | Matches a word.
word = many1 $ noneOf " \n\r"

-- | Matches a space-separated list of words.
words = word `sepEndBy1` char ' '

-- | Matches an integer.
digits = read <$> many1 digit

-- | Matches either a space or a tab.
sep = oneOf " \t"

-- | Matches both @DOS@- and @UNIX@-style newlines.
eol =  try (string "\r\n")
   <|> string "\n"
   <|> string "\r"


{- Example Program -}

-- | /O(nlog n)/. Parses a @.dx1@ file from @stdin@ or a given filename,
-- computes the frequency of each word, sorts by frequency in ascending order,
-- and prints the result.
main = do
  args <- getArgs
  case args of
    [] -> (liftM parseDX1FreqsRanksAndZipf >=> putStr) getContents
    paths -> mapM_ ((liftM parseDX1FreqsRanksAndZipf >=> putStr) . readFile) paths

parseDX1FreqsRanksAndZipf :: String -> String
parseDX1FreqsRanksAndZipf contents = case parseDX1 contents of
  Left  e -> "Error parsing input: " ++ show e
  Right r ->
    let es = ranks . sortByFrequency $ frequencies r
        z  = averageZipfConstant es
    in  unlines $ map show es ++ ['#' : show z]

parseDX1PhonemesToDX1 :: String -> String
parseDX1PhonemesToDX1 contents = case parseDX1 contents of
  Left  e -> "Error parsing input: " ++ show e
  Right r ->
    let ps = map (\xs@(x:_) -> (x, length xs)) . group . sort
           $ concatMap (^. phonemes) r
        es = map (\(p, c) -> DX1Entry p c [p] () ()) ps
    in  unlines $ map show es
