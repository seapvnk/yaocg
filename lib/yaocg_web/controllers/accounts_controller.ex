defmodule YaocgWeb.AccountsController do
  use YaocgWeb, :controller

  alias YaocgWeb.Token
  alias Yaocg.Accounts
  alias Yaocg.Accounts.User

  action_fallback YaocgWeb.FallbackController

  def signup(conn, params) do
    with {:ok, %User{} = user} <- Accounts.create(params) do
      conn
      |> put_status(:created)
      |> render(:token, token: Token.sign(user))
    end
  end

  def signin(conn, %{"username" => username, "password" => password}) do
    conn
    |> handle_signin(Accounts.auth(username, password))
  end

  defp handle_signin(conn, {:ok, %User{} = user}) do
    conn
    |> put_status(:ok)
    |> render(:token, token: Token.sign(user))
  end

  defp handle_signin(conn, {:error, :unauthenticated}) do
    conn
    |> put_status(:unauthorized)
    |> render(:unauthenticated)
  end
end
