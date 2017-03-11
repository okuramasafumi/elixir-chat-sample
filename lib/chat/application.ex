defmodule Chat.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Chat.Worker.start_link(arg1, arg2, arg3)
      worker(__MODULE__, [], function: :start_server),
      supervisor(Phoenix.PubSub.PG2, [:chat_pubsub, []])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_server do
    routes = [
      {"/", Chat.RootHandler, []},
      {"/greet/:name", Chat.GreetingHandler, []},
      {"/websocket", Chat.WebsocketHandler, []},
      {"/static/[...]", :cowboy_static, {:priv_dir, :chat, "static"}}
    ]
    dispatch = :cowboy_router.compile([{:_, routes}])
    opts = [{:port, 4001}]
    env = %{dispatch: dispatch}
    {:ok, _pid} = :cowboy.start_clear(:http, 10, opts, %{env: env})
  end
end
