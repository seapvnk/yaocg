defmodule Yaocg.Accounts do
  alias Yaocg.Repo
  alias Yaocg.Accounts.User

  @doc false
  def create(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end

  @doc false
  def auth(username, password) do
    Repo.get_by(User, username: username)
    |> Repo.preload(:role)
    |> verify_account(password)
  end

  defp verify_account(%{password_hash: stored_password} = user, password) do
    cond do
      Argon2.verify_pass(password, stored_password) -> {:ok, user}
      true -> {:error, :unauthenticated}
    end
  end

  defp verify_account(nil, _password), do: {:error, :unauthenticated}
end
