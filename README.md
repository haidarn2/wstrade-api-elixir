# wstrade-api-elixir

An unofficial elixir wrapper of the [Wealthsimple Trade](https://www.wealthsimple.com/en-ca/product/trade/) REST API.

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
### Auth:
#### Option 1: Provide OTP manually:
```elixir
# Trigger OTP (SMS 2FA)
iex(1)> WsTrade.Auth.login("user@example.com", "my-password")
{:ok, :opt_challenge_triggered}
# Login with OTP
iex(2)> WsTrade.Auth.login("user@example.com", "my-password", "739677")
{:ok, :successfully_logged_in}
```
#### Option 2: Provide OTP via provider function:
```elixir
iex(1)> a = fn -> "739677" end
iex(2)> WsTrade.Auth.login("user@example.com", "my-password", a)
{:ok, :successfully_logged_in}
```

#### Option 2B: Provide OTP via a built-in provider function:
```elixir
iex(1)> WsTrade.Auth.login("user@example.com", "my-password", &WsTrade.Auth.OtpProviders.simple_user_prompt/0)
OTP: 888919 # user input
{:ok, :successfully_logged_in}
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ws_trade](https://hexdocs.pm/ws_trade).

