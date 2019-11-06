module Backend.Server exposing (..)


import Url exposing (Url)
import Json.Decode as JD exposing (Decoder)


type Request header body =
    Request Url (RequestData header body)


type alias RequestData header body =
    { method : Method
    , header : header
    , body : body
    }


type Method
    = Get
    | Post
    | Put
    | Delete


methodDecoder : String -> Decoder Method
methodDecoder method =
    case method of
        "GET" ->
            JD.succeed Get
        
        "POST" ->
            JD.succeed Post

        "PUT" ->
            JD.succeed Put

        "DELETE" ->
            JD.succeed Delete

        _ ->
            JD.fail "No match method"


requestDecoder : Decoder header -> Decoder body -> Decoder (Request header body)
requestDecoder headerDecoder bodyDecoder =
    let
        helper =
            JD.map3 RequestData
                (JD.field "method" (JD.string |> JD.andThen methodDecoder))
                (JD.field "header" headerDecoder)
                (JD.field "body" bodyDecoder)
    in
        JD.map2 Request
            (JD.string
                |> JD.map Url.fromString
                |> JD.andThen
                    (\x ->
                        case x of
                            Just url ->
                                JD.succeed url
                            
                            Nothing ->
                                JD.fail "not url"
                    )
                |> JD.field "url")
            helper
