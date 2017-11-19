defprotocol InfinityAPS.Glucose.Source do
  def get_sensor_values(source, minutes_back, timezone)
end

defimpl InfinityAPS.Glucose.Source, for: Pummpcomm.Monitor.BloodGlucoseMonitor do
  defdelegate get_sensor_values(source, minutes_back, timezone), to: Pummpcomm.Monitor.BloodGlucoseMonitor
end
