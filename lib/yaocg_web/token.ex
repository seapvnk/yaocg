defmodule YaocgWeb.Token do
  alias YaocgWeb.Endpoint
  alias Phoenix.Token

  @sign_salt "changeme"

  def sign(%{id: user_id}) do
    Token.sign(Endpoint, @sign_salt, %{id: user_id})
  end

  def verify(token), do: Token.verify(Endpoint, @sign_salt, token)
end
