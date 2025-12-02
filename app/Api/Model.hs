{-# LANGUAGE DeriveGeneric #-}
module Api.Model where

import Data.Aeson
import GHC.Generics

data ResultadoResponse = ResultadoResponse {
    resultado :: Int
} deriving (Show, Generic)

instance ToJSON ResultadoResponse where 

data Aluno = Aluno {
    id :: Int,
    nome :: String,
    cpf :: String,
    telefone :: String,
    idade :: Int,
    peso :: Double,
    altura :: Double
} deriving (Show, Generic)

instance FromJSON Aluno where 
instance ToJSON Aluno where 

data AlunoResponse = AlunoResponse {
    alunos :: [Aluno]
} deriving (Show, Generic)

instance ToJSON AlunoResponse where