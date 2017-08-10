defmodule NervesAps.UI.PageController do
  use NervesAps.UI.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
