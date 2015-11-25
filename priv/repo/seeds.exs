# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SeatSaver.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Enum.map 1..12, &(SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: &1, occupied: (&1 < 3)}))
