defmodule Yaocg.Accounts.Role do
  use Yaocg.Schema
  import Ecto.Changeset

  alias Yaocg.Accounts.User

  @role_fields [:actions]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "roles" do
    field :actions, :integer
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role \\ %__MODULE__{}, attrs) do
    role
    |> cast(attrs, @role_fields)
    |> validate_required(@role_fields)
  end
end
