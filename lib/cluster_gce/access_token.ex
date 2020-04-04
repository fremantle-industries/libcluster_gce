defmodule ClusterGCE.AccessToken do
  @type token :: String.t()

  @access_token_path 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'
  @headers [{'Metadata-Flavor', 'Google'}]

  @spec get :: {:ok, token} | {:error, :failed_connect}
  def get do
    :get
    |> :httpc.request({@access_token_path, @headers}, [], [])
    |> case do
      {:ok, {{_, 200, _}, _headers, body}} ->
        %{"access_token" => token} = Jason.decode!(body)
        {:ok, token}

      {:error, {:failed_connect, _}} ->
        {:error, :failed_connect}
    end
  end
end
