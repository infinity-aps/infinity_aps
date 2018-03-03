defmodule InfinityAPS.UI.Router do
  use InfinityAPS.UI.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", InfinityAPS.UI do
    # Use the default browser stack
    pipe_through(:browser)

    post("/configuration", ConfigurationController, :update)
    get("/configuration", ConfigurationController, :index)

    post("/preferences", PreferencesController, :update)
    get("/preferences", PreferencesController, :index)

    get("/", IndexController, :index)
  end
end
