module Main where

import Text.ParserCombinators.Parsec hiding (spaces)
import System.Environment
import Control.Monad

data LispVal = LispAtom String
             | LispList [LispVal]
             | LispDottedList [LispVal] LispVal
             | LispNumber Integer
             | LispString String
             | LispBool Bool
               deriving Show

main :: IO ()
main = do
  (expr:_) <- getArgs
  putStrLn (readExpr expr)

readExpr :: String -> String
readExpr input = 
    case parse parseExpr "lisp" input of
      Left err -> "No match: " ++ show err
      Right val -> "Found value: " ++ show val

parseExpr :: Parser LispVal
parseExpr = parseAtom
            <|> parseString
            <|> parseNumber

parseString :: Parser LispVal
parseString = do
  char '"'
  x <- many (noneOf "\"")
  char '"'
  return $ LispString x

parseAtom :: Parser LispVal
parseAtom = do
  first <- letter <|> symbol
  rest <- many (letter <|> digit <|> symbol)
  let atom = first:rest
  return $ case atom of
             "#t" -> LispBool True
             "#f" -> LispBool False
             _    -> LispAtom atom

parseNumber :: Parser LispVal
parseNumber = do
  digits <- many1 digit
  return $ (LispNumber . read) digits

symbol :: Parser Char
symbol = 
    oneOf "!#$%&|*+-/:<=>?@^_~"

spaces :: Parser ()
spaces = 
    skipMany1 space
