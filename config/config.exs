use Mix.Config

config :logger,
  level: :debug,
  format: "$time $metadata[$level] $levelpad$message\n"
