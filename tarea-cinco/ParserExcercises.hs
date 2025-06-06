-- Denise Souberville 223427
-- Bruno Monfort 173280
-- Nicolás Capellino 272778

module ParserExercises where

import Parsing
import Control.Applicative (Alternative((<|>)))


{- PRIMER EJERCICIO:
Dar un parser para strings 
"{ field1: bool, field2: int, field3: string }" 
el resultado debera ser una lista de tuplas con el nombre del field y el tipo asociado [(String,String)], un bnf del lenguaje es el siguiente:
record ::= { identifier : type ( , field : type )* }
type ::= bool | int | string
-}

oneField :: Parser (String, String)
oneField = do
    fieldName <- identifier
    _ <- symbol ":"
    aType <- symbol "bool" <|> symbol "int" <|> symbol "string"
    return (fieldName, aType)
    
fields :: Parser [(String, String)]
fields = do
    f  <- oneField
    fs <- many (do _ <- symbol ","; oneField)         
    return (f : fs)

record :: Parser [(String, String)]
record = do
    _ <- symbol "{"
    fs <- fields
    _ <- symbol "}"
    return fs

{- SEGUNDO EJERCICIO:
Ejercicio 6 del Hutton (pag. 194)
Extend the parser expr :: Parser Int to support subtraction and division,
and to use integer values rather than natural numbers, based upon the following
revisions to the grammar:
expr   ::= term (+ expr | - expr | ε)
term   ::= factor (* term | / term | ε)
factor ::= ( expr ) | int
int    ::= ..., -1, 0, 1, ...
-}

expr :: Parser Int
expr = do
  t <- term
  do symbol "+"
     e1 <- expr
     return (t + e1)
     <|> do symbol "-" 
            e2 <- expr
            return (t - e2)
     <|> return t

term :: Parser Int
term = do 
    f <- factor
    do symbol "*"
       t1 <- term
       return (f * t1)
       <|> do symbol "/"
              t2 <- term
              if t2 == 0
              then failure
              else return (f `div` t2)
       <|> return f

factor :: Parser Int
factor = do symbol "("
            e <- expr
            symbol ")"
            return e
         <|> integer


parseTest1 = parse expr "2 + 3 * 4"

parseTest2 = parse expr "10 - 2"

parseTest3 = parse expr "20 / 5"

parseTest4 = parse expr "8 / 0" -- Lo interpretamos como "Si falla, no le hagas 'parse'."

parseTest5 = parse expr "1 + 2 * (3 + 4) - 5"

parseTest6 = parse expr "-3 + 7"

parseTest7 = parse expr "1 + 2 * (2 + 6) / 4"