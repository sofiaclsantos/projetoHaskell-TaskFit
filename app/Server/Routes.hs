{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Server.Routes where

import Api.Model
import Control.Monad.IO.Class
import Control.Monad.Except
import Database.PostgreSQL.Simple
import Data.Proxy
import Data.Aeson (Value, object, (.=))
import Network.Wai
import Servant.API
import Servant.Server

type API =
         "aluno" :> ReqBody '[JSON] Aluno :> Post '[JSON] ResultadoResponse
    :<|> "aluno" :> Capture "id" Int :> Get '[JSON] Value
    :<|> "aluno" :> Capture "id" Int :> ReqBody '[JSON] Aluno :> Put '[JSON] ResultadoResponse
    :<|> "aluno" :> Capture "id" Int :> DeleteNoContent
    :<|> "aluno" :> Capture "id" Int :> Verb 'OPTIONS 200 '[JSON] ()
    :<|> "aluno" :> Verb 'OPTIONS 200 '[JSON] ()
    :<|> "aluno" :> Get '[JSON] AlunoResponse


handlerAluno :: Connection -> Aluno -> Handler ResultadoResponse
handlerAluno conn alu = do
    res <- liftIO $
        query conn
            "INSERT INTO Aluno (nome, cpf, telefone, idade, peso, altura) \
            \VALUES (?,?,?,?,?,?) RETURNING id"
            (nome alu, cpf alu, telefone alu, idade alu, peso alu, altura alu)

    case res of
        [Only novoId] -> pure (ResultadoResponse novoId)
        _ -> throwError err500

handlerAlunoTodos :: Connection -> Handler AlunoResponse
handlerAlunoTodos conn = do 
    res <- liftIO $
        query_ conn "SELECT id, nome, cpf, telefone, idade, peso, altura FROM Aluno"

    let result = map
            (\(id', n, c, t, i, p, a) -> Aluno id' n c t i p a)
            res

    pure (AlunoResponse result)

handlerAlunoPorId :: Connection -> Int -> Handler Value
handlerAlunoPorId conn ident = do
    res <- liftIO $
        query conn
            "SELECT id, nome, cpf, telefone, idade, peso, altura FROM Aluno WHERE id = ?"
            (Only ident)

    case res of
        [(id', n, c, t, i, p, a)] ->
            pure $ object
                [ "aluno" .= Aluno id' n c t i p a ]
        _ -> throwError err404
        
handlerAtualizar :: Connection -> Int -> Aluno -> Handler ResultadoResponse
handlerAtualizar conn ident alu = do
    _ <- liftIO $
        execute conn
            "UPDATE Aluno SET nome=?, cpf=?, telefone=?, idade=?, peso=?, altura=? WHERE id=?"
            (nome alu, cpf alu, telefone alu, idade alu, peso alu, altura alu, ident)
    pure (ResultadoResponse ident)


handlerExcluir :: Connection -> Int -> Handler NoContent
handlerExcluir conn ident = do
    _ <- liftIO $
        execute conn "DELETE FROM Aluno WHERE id=?" (Only ident)
    pure NoContent


options :: Handler ()
options = pure ()

optionsId :: Connection -> Int -> Handler ()
optionsId _ _ = pure ()


server :: Connection -> Server API
server conn =
       handlerAluno conn
    :<|> handlerAlunoPorId conn
    :<|> handlerAtualizar conn
    :<|> handlerExcluir conn
    :<|> optionsId conn 
    :<|> options
    :<|> handlerAlunoTodos conn


addCorsHeader :: Middleware
addCorsHeader app' req resp =
  app' req $ \res ->
    resp $ mapResponseHeaders
      ( \hs ->
          [ ("Access-Control-Allow-Origin", "*")
          , ("Access-Control-Allow-Headers", "content-type")
          , ("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
          ] ++ hs
      )
      res

app :: Connection -> Application
app conn = addCorsHeader (serve (Proxy @API) (server conn))
