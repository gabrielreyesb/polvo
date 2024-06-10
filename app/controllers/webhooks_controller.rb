require 'json'
require 'faraday'

class WebhooksController < ApplicationController

  def rapid7
    payload = JSON.parse(request.body.read)
    config.log_level = :error

    logger.info "------------------------------------------------"
    logger.info "Received webhook: #{payload.inspect}"

    alert_id = payload['alert']['id']
    alert_name = payload['alert']['name']
    alert_status = payload['alert']['status']
    severity = payload['metadata']['severity']
    attack_type = payload['metadata']['attackType']

    process_alert(payload, alert_id, alert_name, alert_status, severity, attack_type)

    head :ok
  end

  private

  def process_alert(original_payload, alert_id, alert_name, alert_status, severity, attack_type)
    logger.info "Procesando alerta"
    puts "Original payload: #{original_payload}"
    url = "https://3.basecamp.com/3734616/integrations/5jLtTZFkYWebruRpZrpejfEZ/buckets/7028920/chats/975348750/lines"
    headers = { "Content-Type" => "application/json" }
    payload_content = "<details><summary>🚨 Alerta desde Rapid7: <b>#{alert_name}</b></summary><pre>#{JSON.pretty_generate(original_payload)}</pre><br><i>Lanzado desde la app de integraciones internas.</i></details>"

    final_payload = { subject: "Form Submission", content: payload_content }

    conn = Faraday.new(url: url) do |faraday|
      faraday.headers['Content-Type'] = 'application/json'
      faraday.request  :json
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end

    begin
      response = conn.post do |req|
        req.body = final_payload
      end
    
      if response.status == 201
        logger.info "Message posted successfully!"
      else
          logger.error "Message posted successfully!"
        raise "Failed to post message: #{response.body}"
      end
    rescue Faraday::Error => e
      logger.error "Error posting message: #{e.message}"
    end
  end

end
