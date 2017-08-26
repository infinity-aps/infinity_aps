defmodule InfinityAPS.Monitor.CurrentBasalMonitor do
  require Logger

  def loop do
    Logger.debug "Reading temp basal"

    case Pummpcomm.Session.Pump.read_temp_basal() do
      {:ok, temp_basal} -> write_oref0(temp_basal)
      response          -> Logger.warn "Got: #{inspect(response)}"
    end
  end

  def write_oref0(temp_basal) do
    File.mkdir_p!("/root/loop")

    encoded =  Poison.encode!(%{duration: temp_basal.duration, rate: temp_basal.units_per_hour, temp: temp_basal.type})
    File.write!("/root/loop/temp_basal.json", encoded, [:binary])
  end
end
