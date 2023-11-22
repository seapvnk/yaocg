defmodule YaocgWeb.AccountControllerTest do
  use YaocgWeb.ConnCase
  use ExMachina.Ecto, repo: Yaocg.Repo

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
        },
        signin: %{
          "username" => "test_user",
          "password" => "test_pass"
        }
      }
    }
  end

  describe "signup/2" do
    test "successfully creates an account", %{conn: conn, account: account} do
      response =
        conn
        |> post(~p"/api/signup", account)
        |> json_response(:created)

      assert %{"data" => %{"token" => _token}, "message" => "authenticated"} = response
    end

    test "do not create an account when password confirmation doesnt match", %{
      conn: conn,
      account: account
    } do
      account = %{account | "password_confirmation" => "not match"}

      response =
        conn
        |> post(~p"/api/signup", account)
        |> json_response(:bad_request)

      assert %{"errors" => %{"password_confirmation" => ["does not match confirmation"]}} =
               response
    end

    test "do not create an account when username length is less than 3", %{
      conn: conn,
      account: account
    } do
      account = %{account | "username" => "hi"}

      response =
        conn
        |> post(~p"/api/signup", account)
        |> json_response(:bad_request)

      assert %{"errors" => %{"username" => ["should be at least 3 character(s)"]}} = response
    end

    test "do not create an account when password length is less than 6", %{
      conn: conn,
      account: account
    } do
      account = %{account | "password" => "one"}

      response =
        conn
        |> post(~p"/api/signup", account)
        |> json_response(:bad_request)

      assert %{"errors" => %{"password" => ["should be at least 6 character(s)"]}} = response
    end

    test "do not create an account when username was already taken", %{
      conn: conn,
      account: account
    } do
      insert(:user, %{username: "test_user"})

      response =
        conn
        |> post(~p"/api/signup", account)
        |> json_response(:bad_request)

      assert %{"errors" => %{"username" => ["has already been taken"]}} = response
    end
  end

  describe "signin/2" do
    test "successfully signin when username and password are valid", %{
      conn: conn,
      signin: signin
    } do
      insert(:user, %{
        username: signin["username"],
        password_hash: Argon2.hash_pwd_salt(signin["password"])
      })

      response =
        conn
        |> post(~p"/api/signin", signin)
        |> json_response(:ok)

      assert %{"data" => %{"token" => _token}, "message" => "authenticated"} = response
    end

    test "cannot signin with wrong password", %{
      conn: conn,
      signin: signin
    } do
      insert(:user, %{
        username: signin["username"],
        password_hash: Argon2.hash_pwd_salt(signin["password"])
      })

      signin = %{signin | "password" => "wrong!"}

      response =
        conn
        |> post(~p"/api/signin", signin)
        |> json_response(:unauthorized)

      assert %{"message" => "unauthenticated"} = response
    end

    test "cannot signin in an unexistent account", %{
      conn: conn,
      signin: signin
    } do
      response =
        conn
        |> post(~p"/api/signin", signin)
        |> json_response(:unauthorized)

      assert %{"message" => "unauthenticated"} = response
    end
  end
end
