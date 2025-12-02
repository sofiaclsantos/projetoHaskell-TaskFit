{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module Server.Routes where 

import Api.Model
import Data.Proxy
import Network.Wai
import Servant.API.Sub
import Servant.API
import Servant.Server
import Database.PostgreSQL.Simple
import Control.Monad.IO.Class
import Control.Monad.Except

type API = 
         "aluno" :> ReqBody '[JSON] Aluno :> Post '[JSON] ResultadoResponse 
    :<|> "aluno"  :> Verb 'OPTIONS 200 '[JSON] ()
    :<|> "aluno" :> Get '[JSON] AlunoResponse

handlerAlunoTodos :: Connection -> Handler AlunoResponse
handlerAlunoTodos conn = do 
    res <- liftIO $ query_ conn 
        "SELECT id, nome, cpf, telefone, idade, peso, altura FROM Aluno" 
    let result = map 
            (\(id', nome', cpf', telefone', idade', peso', altura') ->
                Aluno id' nome' cpf' telefone' idade' peso' altura') 
            res
    pure (AlunoResponse result)

handlerAluno :: Connection -> Aluno -> Handler ResultadoResponse
handlerAluno conn alu = do 
    res <- liftIO $
        query conn
            "INSERT INTO Aluno (nome, cpf, telefone, idade, peso, altura) \
            \VALUES (?,?,?,?,?,?) RETURNING id"
            ( nome alu
            , cpf alu
            , telefone alu
            , idade alu
            , peso alu
            , altura alu
            )
    case res of 
        [Only novoId] -> pure (ResultadoResponse novoId)
        _ -> throwError err500


options :: Handler ()
options = pure ()


server :: Connection -> Server API 
server conn =    handlerAluno conn 
            :<|> options 
            :<|> handlerAlunoTodos conn

addCorsHeader :: Middleware
addCorsHeader app' req resp =
  app' req $ \res ->
    resp $ mapResponseHeaders
      ( \hs ->
          [ ("Access-Control-Allow-Origin", "*")
          , ("Access-Control-Allow-Headers", "Content-Type, Authorization")
          , ("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
          ] ++ hs
      )
      res

app :: Connection -> Application 
app conn = addCorsHeader (serve (Proxy @API) (server conn))