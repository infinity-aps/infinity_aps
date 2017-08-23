defmodule NervesAps.UI.Router do
  use NervesAps.UI.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NervesAps.UI do
    pipe_through :browser # Use the default browser stack

    post "/configuration", ConfigurationController, :update
    get "/configuration", ConfigurationController, :index

    post "/preferences", PreferencesController, :update
    get "/preferences", PreferencesController, :index
  end
end
