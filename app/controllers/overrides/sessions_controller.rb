module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    respond_to :json

    skip_before_filter :verify_authenticity_token, only: [:destroy]
    skip_before_action :verify_signed_out_user, only: [:destroy]

    def respond_to_on_destroy
      respond_to do |format|
        format.all { head :no_content }
      end
    end

    def destroy
      super

      head :no_content
    end

  end
end
