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
         {:ok, basal_profile}         <- Pump.read_std_basal_profile(),
         {:ok, model_number}          <- Pump.get_model_number(),
         %{preferences: preferences}  <- Server.get_config() do

      profile = format_profile(
        bg_targets: bg_targets,
        preferences: preferences,
        settings: settings,
        carb_ratios: carb_ratios,
        insulin_sensitivities: insulin_sensitivities,
        temp_basal: temp_basal,
        basal_profile: basal_profile,
        model_number: model_number
      )
      Logger.info fn() -> inspect(profile) end
      write_profile(profile)
    else
      error -> Logger.error fn() -> "Error while reading profile information: #{inspect(error)}" end
    end
  end

  defp format_profile(
    bg_targets: bg_targets, preferences: preferences, settings: _settings,
    carb_ratios: _carb_ratios, insulin_sensitivities: _insulin_sensitivities,
    temp_basal: temp_basal, basal_profile: basal_profile, model_number: model_number) do

    %{
      max_iob: preferences.max_iob,
      max_daily_safety_multiplier: preferences.max_daily_safety_multiplier,
      current_basal_safety_multiplier: preferences.current_basal_safety_multiplier,
      carbratio_adjustmentratio: 1,
      dia: 4,
      model: Integer.to_string(model_number),
      current_basal: temp_basal.units_per_hour,
      min_bg: 80,
      max_bg: 120,
      sens: 30,
      bg_targets: format_bg_targets(bg_targets),
      basalprofile: basal_profile.schedule
    }
  end

  defp format_bg_targets(bg_targets) do
    %{
      units: bg_targets.units,
      user_preferred_units: bg_targets.units,
      targets: Enum.map(bg_targets.targets, fn(target) ->
        %{
          min_bg: target.bg_low,
          max_bg: target.bg_high,
          start: Time.to_string(target.start)
        }
      end)
    }
  end

  defp write_profile(profile) do
    loop_dir = Application.get_env(:infinity_aps, :loop_directory) |> Path.expand()
    File.mkdir_p!(loop_dir)

    File.write!("#{loop_dir}/profile.json", Poison.encode!(profile), [:binary])
  end
end
