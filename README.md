# wstrade-api-elixir

[https://hex.pm/packages/ws_trade/](https://hex.pm/packages/ws_trade/)

An work-in-progress elixir wrapper of the [Wealthsimple Trade](https://www.wealthsimple.com/en-ca/product/trade/) REST API.

This wrapper is a port of [wstrade-api](https://github.com/ahmedsakr/wstrade-api) (an unofficial javascript wrapper).

## Installation
add `ws_trade` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ws_trade, "~> 0.1.0"}
  ]
end
```

## Usage
### Authentication
#### Option 1: Provide OTP manually:

`WsTrade.Auth.login/2`
`WsTrade.Auth.login/3`

```elixir
# Trigger OTP (SMS 2FA)
WsTrade.Auth.login("user@example.com", "my-password")
{:ok, :opt_challenge_triggered}
# Login with OTP
WsTrade.Auth.login("user@example.com", "my-password", "739677")
{:ok, %{
  "x-access-token" => "weEwVLXe-9QkL3rEqug-S4GKE_Q8TyFwciiTgYEtyCk",
  "x-access-token-expires" => "1622182923",
  "x-refresh-token" => "AofZgoTeMhANmELMAcV2u0Z6I4bDGvNTfcpaVdcFGMM"
  }
}
```
#### Option 2A: Provide OTP via provider function:

`WsTrade.Auth.login/3`

```elixir
a = fn -> "739677" end
WsTrade.Auth.login("user@example.com", "my-password", a)
{:ok, %{
  "x-access-token" => "weEwVLXe-9QkL3rEqug-S4GKE_Q8TyFwciiTgYEtyCk",
  "x-access-token-expires" => "1622182923",
  "x-refresh-token" => "AofZgoTeMhANmELMAcV2u0Z6I4bDGvNTfcpaVdcFGMM"
  }
}
```

#### Option 2B: Provide OTP via a built-in provider function:

`WsTrade.Auth.login/3`

```elixir
WsTrade.Auth.login("user@example.com", "my-password", &WsTrade.Auth.OtpProviders.simple_user_prompt/0)
OTP: 888919 # user input
{:ok, %{
  "x-access-token" => "weEwVLXe-9QkL3rEqug-S4GKE_Q8TyFwciiTgYEtyCk",
  "x-access-token-expires" => "1622182923",
  "x-refresh-token" => "AofZgoTeMhANmELMAcV2u0Z6I4bDGvNTfcpaVdcFGMM"
  }
}
```

Once logged in, your OAuth token will be stored and refreshed every hour. You can change the refresh interval by adding the following to `config.exs`:
```elixir
config :ws_trade, token_cache_refresh_freq: :timer.minutes(60)
```

You can retreive the stored Oauth credentials at any time with:
`WsTrade.Auth.TokenCache.get_token/0`
```elixir
WsTrade.Auth.TokenCache.get_token()
{:ok,
 %{
   "x-access-token" => "weEwVLXe-8WmG3rEqug-S4GNZ_Q8TyFwciiTgYEarCk",
   "x-access-token-expires" => "1622182923",
   "x-refresh-token" => "EofZgoTeMhANmCLMAcV2u0Z6INbDGvNTWcpaVdcZGMM"
 }}
```

### Accounts

#### Get all available WS Trade accounts

`WsTrade.Accounts.get_accounts/0`

Retrieves all accounts under the logged in WealthSimple Trade account.

```elixir
WsTrade.Accounts.get_accounts()
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
  }
}
```

#### Get account history

`WsTrade.Accounts.account_history/2`

Query the history of an open account within the specified time interval.
Account id can be retrieved using `WsTrade.Accounts.get_accounts/0`

Interval must be one of: `["1d", "1w", "1m", "3m", "1y", "all"]`

```elixir
WsTrade.Accounts.account_history("non-registered-zzzzzzzz", "1d")
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
  }
}
```

#### Get account activities

`WsTrade.Accounts.account_activities/3`

Fetches activities on your WealthSimple Trade account(s). You can limit number of activities to
fetch or refine what activities are fetched based on activity type (e.g., buy, sell).

By default, this function has a limit of `20` activities and can fetch up to a maximum of `99`.

By default, all account activity types are fetched: `["sell", "deposit", "withdrawal", "dividend",
"institutional_transfer", "internal_transfer", "refund", "referral_bonus", "affiliate", "buy"]`.

```elixir
WsTrade.Accounts.account_activities(["non-registered-zzzzzzzz"], 1)
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
  }
}
```

#### Get all deposits

`WsTrade.Accounts.get_deposits/0`

Fetches all deposits linked to the logged in WealthSimple Trade account.

```elixir
WsTrade.Accounts.get_deposits()
{:ok,
  %{
    "object" => "deposit",
    "results" => [
      %{
        "accepted_at" => "2021-05-05T19:23:21.000Z",
        "account_id" => "non-registered-zzzzzzzz",
        "bank_account_id" => "bank_account-zzzzzzzzzzzzzzzzzzzzzzzzzz",
        "cancellable" => false,
        "cancelled_at" => nil,
        "created_at" => "2021-05-05T17:36:06.000Z",
        "id" => "funds_transfer-zzzzzzzzzzzzzzzzzzzzzzzzz",
        "instant_value" => %{"amount" => 250, "currency" => "CAD"},
        "object" => "deposit",
        "rejected_at" => nil,
        "status" => "accepted",
        "updated_at" => "2021-05-05T19:25:20.110Z",
        "value" => %{"amount" => 250, "currency" => "CAD"}
      }, ...
    ]
  }
}
```


#### Get all bank accounts

`WsTrade.Accounts.get_bank_accounts/0`

Fetches all bank accounts linked to the logged in WealthSimple Trade account.

```elixir
WsTrade.Accounts.get_bank_accounts()
{:ok,
  %{
    "results" => [
      %{
        "account_name" => nil,
        "account_number" => "****zzz",
        "corporate" => false,
        "created_at" => "2019-03-13T21:59:56Z",
        "id" => "bank_account-zzzzzzzzzzzzzzzzzzzzzzzzzz",
        "institution_name" => "zz",
        "institution_number" => "zzz",
        "jurisdiction" => "CA",
        "nickname" => nil,
        "object" => "bank_account",
        "transit_number" => "zzzzz",
        "type" => "chequing",
        "updated_at" => "2019-03-13T21:59:56Z",
        "verification_documents" => [
          %{
            "acceptable" => true,
            "document_id" => "document-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
            "document_type" => "zzzzz",
            "id" => "verification_document-zzzzzzzzzzzzzzzzzzzzzzzzz",
            "reviewed_at" => "2021-01-01T19:42:20Z"
          }, ...
        ],
        "verifications" => [
          %{
            "document_id" => "document-zzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
            "id" => "verification-zzzzzzzzzzzzzzzzzzzzzzzzzzz",
            "method" => "plaid",
            "processed_at" => "2021-01-01T19:42:30Z",
            "status" => "accepted"
          }, ...
        ]
      }
    ]
  }
}
```

### Quotes
Coming soon

### Orders
Coming soon

### Data

#### Get Exchange rate

`WsTrade.Data.get_exchange_rates/0`

Fetches the current USD/CAD Exchange rates
```elixir
WsTrade.Data.get_exchange_rates()
{:ok,
  %{
   "USD" => %{
     "buy_rate" => 1.229,
     "fx_rate" => 1.2106,
     "sell_rate" => 1.1924,
     "spread" => 0.015
   }
  }
}
```
# License
This project is licensed under the MIT License.
