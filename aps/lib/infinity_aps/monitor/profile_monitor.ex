defmodule InfinityAPS.Monitor.ProfileMonitor do
  @moduledoc false
  require Logger
  alias InfinityAPS.Configuration

  def loop(local_timezone) do
    Logger.debug("Reading profile information")

    pump = pump()

    with {:ok, bg_targets} <- pump.read_bg_targets(),
         {:ok, settings} <- pump.read_settings(),
         {:ok, carb_ratios} <- pump.read_carb_ratios(),
         {:ok, insulin_sensitivities} <- pump.read_insulin_sensitivities(),
         {:ok, basal_profile} <- pump.read_std_basal_profile(),
         {:ok, model_number} <- pump.get_model_number(),
         %{preferences: preferences} <- Configuration.get_config() do
      profile =
        format_profile(
          bg_targets: bg_targets,
          preferences: preferences,
          settings: settings,
          carb_ratios: carb_ratios,
          insulin_sensitivities: insulin_sensitivities,
          basal_profile: basal_profile,
          model_number: model_number,
          local_timezone: local_timezone
        )

      Logger.info(fn -> inspect(profile) end)
      write_profile(profile)
    else
      error ->
        Logger.error(fn -> "Error while reading profile information: #{inspect(error)}" end)
    end
  end

  defp pump do
    Application.get_env(:pummpcomm, :pump)
  end

  defp format_profile(
         bg_targets: bg_targets,
         preferences: preferences,
         settings: _settings,
         carb_ratios: _carb_ratios,
         insulin_sensitivities: _insulin_sensitivities,
         basal_profile: basal_profile,
         model_number: model_number,
         local_timezone: local_timezone
       ) do
    %{
      max_iob: preferences.max_iob,
      max_daily_safety_multiplier: preferences.max_daily_safety_multiplier,
      current_basal_safety_multiplier: preferences.current_basal_safety_multiplier,
      carbratio_adjustmentratio: 1,
      dia: 4,
      model: Integer.to_string(model_number),
      current_basal:
        current_basal(basal_profile.schedule, DateTime.to_time(Timex.now(local_timezone))),
      min_bg: 80,
      max_bg: 120,
      sens: 30,
      bg_targets: format_bg_targets(bg_targets),
      basalprofile: format_basal_profile(basal_profile)
    }
  end

  defp format_bg_targets(bg_targets) do
    %{
      units: bg_targets.units,
      user_preferred_units: bg_targets.units,
      targets:
        Enum.map(bg_targets.targets, fn target ->
          %{
            min_bg: target.bg_low,
            max_bg: target.bg_high,
            start: Time.to_string(target.start)
          }
        end)
    }
  end

  def current_basal(basal_schedule, current_time) do
    Enum.reduce_while(basal_schedule, nil, fn schedule_entry, rate ->
      case Timex.before?(current_time, schedule_entry.start) do
        true -> {:halt, rate}
        false -> {:cont, schedule_entry.rate}
      end
    end)
  end

  defp format_basal_profile(basal_profile) do
    basal_profile.schedule
    |> Enum.map(fn item ->
      %{
        start: Time.to_string(item.start),
        rate: item.rate
      }
    end)
  end

  defp write_profile(profile) do
    loop_dir = Path.expand(Application.get_env(:aps, :loop_directory))
    File.mkdir_p!(loop_dir)

    File.write!("#{loop_dir}/profile.json", Poison.encode!(profile), [:binary])
  end
end
