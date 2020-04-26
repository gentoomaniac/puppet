TOKEN_FILE = "/etc/secrets_access_token"

Puppet::Functions.create_function(:'vault_lookup::lookup') do
  dispatch :lookup do
    param 'String', :path
    param 'String', :vault_url
  end

  def lookup(path, vault_url)
    uri = URI(vault_url)
    # URI is used here to just parse the vault_url into a host string
    # and port; it's possible to generate a URI::Generic when a scheme
    # is not defined, so double check here to make sure at least
    # host is defined.
    raise Puppet::Error, "Unable to parse a hostname from #{vault_url}" unless uri.hostname

    connection = Puppet::Network::HttpPool.http_ssl_instance(uri.host, uri.port)

    if ENV.key?("VAULT_TOKEN")
        token = ENV["VAULT_TOKEN"]
    elsif File.file?(TOKEN_FILE)
        file = File.open(TOKEN_FILE)
        token = file.read.strip
        File.close
    end
    raise Puppet::Error, "No vault token found" unless defined?(access_token).nil?

    secret_response = connection.get("/v1/#{path}", 'X-Vault-Token' => token)
    unless secret_response.is_a?(Net::HTTPOK)
      message = "Received #{secret_response.code} response code from vault at #{uri.host} for secret lookup"
      raise Puppet::Error, append_api_errors(message, secret_response)
    end

    begin
      data = JSON.parse(secret_response.body)['data']
    rescue StandardError
      raise Puppet::Error, 'Error parsing json secret data from vault response'
    end

    Puppet::Pops::Types::PSensitiveType::Sensitive.new(data)
  end
end
