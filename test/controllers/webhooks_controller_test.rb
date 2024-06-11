require 'test_helper'
require 'webmock/minitest' 

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should receive Rapid7 webhook and post to Basecamp" do
    webhook_payload = {
      'alert' => {
        'id' => 'ALERT_123',
        'name' => 'Test Alert',
        'status' => 'new',
      },
      'metadata' => {
        'severity' => 'high',
        'attackType' => 'phishing',
      }
    }

    stub_request(:post, "https://3.basecamp.com/3734616/integrations/5jLtTZFkYWebruRpZrpejfEZ/buckets/7028920/chats/975348750/lines")
      .with(
        body: hash_including({
          subject: "Form Submission",
          content: "<details><summary>🚨 Alerta desde Rapid7: <b>Test Alert</b></summary><pre>#{JSON.pretty_generate(webhook_payload)}</pre><br><i>Lanzado desde la app de integraciones internas.</i></details>"
        }),
        headers: {
          'Content-Type' => 'application/json'
        }
      )
      .to_return(status: 201, body: "", headers: {})

    post webhooks_rapid7_url, params: webhook_payload.to_json, headers: { 'Content-Type' => 'application/json' }

    assert_response :ok
    assert_requested :post, "https://3.basecamp.com/3734616/integrations/5jLtTZFkYWebruRpZrpejfEZ/buckets/7028920/chats/975348750/lines", times: 1  # Ensure the Basecamp request was made
  end
end

