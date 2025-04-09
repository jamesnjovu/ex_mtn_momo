defmodule ExMtnMomo do
  @moduledoc """
  ExMtnMomo is an Elixir library for interacting with the MTN Mobile Money API.

  This library provides a simple interface to MTN Mobile Money's Sandbox, Collection,
  and Disbursement APIs, making it easy to integrate MTN Mobile Money into your
  Elixir applications.

  ## Features

  * Sandbox API for testing and development
  * Collection API for receiving payments
  * Disbursement API for sending payments
  * Comprehensive error handling
  * Configurable environment settings

  ## Module Overview

  This library is organized into three main modules:

  * `ExMtnMomo.Sandbox` - Functions for setting up and testing in the sandbox environment
  * `ExMtnMomo.Collection` - Functions for receiving payments from customers
  * `ExMtnMomo.Disbursements` - Functions for sending payments to customers

  ## Getting Started

  First, configure your MTN MoMo API credentials in your `config.exs` file:

  ```elixir
  config :ex_mtn_momo,
    base_url: "https://sandbox.momodeveloper.mtn.com",
    x_target_environment: "sandbox", # mtnzambia | sandbox
    disbursement: %{
      secondary_key: "your_secondary_key",
      primary_key: "your_primary_key",
      user_id: "your_user_id",
      api_key: "your_api_key"
    },
    collection: %{
      secondary_key: "your_secondary_key",
      primary_key: "your_primary_key",
      user_id: "your_user_id",
      api_key: "your_api_key"
    }
  ```

  Then, you can start using the library in your application.

  See the documentation for `ExMtnMomo.Sandbox`, `ExMtnMomo.Collection`, and
  `ExMtnMomo.Disbursements` for specific usage examples.
  """

  # alias ExMtnMomo.{Disbursements, Collection, Sandbox}

end
