defmodule InfinityAPS.Oref0.PredictedBG do
  def apply_timestamp(bgs, start_timestamp) do
    bgs
    |> Enum.reduce([], fn(bg, acc) ->
      timestamp = Timex.shift(start_timestamp, minutes: (5 * length(acc)))
      [timestamp_bg(bg, timestamp) | acc]
    end)
    |> Enum.reverse()
  end

  defp timestamp_bg(bg, timestamp) do
    %{
      "bg" => bg,
      "dateString" => Timex.format!(timestamp, "{ISO:Extended:Z}")
    }
  end
end
