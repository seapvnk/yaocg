defmodule YaocgWeb.AccountsJSON do
  def token(%{token: token}) do
    %{
      message: :authenticated,
      data: data(token)
    }
  end

  def unauthenticated(%{}), do: %{message: :unauthenticated}

  defp data(token), do: %{token: token}
end
