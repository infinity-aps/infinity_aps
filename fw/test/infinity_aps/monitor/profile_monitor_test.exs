defmodule ProfileMonitorTest do
  use ExUnit.Case

  alias InfinityAPS.Monitor.ProfileMonitor

  setup do
    basal_schedule = [
      %{start: ~T[00:00:00], rate: 0.80},
      %{start: ~T[06:30:00], rate: 0.95},
      %{start: ~T[09:30:00], rate: 1.10},
      %{start: ~T[14:00:00], rate: 0.95}
    ]

    {:ok, %{basal_schedule: basal_schedule}}
  end

  test "current_basal return correct rate in between scheduled times", %{
    basal_schedule: basal_schedule
  } do
    current_time = ~T[10:00:00]
    assert 1.10 == ProfileMonitor.current_basal(basal_schedule, current_time)
  end

  test "current_basal return correct rate at exact start of day", %{
    basal_schedule: basal_schedule
  } do
    current_time = ~T[00:00:00]
    assert 0.80 == ProfileMonitor.current_basal(basal_schedule, current_time)
  end

  test "current_basal return correct rate at very end of day", %{basal_schedule: basal_schedule} do
    current_time = ~T[23:59:59]
    assert 0.95 == ProfileMonitor.current_basal(basal_schedule, current_time)
  end
end
