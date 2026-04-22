require "omniauth"
require "omniauth_openid_connect"

require "fizzy_authentik/version"
require "fizzy_authentik/engine"

module FizzyAuthentik
  # Env knobs consumed at boot:
  #   AUTHENTIK_ISSUER                  — OIDC issuer URL (.well-known discovery)
  #   AUTHENTIK_CLIENT_ID               — OAuth2 client id from Authentik provider
  #   AUTHENTIK_CLIENT_SECRET           — OAuth2 client secret
  #   APP_URL                           — public base URL of the Fizzy app
  #   SSO_DEFAULT_ACCOUNT_EXTERNAL_ID   — if set, unknown emails are auto-provisioned
  #                                       as members of this Account. Empty = reject.
  def self.configured?
    ENV["AUTHENTIK_CLIENT_ID"].to_s.strip != ""
  end
end
