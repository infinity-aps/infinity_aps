defmodule InfinityAPS.Monitor.PumpHistoryMonitor do
  require Logger

  def loop do
    Logger.warn "Getting history values"
    history_response = Pummpcomm.Monitor.HistoryMonitor.get_pump_history(4800)
    Logger.warn "Got: #{inspect(history_response)}"
    with {:ok, history} <- history_response do
      write_history(history)
    end
  end

  def write_history(history) do
    loop_dir = Application.get_env(:infinity_aps, :loop_directory) |> Path.expand()
    File.mkdir_p!(loop_dir)

    encoded = history
    |> Enum.filter(&filter_history/1)
    |> Enum.map(&map_history/1)
    |> Poison.encode!

    File.write!("#{loop_dir}/history.json", encoded, [:binary])
  end

  defp filter_history({entry, _}) when entry in [:temp_basal, :temp_basal_duration, :bolus_wizard_estimate, :bolus_normal], do: true
  defp filter_history(_), do: false

  defp map_history({:temp_basal, %{rate: rate, rate_type: rate_type, timestamp: timestamp}}) do
    %{"_type" => "TempBasal", "timestamp" => formatted_time(timestamp), "rate" => rate, "temp" => Atom.to_string(rate_type)}
  end

  defp map_history({:temp_basal_duration, %{duration: duration, timestamp: timestamp}}) do
    %{"_type" => "TempBasalDuration", "timestamp" => formatted_time(timestamp), "duration (min)" => duration}
  end

  defp map_history({:bolus_normal, %{programmed: programmed, duration: duration, amount: amount, type: type, timestamp: timestamp}}) do
    %{
      "_type" => "Bolus",
      "timestamp" => formatted_time(timestamp),
      "programmed" => programmed,
      "duration" => duration,
      "amount" => amount,
      "type" => Atom.to_string(type)
    }
  end

  defp map_history({:bolus_wizard_estimate, data}) do
    %{
      "_type" => "BolusWizard",
      "timestamp" => formatted_time(data.timestamp),
      "bg" => data.bg,
      "bg_target_high" => data.bg_target_high,
      "bg_target_low" => data.bg_target_low,
      "bolus_estimate" => data.bolus_estimate,
      "carb_input" => data.carbohydrates,
      "carb_ratio" => data.carb_ratio,
      "correction_estimate" => data.correction_estimate,
      "food_estimate" => data.food_estimate,
      "sensitivity" => data.insulin_sensitivity,
      "unabsorbed_insulin_total" => data.unabsorbed_insulin_total
    }
  end

  defp formatted_time(timestamp) do
    Timex.to_datetime(timestamp, :local)
    |> Timex.format!("{ISO:Extended}")
  end
end
