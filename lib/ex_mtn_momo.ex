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

  alias ExMtnMomo.{
    Collection,
    Disbursements,
    Sandbox
  }


  @doc """
  Checks the status of a payment request.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.create_sandbox_user()
      {:ok, %{
        "api_key" => "6418abf0507b4829a7ded11ca8f67cd7",
        "providerCallbackHost" => "https://webhook.site",
        "targetEnvironment" => "sandbox",
        "user_id" => "3d6df852-7be6-4870-be57-b784446a885c"
        }}

  """
  def create_sandbox_user(
        callback_url \\ "https://webhook.site",
        options \\ []
      ) do
    with uuid <- Sandbox.get_uuid4(),
         {:ok, _} <- Sandbox.create_api_user(uuid, callback_url, options),
         {:ok, %{"apiKey" => api_key}} <- Sandbox.get_api_key(uuid, options),
         {:ok, attrs} <- Sandbox.get_created_user(uuid, options) do
      {:ok, Map.merge(%{"user_id" => uuid, "api_key" => api_key}, attrs)}
    else
      error ->
        error
    end
  end


  @doc """
  Checks the status of a payment request.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples
      iex> payment_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payer" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Payment for products",
      ...>   "payeeNote" => "Payment received"
      ...> }
      iex> ExMtnMomo.collect_funds(payment_details)
      {:ok, %{
         "x_reference_id" => x_reference_id,
         "status" => "pending",
         "message" => "Request to pay has been sent"
        }}

  """
  def collect_funds(attrs, x_reference_id \\ UUID.uuid4(), options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Collection.create_access_token(options),
         {:ok, _} <- Collection.request_to_pay(attrs, access_token, x_reference_id, options) do
      {:ok,
       %{
         "x_reference_id" => x_reference_id,
         "status" => "pending",
         "message" => "Request to pay has been sent"
       }}
    else
      error ->
        error
    end
  end

  @doc """
  Checks the status of a payment request.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.collections_check_transaction_status(reference_id)
      {:ok, %{
        "amount" => "1000",
        "currency" => "EUR",
        "externalId" => "123456789",
        "financialTransactionId" => "1308275464",
        "payeeNote" => "Payment received",
        "payer" => %{"partyId" => "256771234567", "partyIdType" => "MSISDN"},
        "payerMessage" => "Payment for products",
        "status" => "SUCCESSFUL"
        }}

  """

  def collections_check_transaction_status(reference_id, options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Collection.create_access_token(options),
         data <- Collection.request_to_pay_transaction_status(reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end

  """
      attrs = %{
         "amount" => "1000",
         "currency" => "EUR",
         "externalId" => "1234564789",
         "payer" => %{
           "partyIdType" => "MSISDN",
           "partyId" => "256771234567"
         },
         "payerMessage" => "Payment for products",
         "payeeNote" => "Payment received"
      }
  """

  def disburse_funds(attrs, reference_id \\ UUID.uuid4(), options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Disbursements.create_access_token(options),
         data <- Disbursements.transfer(attrs, reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end

  def disbursements_check_transaction_status(reference_id, options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Disbursements.create_access_token(options),
         data <- Disbursements.request_to_pay_transaction_status(reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end
end
