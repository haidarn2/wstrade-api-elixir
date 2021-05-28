defmodule WsTrade.Accounts do
  require Logger

  @moduledoc """
  A module that implements functions for retrieving WS Trade account details
  """
  alias WsTrade.Client

  @activity_fetch_limit 99
  @activity_all_types [
    "sell",
    "deposit",
    "withdrawal",
    "dividend",
    "institutional_transfer",
    "internal_transfer",
    "refund",
    "referral_bonus",
    "affiliate",
    "buy"
  ]

  @doc """
    Retrieves all account ids open under the logged in WealthSimple Trade account.

  ## Examples

  iex> WsTrade.Accounts.get_accounts()
  {:ok,
  %{
   "results" => [
     %{
       "account_type" => "ca_non_registered",
       "available_to_withdraw" => %{"amount" => 8.86, "currency" => "CAD"},
       "base_currency" => "CAD",
       "buying_power" => %{"amount" => 8.86, "currency" => "CAD"},
       "created_at" => "2021-01-01T19:42:29.515Z",
       "current_balance" => %{"amount" => 8.86, "currency" => "CAD"},
       "custodian_account_number" => "zzzzzzzzzzz",
       "deleted_at" => nil,
       "external_esignature_id" => "document-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
       "id" => "non-registered-zzzzzzzz",
       "last_synced_at" => "2021-05-27T22:22:16.288Z",
       "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
       "object" => "account",
       "opened_at" => "2021-01-01T19:42:55.099Z",
       "position_quantities" => %{
         "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" => 140,
         "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" => 100,
         "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" => 140,
         "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" => 13
       },
       "read_only" => nil,
       "status" => "open",
       "updated_at" => "2021-01-01T19:42:29.515Z",
       "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
     }
   ]
  }}
  """
  def get_accounts() do
    Client.get_accounts()
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 401}} -> {:error, :unauthorized}
      {:ok, %{status: _}} -> {:error, :unknown_status}
      _e -> {:error, :remote_call_failed}
    end
  end

  @doc """
    Query the history of an open account within a certain time interval.
    Account id can be retrieved from: WsTrade.Accounts.get_accounts/0
    Interval must be one of: ["1d", "1w", "1m", "3m", "1y", "all"]

  ## Examples

  iex> WsTrade.Accounts.account_history("non-registered-zzzzzzzz", "1d")
  {:ok,
  %{
    "previous_close_data_point" => %{
      "date" => "2021-05-26T20:00:00.000Z",
      "equity_value" => %{"amount" => 7511.5884, "currency" => "CAD"},
      "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
      "value" => %{"amount" => 7520.4484, "currency" => "CAD"},
      "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
    },
    "previous_close_net_liquidation_value" => %{
      "amount" => 7520.4484,
      "currency" => "CAD"
    },
    "results" => [
      %{
        "date" => "2021-05-27T13:30:00.000Z",
        "equity_value" => %{"amount" => 7595.0496, "currency" => "CAD"},
        "net_deposits" => %{"amount" => 7305, "currency" => "CAD"},
        "relative_equity_earnings" => %{
          "amount" => 83.4612,
          "currency" => "CAD",
          "percentage" => 0.010988894661069757
        },
        "value" => %{"amount" => 7603.9096, "currency" => "CAD"},
        "withdrawn_earnings" => %{"amount" => 0, "currency" => "CAD"}
      },
      ...
    ],
    "start_earnings" => %{"amount" => 215.4484, "currency" => "CAD"}
  }}
  """
  def account_history(account_id, interval)
      when interval in ["1d", "1w", "1m", "3m", "1y", "all"] do
    Client.account_history(account_id, interval)
    |> case do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: 401}} -> {:error, :unauthorized}
      {:ok, %{status: _}} -> {:error, :unknown_status}
      _e -> {:error, :remote_call_failed}
    end
  end

  @doc """
    Fetches activities on your Wealthsimple Trade account(s). You can limit number of activities to
    fetch or refine what activities are fetched based on activity type (e.g., buy, sell).

    By default, this function has a limit of 20 activities and can fetch up to a maximum of 99.
    By default, all account activity types are fetched: "sell", "deposit", "withdrawal", "dividend",
    "institutional_transfer", "internal_transfer", "refund", "referral_bonus", "affiliate", "buy".


    ## Examples

    iex> WsTrade.Accounts.account_activities(["non-registered-zzzzzzzz"], 1)
    {:ok,
     %{
       "bookmark" => "zzzzzzzzzzzzzzz...",
       "errors" => [],
       "results" => [
         %{
           "account_value" => %{"amount" => 254.94, "currency" => "CAD"},
           "settled" => true,
           "order_sub_type" => "limit",
           "completed_at" => nil,
           "id" => "order-zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
           "use_kafka_consumer" => true,
           "account_hold_value" => %{"amount" => 0, "currency" => "CAD"},
           "security_id" => "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
           "user_id" => zzzzzz,
           "time_in_force" => "day",
           "market_currency" => "CAD",
           "fill_quantity" => 21,
           "external_order_id" => "order-zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
           "order_id" => "order-zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
           "status" => "posted",
           "limit_price" => %{"amount" => 12.21, "currency" => "CAD"},
           "created_at" => "2021-05-05T17:38:36.213Z",
           "bigint_id" => nil,
           "external_order_batch_id" => "order-batch-zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
           "stop_price" => nil,
           "quantity" => 21,
           "market_value" => %{"amount" => 254.94, "currency" => "CAD"},
           "account_currency" => "CAD",
           "ip_address" => "99.238.68.169",
           "perceived_filled_at" => "2021-05-05T17:38:37.462Z",
           "object" => "order",
           "symbol" => "CGX",
           "external_security_id" => "sec-s-zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
           "last_event_time" => "2021-05-05T17:38:37.040Z",
           "order_type" => "buy_quantity",
           "account_id" => "non-registered-zzzzzzzz",
           "fill_fx_rate" => 1,
           "filled_at" => "2021-05-05T17:38:36.490Z",
           "updated_at" => "2021-05-05T17:39:30.262Z",
           "security_name" => "Cineplex Inc"
         }
       ]
     }}
  """
  def account_activities(account_ids, limit \\ 20, types \\ @activity_all_types)
      when is_list(account_ids) and limit <= @activity_fetch_limit do
    Client.account_activities(
      account_ids |> Enum.join(","),
      limit,
      types,
      ""
    )
    |> case do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %{status: _}} = e ->
        Logger.error("unknown status!\n#{inspect(e)}")
        {:error, :unknown_status}

      _e ->
        {:error, :remote_call_failed}
    end
  end
end
