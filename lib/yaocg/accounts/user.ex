defmodule Yaocg.Accounts.User do
  use Yaocg.Schema
  import Ecto.Changeset

  alias Yaocg.Accounts.Role

  @user_fields [:username, :password, :password_confirmation]
  @min_username 3
  @min_password 6

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    has_one :role, Role

    field :username, :string
    field :password_hash, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @user_fields)
    |> validate_required(@user_fields)
    |> validate_user()
    |> put_assoc(:role, %Role{actions: 0})
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @user_fields)
    |> validate_user()
  end

  defp validate_user(changeset) do
    changeset
    |> validate_length(:username, min: @min_username)
    |> validate_length(:password, min: @min_password)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    |> hash_password()
  end

  defp hash_password(%{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
  end
end
