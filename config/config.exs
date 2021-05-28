import Config

config :ws_trade,
  base_url: System.get_env("WS_TRADE_BASE_URL") || "https://trade-service.wealthsimple.com"

config :ws_trade, token_cache_refresh_freq: :timer.minutes(60)

import_config "#{Mix.env()}.exs"
