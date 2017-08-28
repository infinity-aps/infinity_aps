defmodule InfinityAPS.Monitor.ProfileMonitor do
  require Logger
  alias InfinityAPS.Configuration.Server
  alias Pummpcomm.Session.Pump

  def loop do
    Logger.debug "Reading profile information"

    with {:ok, bg_targets}            <- Pump.read_bg_targets(),
         {:ok, settings}              <- Pump.read_settings(),
         {:ok, carb_ratios}           <- Pump.read_carb_ratios(),
         {:ok, insulin_sensitivities} <- Pump.read_insulin_sensitivities(),
         {:ok, temp_basal}            <- Pump.read_temp_basal(),
         {:ok, model_number}          <- Pump.get_model_number(),
         %{preferences: preferences}  <- Server.get_config() do

      profile = format_profile(
        bg_targets: bg_targets,
        preferences: preferences,
        settings: settings,
        carb_ratios: carb_ratios,
        insulin_sensitivities: insulin_sensitivities,
        temp_basal: temp_basal,
        model_number: model_number
      )
      Logger.info fn() -> inspect(profile) end
      write_profile(profile)
    else
      error -> Logger.error fn() -> "Error while reading profile information: #{inspect(error)}" end
    end
  end

  defp format_profile(
    bg_targets: bg_targets, preferences: preferences, settings: settings,
    carb_ratios: carb_ratios, insulin_sensitivities: insulin_sensitivities,
    temp_basal: temp_basal, model_number: model_number) do

    %{
      max_iob: preferences.max_iob,
      max_daily_safety_multiplier: preferences.max_daily_safety_multiplier,
      current_basal_safety_multiplier: preferences.current_basal_safety_multiplier,
      # autosens_max: preferences.autosens_max,
      # autosens_min: preferences.autosens_min,
      # adv_target_adjustments: preferences.adv_target_adjustments,
      # override_high_target_with_low: false,
      # skip_neutral_temps: false,
      # bolussnooze_dia_divisor: 2,
      # min_5m_carbimpact: 3,
      carbratio_adjustmentratio: 1,
      dia: 4,
      model: Integer.to_string(model_number),
      current_basal: temp_basal.units_per_hour
    }
  end

  defp write_profile(profile) do
    loop_dir = Application.get_env(:infinity_aps, :loop_directory) |> Path.expand()
    File.mkdir_p!(loop_dir)

    File.write!("#{loop_dir}/profile.json", Poison.encode!(profile), [:binary])
  end
end
