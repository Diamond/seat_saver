module SeatSaver where

import StartApp
import Effects exposing (Effects, Never)
import Task exposing (Task)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

import Http
import Json.Decode as Json exposing ((:=))

app =
  StartApp.start
    { init   = init,
      update = update,
      view   = view,
      inputs = [] }

main : Signal Html
main =
  app.html

port tasks : Signal (Task Never ())
port tasks =
  app.tasks

-- MODEL

type alias Seat =
  { seatNo : Int,
    occupied : Bool }

type alias Model =
  List Seat

init : (Model, Effects Action)
init =
  ([], fetchSeats)

--init =
  --let
    --seats =
      --[ { seatNo = 1,  occupied = False },
        --{ seatNo = 2,  occupied = False },
        --{ seatNo = 3,  occupied = False },
        --{ seatNo = 4,  occupied = False },
        --{ seatNo = 5,  occupied = False },
        --{ seatNo = 6,  occupied = False },
        --{ seatNo = 7,  occupied = False },
        --{ seatNo = 8,  occupied = False },
        --{ seatNo = 9,  occupied = False },
        --{ seatNo = 10, occupied = False },
        --{ seatNo = 11, occupied = False },
        --{ seatNo = 12, occupied = False } ]
  --in
    --(seats, Effects.none)

-- UPDATE

type Action = Toggle Seat | SetSeats (Maybe Model)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Toggle seatToToggle ->
      let
        updateSeat seatFromModel =
          if seatFromModel.seatNo == seatToToggle.seatNo then
            { seatFromModel | occupied = not seatFromModel.occupied }
          else seatFromModel
      in
        (List.map updateSeat model, Effects.none)
    SetSeats seats ->
      let
        newModel = Maybe.withDefault model seats
      in
        (newModel, Effects.none)

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  ul [ class "seats" ] (List.map (seatItem address) model)

seatItem : Signal.Address Action -> Seat -> Html
seatItem address seat =
  let occupiedClass =
    if seat.occupied then "occupied" else "available"
  in
    li
      [ class ("seat " ++ occupiedClass),
        onClick address (Toggle seat) ]
      [ text (toString seat.seatNo) ]

-- EFFECTS

fetchSeats : Effects Action
fetchSeats =
  Http.get decodeSeats "http://localhost:4000/api/seats"
    |> Task.toMaybe
    |> Task.map SetSeats
    |> Effects.task

decodeSeats : Json.Decoder Model
decodeSeats =
  let
    seat =
      Json.object2 (\seatNo occupied -> (Seat seatNo occupied))
        ("seatNo"   := Json.int)
        ("occupied" := Json.bool)
  in
    Json.at ["data"] (Json.list seat)
