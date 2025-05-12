require 'net/http'
require 'uri'
require 'json'

module ExpertDialog
  class ClaudeClient
    def initialize(api_key = nil)
      @api_key = api_key || SiteSetting.expert_dialog_claude_api_key
      @base_url = "https://api.anthropic.com/v1/messages"
      
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "claude_client",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def generate_dialog(prompt, options = {})
      ExpertDialog::StateTracker.track_operation("claude_api_call") do
        ExpertDialog::PerformanceMonitor.track_api_call("claude", "generate_dialog") do
          # Set default options
          model = options[:model] || SiteSetting.expert_dialog_claude_model || "claude-3-opus-20240229"
          max_tokens = options[:max_tokens] || 4000
          temperature = options[:temperature] || SiteSetting.expert_dialog_temperature || 0.7
          
          # Prepare request payload
          payload = {
            model: model,
            messages: [
              { role: "user", content: prompt }
            ],
            max_tokens: max_tokens,
            temperature: temperature,
          }
          
          # Make API request
          uri = URI.parse(@base_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          
          request = Net::HTTP::Post.new(uri.path)
          request["Content-Type"] = "application/json"
          request["x-api-key"] = @api_key
          request["anthropic-version"] = "2023-06-01"
          request.body = payload.to_json
          
          begin
            response = http.request(request)
            
            if response.code == "200"
              JSON.parse(response.body)
            else
              Rails.logger.error("Claude API error: #{response.code} - #{response.body}")
              nil
            end
          rescue => e
            Rails.logger.error("Claude API request error: #{e.message}")
            nil
          end
        end
      end
    end
  end
end 