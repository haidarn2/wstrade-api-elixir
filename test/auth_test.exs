defmodule WsTrade.AuthTest do
  use ExUnit.Case, async: true

  alias WsTrade.Auth

  @login_url Application.compile_env(:ws_trade, :base_url) <> "/auth/login"
  @sample_email "user@example.com"
  @sample_password "password"
  @sample_otp "739677"
  @sample_otp_challenge_body %{
    email: "user@example.com",
    password: "password",
    otp: ""
  }
  @sample_login_body %{
    email: "user@example.com",
    password: "password",
    otp: "739677"
  }

  defp mock_endpoint(req_method, req_url, req_body, resp_status) do
    mock_endpoint_and_resp(req_method, req_url, req_body, %Tesla.Env{status: resp_status})
  end

  defp mock_endpoint_and_resp(req_method, req_url, req_body, resp) do
    {:ok, req_body} = req_body |> Jason.encode()

    Tesla.Mock.mock(fn
      %{method: ^req_method, url: ^req_url, body: ^req_body} ->
        resp

      %{method: unexpected_method, url: unexpected_url, body: unexpected_body} ->
        assert unexpected_method == req_method
        assert unexpected_url == req_url
        assert unexpected_body == req_body
    end)
  end

  test "otp challenge returns ok on 401 response" do
    mock_endpoint(:post, @login_url, @sample_otp_challenge_body, 401)
    assert {:ok, :opt_challenge_triggered} == Auth.login(@sample_email, @sample_password)
  end

  test "otp challenge returns error on unsupported status response" do
    mock_endpoint(:post, @login_url, @sample_otp_challenge_body, 502)
    assert {:error, :unsupported_status} == Auth.login(@sample_email, @sample_password)
  end

  test "otp challenge returns error on remote call error" do
    resp = {:error, :dns_error}
    mock_endpoint_and_resp(:post, @login_url, @sample_otp_challenge_body, resp)
    assert {:error, :remote_call_failed} == Auth.login(@sample_email, @sample_password)
  end

  test "login returns ok on 200 response" do
    mock_endpoint(:post, @login_url, @sample_login_body, 200)

    assert {:ok, :successfully_logged_in} ==
             Auth.login(@sample_email, @sample_password, @sample_otp)
  end

  test "login returns error on 401 response" do
    mock_endpoint(:post, @login_url, @sample_login_body, 401)

    assert {:error, :incorrect_credentials} ==
             Auth.login(@sample_email, @sample_password, @sample_otp)
  end

  test "login returns error on unsupported status response" do
    mock_endpoint(:post, @login_url, @sample_login_body, 502)

    assert {:error, :unsupported_status} ==
             Auth.login(@sample_email, @sample_password, @sample_otp)
  end

  test "login returns error on remote call error" do
    resp = {:error, :dns_error}
    mock_endpoint_and_resp(:post, @login_url, @sample_login_body, resp)

    assert {:error, :remote_call_failed} ==
             Auth.login(@sample_email, @sample_password, @sample_otp)
  end

  test "login with otp provider returns ok on 200 response" do
    method = :post
    url = @login_url
    {:ok, otp_body} = @sample_otp_challenge_body |> Jason.encode()
    {:ok, login_body} = @sample_login_body |> Jason.encode()

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url, body: ^otp_body} ->
        %Tesla.Env{status: 401}

      %{method: :post, url: ^url, body: ^login_body} ->
        %Tesla.Env{status: 200, body: %{}, headers: %{}}
    end)

    assert {:ok, :successfully_logged_in} ==
             Auth.login(@sample_email, @sample_password, fn -> {:ok, @sample_otp} end)
  end
end
