defmodule InfinityAPS.Monitor.NightscoutTreatmentsReporter do
  require Logger

  def loop(local_timezone) do
    history_response = Pummpcomm.Monitor.HistoryMonitor.get_pump_history(4800, local_timezone)
    with {:ok, entries} <- history_response do
      report_treatments(entries, local_timezone)
    end
  end

  def report_treatments(entries, local_timezone) do
    entries
    |> Enum.filter(&filter_history/1)
    |> Enum.reduce([], &group_history/2)
    |> Enum.reverse
    |> Enum.map(fn(entry) -> map_history(entry, local_timezone) end)
    |> TwilightInformant.post_treatments()
  end

  # , :basal_profile_start
  defp filter_history({entry, _}) when entry in [:bolus_normal, :bolus_wizard_estimate, :alarm_sensor, :cal_bg_for_ph], do: true
  defp filter_history({entry, _}) when entry in [:temp_basal, :temp_basal_duration], do: true
  defp filter_history(_), do: false

  defp group_history({:bolus_normal, entry_data}, acc) do
    [{:bolus_wizard_group, %{bolus_normal: entry_data}} | acc]
  end

  defp group_history({:bolus_wizard_estimate, entry_data}, [{:bolus_wizard_group, group} | acc]) do
    group = Map.put(group, :bolus_wizard_estimate, entry_data)
    [{:bolus_wizard_group, group} | acc]
  end

  defp group_history({:unabsorbed_insulin, entry_data}, [{:bolus_wizard_group, group} | acc]) do
    group = Map.put(group, :unabsorbed_insulin, entry_data)
    [{:bolus_wizard_group, group} | acc]
  end

  defp group_history({:temp_basal_duration, entry_data}, acc) do
    [{:temp_basal_group, %{temp_basal_duration: entry_data}} | acc]
  end

  defp group_history({:temp_basal, entry_data}, [{:temp_basal_group, group} | acc]) do
    group = Map.put(group, :temp_basal, entry_data)
    [{:temp_basal_group, group} | acc]
  end

  defp group_history(entry, acc), do: [entry | acc]

  defp map_history({:cal_bg_for_ph, %{amount: amount, timestamp: timestamp}}, local_timezone) do
    %{eventType: "BG Check", created_at: formatted_time(timestamp, local_timezone),
      glucose: amount, glucoseType: "Finger"}
  end

  defp map_history({:alarm_sensor, %{amount: amount, alarm_type: alarm_type, timestamp: timestamp}}, local_timezone) do
    %{eventType: "Note", created_at: formatted_time(timestamp, local_timezone),
      notes: alarm_type, glucose: amount, glucoseType: "Sensor"}
  end

  defp map_history({:alarm_sensor, %{alarm_type: alarm_type, timestamp: timestamp}}, local_timezone) do
    %{eventType: "Note", created_at: formatted_time(timestamp, local_timezone), notes: alarm_type}
  end

  # bolus wizard with bolus
  defp map_history({:bolus_wizard_group,
                    %{bolus_wizard_estimate: %{carbohydrates: carbohydrates, bg: bg},
                      bolus_normal: %{amount: amount, timestamp: timestamp}}}, local_timezone) do
    %{eventType: "Meal Bolus", created_at: formatted_time(timestamp, local_timezone),
      carbs: carbohydrates, insulin: amount, glucose: bg, glucoseType: "BolusWizard"}
  end

  # bolus with no bolus wizard
  defp map_history({:bolus_wizard_group, %{bolus_normal: %{amount: amount, timestamp: timestamp}}}, local_timezone) do
    %{eventType: "Correction Bolus", created_at: formatted_time(timestamp, local_timezone), insulin: amount}
  end

  # bolus wizard with no bolus
  defp map_history({:bolus_wizard_estimate, %{carbohydrates: carbohydrates, timestamp: timestamp, bg: bg}}, local_timezone) do
    %{eventType: "Carb Correction", created_at: formatted_time(timestamp, local_timezone),
                                 carbs: carbohydrates, insulin: 0, glucose: bg, glucoseType: "BolusWizard"}
  end

  defp map_history({:temp_basal_group, %{temp_basal_duration: temp_basal_duration, temp_basal: temp_basal}}, local_timezone) do
    %{rate: rate, rate_type: rate_type, timestamp: _timestamp} = temp_basal
    %{duration: duration, timestamp: timestamp} = temp_basal_duration
    %{eventType: "Temp Basal",
      created_at: formatted_time(timestamp, local_timezone),
      rate: rate,
      absolute: rate,
      temp: Atom.to_string(rate_type),
      duration: duration}
  end

  defp formatted_time(timestamp, local_timezone) do
    Timex.to_datetime(timestamp, local_timezone)
    |> Timex.format!("{ISO:Extended}")
  end
end
