defmodule InfinityAPS.Configuration.Preferences do
  defstruct max_iob: 3,
            max_daily_safety_multiplier: 3,
            current_basal_safety_multiplier: 4,
            autosens_max: 1.2,
            autosens_min: 0.7,
            rewind_resets_autosens: true,
            adv_target_adjustments: true,
            unsuspend_if_no_temp: false
end
