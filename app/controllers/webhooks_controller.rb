class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

  def rapid7
    payload = JSON.parse(request.body.read)
    logger.info "Received webhook: #{payload.inspect}"

    alert_id = payload['alert']['id']
    alert_name = payload['alert']['name']
    # ... (extract other relevant data)

    process_alert(alert_id, alert_name)

    head :ok
  end

  private

  def process_alert(alert_id, alert_name)
    logger.info "Todo bien"
  end
end
