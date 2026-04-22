module FizzyAuthentik
  class SessionsController < ::ApplicationController
    disallow_account_scope
    require_unauthenticated_access except: :failure
    skip_before_action :verify_authenticity_token, only: [ :create, :passthru ]

    layout "public"

    # OmniAuth middleware intercepts /auth/:provider before Rails routing
    # takes over, so this action is only hit if OmniAuth is disabled.
    def passthru
      render plain: "SSO passthru — OmniAuth middleware not active.", status: :not_found
    end

    def create
      info = request.env["omniauth.auth"]&.info

      unless info&.email
        redirect_to(new_session_path, alert: "SSO sign-in failed.")
        return
      end

      identity = find_or_provision_identity(info)

      if identity.nil?
        redirect_to new_session_path, alert: "No Fizzy account for #{info.email}. Ask an admin to invite you."
      else
        start_new_session_for(identity)
        redirect_to after_authentication_url
      end
    end

    def failure
      redirect_to new_session_path, alert: "SSO failed: #{params[:message].presence || 'Unknown error'}"
    end

    private
      def find_or_provision_identity(info)
        if identity = Identity.find_by(email_address: info.email)
          return identity
        end

        external_id = ENV["SSO_DEFAULT_ACCOUNT_EXTERNAL_ID"].presence
        return nil unless external_id

        account = Account.find_by(external_account_id: external_id)
        return nil unless account

        Identity.transaction do
          identity = Identity.create!(email_address: info.email)
          account.users.create!(
            identity: identity,
            name: info.name.presence || info.email.split("@").first,
            role: :member,
            verified_at: Time.current
          )
          identity
        end
      end
  end
end
