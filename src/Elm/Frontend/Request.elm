module Frontend.Request exposing (..)


import Task exposing (Task)
import Http exposing (Response(..), Error(..))
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Model exposing (Todo)


baseUrl : String
baseUrl =
    "http://localhost:3000"


resolver : Decoder a -> Response String -> Result Http.Error a
resolver decoder res =
    case res of
        GoodStatus_ _ str ->
            JD.decodeString decoder str
                |> Result.mapError (JD.errorToString >> BadBody)
        
        BadUrl_ str ->
            Result.Err <| BadUrl str

        Timeout_ ->
            Result.Err <| Timeout

        NetworkError_ ->
            Result.Err <| NetworkError

        BadStatus_ meta _ ->
            Result.Err <| BadStatus meta.statusCode


getAllTodo : (Result Error (List Todo) -> msg) -> Cmd msg
getAllTodo msg =
    Http.request
        { method = "GET"
        , headers = []
        , url = baseUrl ++ "/list"
        , body = Http.emptyBody
        , expect = Http.expectJson msg (JD.list Model.todoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


storeTodo : (Result Error (List Todo) -> msg) -> String -> Cmd msg
storeTodo msg title =
    Http.request
        { method = "POST"
        , headers = []
        , url = baseUrl ++ "/todo"
        , body = Http.jsonBody <| JE.object [ ( "title", JE.string title ) ]
        , expect = Http.expectJson msg (JD.list Model.todoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


updateTodo : (Result Error (List Todo) -> msg) -> Todo -> Cmd msg
updateTodo msg todo =
    Http.request
        { method = "PUT"
        , headers = []
        , url = String.join "/" [ baseUrl, "todo", todo.id ]
        , body = Http.jsonBody <| Model.todoEncoder todo
        , expect = Http.expectJson msg (JD.list Model.todoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


deleteTodo : (Result Error (List Todo) -> msg) -> String -> Cmd msg
deleteTodo msg id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = String.join "/" [ baseUrl, "todo", id ]
        , body = Http.emptyBody
        , expect = Http.expectJson msg (JD.list Model.todoDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }
