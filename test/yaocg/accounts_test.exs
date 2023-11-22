defmodule Yaocg.AccountsTest do
  use Yaocg.DataCase, async: true
  use ExMachina.Ecto, repo: Yaocg.Repo

  alias Yaocg.Accounts
  alias Yaocg.Accounts.User
  alias Yaocg.Accounts.Role

  def user_factory do
    %User{
      username: sequence(:numeric, &"test_user#{&1}"),
      password_hash: "password_hash",
      role: build(:role)
    }
  end

  def role_factory, do: %Role{actions: 0}

  setup do
    {
      :ok,
      %{
        account: %{
          "username" => "test_user",
          "password" => "test_user",
          "password_confirmation" => "test_user"
        }
      }
    }
  end

  describe "create/1" do
    test "successfully create an account", %{account: params} do
      account = Accounts.create(params)

      assert {
               :ok,
               %User{id: _id, role: %Role{id: _rid, actions: 0}, username: "test_user"}
             } = account
    end

    test "do not create an account when password confirmation doesnt match", %{account: params} do
      params = %{params | "password_confirmation" => "abcde"}
      account = Accounts.create(params)

      assert {:error,
              %{
                errors: [
                  password_confirmation:
                    {"does not match confirmation", [validation: :confirmation]}
                ]
              }} = account
    end

    test "do not create an account when username length is less than 3", %{account: params} do
      params = %{params | "username" => "2a"}
      account = Accounts.create(params)

      assert {:error,
              %{
                errors: [
                  username:
                    {"should be at least %{count} character(s)",
                     [{:count, 3}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
                ]
              }} = account
    end

    test "do not create an account when password length is less than 6", %{account: params} do
      params = %{params | "password" => "2a", "password_confirmation" => "2a"}
      account = Accounts.create(params)

      assert {:error,
              %{
                errors: [
                  password:
                    {"should be at least %{count} character(s)",
                     [{:count, 6}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
                ]
              }} = account
    end

    test "do not create an account when username was already taken", %{account: params} do
      insert(:user, %{
        username: params["username"],
        password_hash: Argon2.hash_pwd_salt(params["password"])
      })

      account = Accounts.create(params)

      assert {:error,
              %{
                errors: [
                  username: {
                    "has already been taken",
                    [constraint: :unique, constraint_name: "users_username_index"]
                  }
                ]
              }} = account
    end
  end

  describe "auth/2" do
    test "successfully authenticate with an existing account", %{account: params} do
      insert(:user, %{
        username: params["username"],
        password_hash: Argon2.hash_pwd_salt(params["password"])
      })

      assert {:ok, %User{username: "test_user", role: %Role{actions: 0}}} =
               Accounts.auth(params["username"], params["password"])
    end

    test "fail when account doesnt exists or password doesnt match", %{account: params} do
      assert {:error, :unauthorized} = Accounts.auth(params["username"], params["password"])
    end
  end
end
