defmodule Client.Config do
  @moduledoc """
  This module is just a bag of configs used by `Client.Request`.
  """
  def headers, do: [{~c"accept", ~c"application/json"}]

  def ssl do
    [
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
  end
end
