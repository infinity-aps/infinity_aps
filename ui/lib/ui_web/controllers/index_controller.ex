defmodule InfinityAPS.UI.IndexController do
  use InfinityAPS.UI.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
