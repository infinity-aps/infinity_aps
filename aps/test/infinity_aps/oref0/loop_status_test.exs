defmodule InfinityAPS.Oref0.LoopStatusTest do
  use ExUnit.Case
  alias InfinityAPS.Oref0.LoopStatus

  setup do
    {:ok, pid} =
      LoopStatus.start_link(
        loop_directory: "#{File.cwd!()}/test/fixtures",
        name: :test_loop_status
      )

    on_exit(fn -> assert_down(pid) end)
    :ok
  end

  test "get_predicted_glucose returns the correct IOB" do
    {:ok, predicted_glucose} = LoopStatus.get_predicted_glucose(:test_loop_status)
    assert length(predicted_glucose) == 39
  end

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
