defmodule InfinityAPS.Monitor.NightscoutTreatmentsReporter do
  require Logger
  alias InfinityAPS.Configuration.Server

  # @treatments_url "#{Application.get_env(:nightscout, :url)}/api/v1/treatments.json?token=#{Application.get_env(:nightscout, :token)}"
  def loop do
    Logger.warn "Getting history values"
    history_response = Pummpcomm.Monitor.HistoryMonitor.get_pump_history(4800)
    Logger.warn "Got: #{inspect(history_response)}"
    with {:ok, entries} <- history_response do
      report_treatments(entries)
    end

    # Logger.warn "Getting sensor values"
    # cgm_response = Pummpcomm.Monitor.BloodGlucoseMonitor.get_sensor_values(480)
    # Logger.warn "Got: #{inspect(cgm_response)}"
    # with {:ok, entries} <- cgm_response do
    #   report_sgvs(entries)
    # end
  end

  def report_treatments(entries) do
    entries
    |> Enum.filter(&filter_history/1)
    |> Enum.reduce([], &group_history/2)
    |> Enum.reverse
    |> Enum.map(&map_history/1)
    |> TwilightInformant.Treatment.post(treatments_url())
  end

  defp treatments_url do
    "#{Server.get_config(:nightscout_url)}/api/v1/treatments.json?token=#{Server.get_config(:nightscout_token)}"
  end

  # , :basal_profile_start
  defp filter_history({entry, _}) when entry in [:bolus_normal, :bolus_wizard_estimate, :alarm_sensor, :cal_bg_for_ph], do: true
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

  defp group_history(entry, acc), do: [entry | acc]

  defp map_history({:cal_bg_for_ph, %{amount: amount, timestamp: timestamp}}) do
    %TwilightInformant.Treatment{eventType: "BG Check", created_at: formatted_time(timestamp),
                                 glucose: amount, glucoseType: "Finger"}
  end

  defp map_history({:alarm_sensor, %{amount: amount, alarm_type: alarm_type, timestamp: timestamp}}) do
    %TwilightInformant.Treatment{eventType: "Note", created_at: formatted_time(timestamp),
                                 notes: alarm_type, glucose: amount, glucoseType: "Sensor"}
  end

  defp map_history({:alarm_sensor, %{alarm_type: alarm_type, timestamp: timestamp}}) do
    %TwilightInformant.Treatment{eventType: "Note", created_at: formatted_time(timestamp), notes: alarm_type}
  end

  # bolus wizard with bolus
  defp map_history({:bolus_wizard_group,
                    %{bolus_wizard_estimate: %{carbohydrates: carbohydrates, bg: bg},
                      bolus_normal: %{amount: amount, timestamp: timestamp}}}) do
    %TwilightInformant.Treatment{eventType: "Meal Bolus", created_at: formatted_time(timestamp),
                                 carbs: carbohydrates, insulin: amount, glucose: bg, glucoseType: "BolusWizard"}
  end

  # bolus with no bolus wizard
  defp map_history({:bolus_wizard_group, %{bolus_normal: %{amount: amount, timestamp: timestamp}}}) do
    %TwilightInformant.Treatment{eventType: "Correction Bolus", created_at: formatted_time(timestamp), insulin: amount}
  end

  # bolus wizard with no bolus
  defp map_history({:bolus_wizard_estimate, %{carbohydrates: carbohydrates, timestamp: timestamp, bg: bg}}) do
    %TwilightInformant.Treatment{eventType: "Carb Correction", created_at: formatted_time(timestamp),
                                 carbs: carbohydrates, insulin: 0, glucose: bg, glucoseType: "BolusWizard"}
  end

  defp formatted_time(timestamp) do
    Timex.to_datetime(timestamp, :local)
    |> Timex.format!("{ISO:Extended}")
  end
end
