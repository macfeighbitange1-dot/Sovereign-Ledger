require 'net/http'
require 'uri'
require 'json'

class HomeController < ApplicationController
  # This line is the "Genius Fix" that makes the markdown helper visible to the view
  helper :all

  def index
    @messages = Message.order(created_at: :asc).last(50)
  end

  def create
    # 1. Save User Input
    user_content = params[:content]
    @message = Message.create!(role: "user", content: user_content)

    # 2. Setup the Raw API Connection (Mistral AI)
    uri = URI.parse("https://api.mistral.ai/v1/chat/completions")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer QiJh8V2kZ3IQL1eYCAnKqJSOJxSHbTyC"
    
    request.body = {
      model: "mistral-small-latest",
      messages: [
        { 
          role: "system", 
          content: "You are the Sovereign AI Nairobi Node. Expert in Kenyan SACCOs and fintech. ALWAYS use clean Markdown. Use tables for data. No unnecessary symbols." 
        },
        { role: "user", content: user_content }
      ]
    }.to_json

    # 3. Execute the Request
    begin
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      # 4. Parse the JSON Response
      result = JSON.parse(response.body)

      if result["choices"] && result["choices"][0]
        ai_text = result["choices"][0]["message"]["content"]
      else
        ai_text = "Nairobi Node: Connection established, but intelligence layer returned an error: #{result['error']}"
      end
    rescue => e
      ai_text = "Nairobi Node Connection Error: #{e.message}"
    end

    # 5. Save AI Response
    @ai_message = Message.create!(role: "assistant", content: ai_text)

    # 6. Stream to UI via Turbo
    respond_to do |format|
      format.turbo_stream
    end
  end
end
