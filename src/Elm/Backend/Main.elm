port module Backend.Main exposing (main)

import Platform
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Backend.Server as Server exposing (Method(..))
import Task
import Time exposing (Posix)
import Model exposing (..)
import Url.Parser as Parser exposing (Parser, (</>))


type Route
    = GetTodo String
    | GetTodos
    | PostTodo
    | UpdateTodo String
    | DeleteTodo String


parser : Server.Method -> Parser (Route -> a) a
parser method =
    case method of
        Get ->
            Parser.oneOf
                [ Parser.map GetTodo (Parser.s "todo" </> Parser.string)
                , Parser.map GetTodos (Parser.s "list")
                ]

        Post ->
            Parser.map PostTodo (Parser.s "todo")
        
        Put ->
            Parser.map UpdateTodo (Parser.s "todo" </> Parser.string)

        Delete ->
            Parser.map DeleteTodo (Parser.s "todo" </> Parser.string)


type Msg
    = NoOp
    | Request (Server.Request () Body)
    | GotTodo Todo
    | GotAllTodo (List Todo)
    | GetTime String Posix
    | EffectResult Bool


type Body
    = Todo_ Todo
    | Title String
    | NoOp_


type alias RequestData =
    Server.RequestData () Body



decoder : Decoder (Server.Request () Body)
decoder =
    Server.requestDecoder
        (JD.succeed ())
        (JD.oneOf
            [ JD.map Todo_ todoDecoder
            , JD.map Title (JD.field "title" JD.string)
            , JD.null NoOp_
            ]
        )


init : () -> ((), Cmd Msg)
init _ =
    ((), Cmd.none)


update : Msg -> () -> ((), Cmd Msg)
update msg model =
    case msg of
        Request (Server.Request url data) ->
            ( model
            , Parser.parse (parser data.method) url
                |> Maybe.map (effect data)
                |> Maybe.withDefault (response (404, JE.string "not found"))
            )

        GotTodo todo ->
            ( model
            , response (200, todoEncoder todo)
            )

        GotAllTodo todoList ->
            ( model
            , response (200, JE.list todoEncoder todoList)
            )
        
        GetTime title posix ->
            ( model
            , { id = ""
              , title = title
              , ts = Time.posixToMillis posix
              , done = False
              }
              |> todoEncoder
              |> storeTodo
            )

        EffectResult True ->
            ( model
            , requestAllTodo ()
            )
        
        EffectResult False ->
            ( model
            , response (500, JE.string "failed")
            )

        NoOp ->
            (model, response (404, JE.string "not found"))


effect : RequestData -> Route -> Cmd Msg
effect data subMsg =
    case (subMsg, data.body) of
        (GetTodo id, _) ->
            requestTodo id

        (GetTodos, _) ->
            requestAllTodo ()

        (PostTodo, Title title) ->
            Task.perform (GetTime title) Time.now
            
        
        (UpdateTodo id, Todo_ todo) ->
            updateTodo (id, todoEncoder todo)

        (DeleteTodo id, _) ->
            deleteTodo id

        _ ->
            response (404, JE.string "not found")


subscriptions : () -> Sub Msg
subscriptions _ =
    [ decoder
        |> JD.map Request
        |> JD.decodeValue
        |> request
        |> Sub.map (Result.withDefault NoOp)
    , result EffectResult
    , todoDecoder
        |> JD.map GotTodo
        |> JD.decodeValue
        |> getTodo
        |> Sub.map (Result.withDefault NoOp)
    , JD.list todoDecoder
        |> JD.map GotAllTodo
        |> JD.decodeValue
        |> getAllTodo
        |> Sub.map (Result.withDefault NoOp)
    ]
    |> Sub.batch


main : Program () () Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


-- PORT

port request : (JD.Value -> msg) -> Sub msg

port response : (Int, JE.Value) -> Cmd msg

port result : (Bool -> msg) -> Sub msg

port getTodo : (JD.Value -> msg) -> Sub msg

port getAllTodo : (JD.Value -> msg) -> Sub msg

port requestTodo : String -> Cmd msg

port requestAllTodo : () -> Cmd msg

port storeTodo : JE.Value -> Cmd msg

port updateTodo : (String, JE.Value) -> Cmd msg

port deleteTodo : String -> Cmd msg
