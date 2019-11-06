module Model exposing (..)


import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Http exposing (Response(..), Error(..))


type alias Todo =
    { id : String 
    , title : String
    , ts : Int
    , done : Bool
    }


todoDecoder : Decoder Todo
todoDecoder =
    JD.map4 Todo
        (JD.maybe (JD.field "id" JD.string)
            |> JD.map (Maybe.withDefault "")
        )
        (JD.field "title" JD.string)
        (JD.field "ts" JD.int)
        (JD.field "done" JD.bool)


todoEncoder : Todo -> JE.Value
todoEncoder todo =
    JE.object
        [ ("id", JE.string todo.id)
        , ("title", JE.string todo.title)
        , ("ts", JE.int todo.ts)
        , ("done", JE.bool todo.done)
        ]
