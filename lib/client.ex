defmodule WsTrade.Client do
  @moduledoc false
  use Tesla

  alias WsTrade.Auth.TokenCache

  plug(Tesla.Middleware.BaseUrl, Application.get_env(:ws_trade, :base_url))
  plug(Tesla.Middleware.JSON)
  plug(WsTrade.Client.Middleware.RuntimeHeader, {"Authorization", &get_auth_token/0})

  def me do
    get("/me")
  end

  def person do
    get("/person")
  end

  def get_accounts do
    get("/account/list")
  end

  def account_history(account_id, interval) do
    get("/account/history/#{interval}", query: [account_id: account_id])
  end

  def account_activities(account_ids, limit, type, bookmark) do
    get("/account/activities",
      query: [
        accountIds: account_ids,
        type: type,
        limit: limit,
        bookmark: bookmark
      ]
    )
  end

  def get_deposits do
    get("/deposits")
  end

  def get_bank_accounts do
    get("/bank-accounts")
  end

  def get_exchange_rates do
    get("/forex")
  end

  defp get_auth_token do
    TokenCache.get_token()
    |> case do
      {:ok, %{"x-access-token" => token}} -> token
      _ -> ""
    end
  end
end
