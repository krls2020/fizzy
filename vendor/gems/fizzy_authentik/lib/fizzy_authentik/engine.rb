module FizzyAuthentik
  class Engine < ::Rails::Engine
    # Not isolate_namespace — we merge routes into the host app so /auth/…
    # resolves without a mount point in host's routes.rb.

    initializer "fizzy_authentik.omniauth", before: :build_middleware_stack do |app|
      next unless FizzyAuthentik.configured?

      app.middleware.use OmniAuth::Builder do
        provider :openid_connect, {
          name: :authentik,
          issuer: ENV["AUTHENTIK_ISSUER"],
          discovery: true,
          scope: [ :openid, :email, :profile ],
          response_type: :code,
          uid_field: "email",
          client_options: {
            identifier: ENV["AUTHENTIK_CLIENT_ID"],
            secret: ENV["AUTHENTIK_CLIENT_SECRET"],
            redirect_uri: "#{ENV['APP_URL']}/auth/authentik/callback"
          }
        }
      end

      # OAuth `state` already protects the callback. Accept GET so
      # /auth/authentik can be a plain link (keeps Fizzy's CSRF layer
      # from rejecting the middleware-level POST).
      OmniAuth.config.allowed_request_methods = [ :get, :post ]
      OmniAuth.config.request_validation_phase = nil
    end

    initializer "fizzy_authentik.routes" do |app|
      next unless FizzyAuthentik.configured?

      app.routes.append do
        match "/auth/:provider",
          to: "fizzy_authentik/sessions#passthru",
          via: %i[ get post ], as: :fizzy_authentik_sign_in
        get "/auth/:provider/callback",
          to: "fizzy_authentik/sessions#create"
        get "/auth/failure",
          to: "fizzy_authentik/sessions#failure"
      end
    end
  end
end
