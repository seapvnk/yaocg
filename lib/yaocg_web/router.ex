defmodule YaocgWeb.Router do
  use YaocgWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", YaocgWeb do
    pipe_through :api

    resources "/users", UserController
  end

  if Application.compile_env(:yaocg, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: YaocgWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
