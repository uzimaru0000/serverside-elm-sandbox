module Frontend.Main exposing (main)


import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Model exposing (Todo)
import Http
import Frontend.Request as Request


type alias Model =
    { input : Maybe String
    , todo : List Todo
    }


type Msg
    = Input String
    | GetAllTodo (Result Http.Error (List Todo))
    | Submit
    | ChangeTodoState Todo
    | DeleteTodo String


init : () -> (Model, Cmd Msg)
init _ =
    ({ input = Nothing
     , todo = []
     }
    , Request.getAllTodo GetAllTodo
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetAllTodo (Ok todoList) ->
            ( { model | todo = todoList }, Cmd.none )

        Input str ->
            ( { model | input = Just str }, Cmd.none )

        Submit ->
            ( { model | input = Nothing }
            , model.input
                |> Maybe.map (Request.storeTodo GetAllTodo)
                |> Maybe.withDefault Cmd.none
            )


        ChangeTodoState todo ->
            ( model
            , Request.updateTodo GetAllTodo todo
            )


        DeleteTodo id ->
            ( model
            , Request.deleteTodo GetAllTodo id
            )


        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.div []
            [ Html.input
                [ Attr.value <| Maybe.withDefault "" model.input
                , Ev.onInput Input
                ]
                []
            , Html.button
                [ Ev.onClick Submit
                , model.input
                    |> Maybe.map String.isEmpty
                    |> Maybe.withDefault True
                    |> Attr.disabled
                ]
                [ Html.text "Add" ]
            ]
        , Html.ul []
            <| List.map todoView model.todo
        ]


todoView : Todo -> Html Msg
todoView todo =
    Html.li []
        [ Html.label
            []
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.checked todo.done
                , Ev.onCheck (\x -> ChangeTodoState { todo | done = x })
                ]
                []
            , Html.span
                [ Attr.style "padding" "0 8px" ]
                [ Html.text todo.title ]
            ]
        , Html.button
            [ Ev.onClick <| DeleteTodo todo.id ]
            [ Html.text "X" ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
