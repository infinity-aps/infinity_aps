defmodule InfinityAPS.Oref0.PredictedBGTest do
  use ExUnit.Case

  alias InfinityAPS.Oref0.PredictedBG

  test "apply_timestamp sets the timestamp offsets at 5 minute intervals" do
    predicted_bgs = [89, 90, 91, 92, 93, 94]
    start_time = Timex.parse!("2017-11-05 00:00:00.000000Z", "{ISO:Extended}")

    expected_bg_result = [
      %{"bg" => 89, "dateString" => "2017-11-05T00:00:00.000000Z"},
      %{"bg" => 90, "dateString" => "2017-11-05T00:05:00.000000Z"},
      %{"bg" => 91, "dateString" => "2017-11-05T00:10:00.000000Z"},
      %{"bg" => 92, "dateString" => "2017-11-05T00:15:00.000000Z"},
      %{"bg" => 93, "dateString" => "2017-11-05T00:20:00.000000Z"},
      %{"bg" => 94, "dateString" => "2017-11-05T00:25:00.000000Z"}
    ]

    assert PredictedBG.apply_timestamp(predicted_bgs, start_time) == expected_bg_result
  end
end
