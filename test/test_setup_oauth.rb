require './test/test_base.rb'

require 'faraday'
require 'json'

class MediumSdkSetupOAuthTest < Test::Unit::TestCase
  def setup
    @string = 'deadbeef'
    @redirect_uri = 'https://example.com/callback'
    @sdk = MediumSdk.new client_id: 'dead', client_secret: 'beef', redirect_uri: @redirect_uri
    @sdk2 = MediumSdk.new client_id: 'dead', client_secret: 'beef', redirect_uri: @redirect_uri, scope: 'listPublications'
  end

  def test_main
    assert_equal 'dead', @sdk.connection.client_id
    assert_equal @redirect_uri, @sdk.connection.oauth_redirect_uri
    assert_equal 'https://api.medium.com/v1', @sdk.connection.api_version_uri

    token = {
      'access_token' => @string
    }
    @sdk.connection.set_token token
    token2 = @sdk.connection.token.to_hash
    assert_equal @string, token2[:access_token]

    token = {
      'access_token' => @string + @string
    }
    token2 = JSON.generate token
    @sdk.connection.set_token token2
    token3 = @sdk.connection.token.to_hash
    assert_equal (@string + @string), token3[:access_token]  

    @sdk.connection.set_token @string
    token = @sdk.connection.token.to_hash
    assert_equal @string, token[:access_token]

    opts = {}
    opts = @sdk.connection._add_redirect_uri opts
    assert_equal @redirect_uri, opts[:redirect_uri]

    auth_uri = @sdk.connection.authorize_uri
    assert_equal 'https://medium.com/m/oauth/authorize?client_id=dead&redirect_uri=https%3A%2F%2Fexample.com%2Fcallback&response_type=code', auth_uri

    auth_uri = @sdk2.connection.authorize_uri
    assert_equal 'https://medium.com/m/oauth/authorize?client_id=dead&redirect_uri=https%3A%2F%2Fexample.com%2Fcallback&response_type=code&scope=listPublications', auth_uri

    assert_raise do 
      @sdk2.connection.set_token(['fail'])
    end
  end
end
