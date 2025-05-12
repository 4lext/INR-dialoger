require 'fileutils'
require 'net/http'
require 'uri'
require 'json'

module ExpertDialog
  class TTSGenerator
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "tts_generator",
        methods: self.methods(false),
        file: __FILE__
      )
      
      # Initialize TTS engine configuration
      @tts_provider = SiteSetting.expert_dialog_tts_provider
      @tts_service_url = SiteSetting.expert_dialog_tts_service_url
      @openai_api_key = SiteSetting.expert_dialog_openai_api_key
      @tts_model = SiteSetting.expert_dialog_tts_model
      
      @voice_profiles = {
        "expert1" => SiteSetting.expert_dialog_tts_voice_1,
        "expert2" => SiteSetting.expert_dialog_tts_voice_2
      }
    end
    
    def generate_audio_for_dialog(dialog_text)
      ExpertDialog::StateTracker.track_operation("generate_audio") do
        # Skip if TTS is not enabled
        unless SiteSetting.expert_dialog_enable_tts
          return { success: false, error: "TTS is not enabled" }
        end
        
        # Skip if provider-specific settings are not configured
        if @tts_provider == "openai" && @openai_api_key.blank?
          return { success: false, error: "OpenAI API key is not configured" }
        elsif @tts_provider == "custom" && @tts_service_url.blank?
          return { success: false, error: "TTS service URL is not configured" }
        end
        
        # Extract each speaker's parts
        dialog_parts = parse_dialog_into_parts(dialog_text)
        
        # Generate audio for each part
        audio_files = []
        
        dialog_parts.each do |part|
          # Generate audio for this part
          audio_result = generate_audio_for_part(part[:speaker], part[:text])
          
          if audio_result[:success]
            filename = "dialog_part_#{part[:index]}.mp3"
            path = "#{Rails.root}/public/uploads/expert_dialog/#{filename}"
            
            # Create directory if it doesn't exist
            FileUtils.mkdir_p(File.dirname(path))
            
            # Write audio data to file
            File.open(path, 'wb') do |file|
              file.write(audio_result[:audio_data])
            end
            
            audio_files << {
              path: path,
              url: "/uploads/expert_dialog/#{filename}",
              speaker: part[:speaker],
              index: part[:index]
            }
          else
            Rails.logger.error("Failed to generate audio for part #{part[:index]}: #{audio_result[:error]}")
          end
        end
        
        # If no audio files were generated, return an error
        if audio_files.empty?
          return { success: false, error: "Failed to generate any audio files" }
        end
        
        # Combine all audio files (if needed)
        combined_audio_path = combine_audio_files(audio_files)
        
        {
          success: true,
          audio_parts: audio_files,
          combined_audio: combined_audio_path
        }
      end
    end
    
    private
    
    def parse_dialog_into_parts(dialog_text)
      parts = []
      index = 0
      
      # Simple regex to extract speaker parts
      # This assumes dialog format like: "Dr. Phillips: Lorem ipsum..."
      dialog_text.scan(/([A-Za-z\.\s]+):\s(.*?)(?=(?:[A-Za-z\.\s]+):|$)/m) do |speaker, text|
        # Clean up speaker name and text
        speaker_name = speaker.strip
        speaker_text = text.strip
        
        # Determine which expert this is
        expert_key = speaker_name.include?("Phillips") ? "expert1" : "expert2"
        
        # Split long text into manageable chunks (4000 chars max for OpenAI TTS)
        text_chunks = chunk_text(speaker_text, 4000)
        
        text_chunks.each do |chunk|
          parts << {
            index: index,
            speaker: expert_key,
            speaker_name: speaker_name,
            text: chunk
          }
          index += 1
        end
      end
      
      parts
    end
    
    def chunk_text(text, max_length)
      # If text is already short enough, return it directly
      return [text] if text.length <= max_length
      
      chunks = []
      current_pos = 0
      
      while current_pos < text.length
        # Find a good breakpoint (end of sentence) within the allowed range
        end_pos = [current_pos + max_length, text.length].min
        
        # Try to find sentence ending within the chunk
        if end_pos < text.length
          # Look for sentence endings (.!?) followed by space or newline
          sentence_end = text[current_pos...end_pos].rindex(/[.!?][\s\n]/)
          
          if sentence_end
            # Add offset to get absolute position
            end_pos = current_pos + sentence_end + 1
          end
        end
        
        # Extract the chunk
        chunks << text[current_pos...end_pos].strip
        current_pos = end_pos
      end
      
      chunks
    end
    
    def generate_audio_for_part(speaker_key, text)
      # Select the appropriate voice
      voice = @voice_profiles[speaker_key]
      
      begin
        if @tts_provider == "openai"
          generate_audio_with_openai(text, voice)
        else
          generate_audio_with_custom_service(text, voice)
        end
      rescue => e
        Rails.logger.error("TTS generation error: #{e.message}")
        { success: false, error: e.message }
      end
    end
    
    def generate_audio_with_openai(text, voice)
      # Call OpenAI TTS API
      uri = URI.parse("https://api.openai.com/v1/audio/speech")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@openai_api_key}"
      request.body = {
        model: @tts_model,
        voice: voice,
        input: text,
        response_format: "mp3"
      }.to_json
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      if response.code == "200"
        { success: true, audio_data: response.body }
      else
        error_message = "OpenAI TTS API error: #{response.code}"
        begin
          error_data = JSON.parse(response.body)
          error_message = "OpenAI TTS API error: #{error_data['error']['message']}"
        rescue
          # Use the default error message if we can't parse the response
        end
        
        Rails.logger.error(error_message)
        { success: false, error: error_message }
      end
    end
    
    def generate_audio_with_custom_service(text, voice)
      # Call custom TTS service
      uri = URI.parse("#{@tts_service_url}/generate")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = {
        text: text,
        voice: voice,
        format: "mp3"
      }.to_json
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
      
      if response.code == "200"
        { success: true, audio_data: response.body }
      else
        error_message = "Custom TTS service error: #{response.code}"
        Rails.logger.error(error_message)
        { success: false, error: error_message }
      end
    end
    
    def combine_audio_files(audio_files)
      return nil if audio_files.empty?
      
      begin
        # Ensure files are in correct order
        ordered_files = audio_files.sort_by { |f| f[:index] }
        
        # Create a combined filename
        timestamp = Time.now.to_i
        combined_filename = "combined_dialog_#{timestamp}.mp3"
        combined_path = "#{Rails.root}/public/uploads/expert_dialog/#{combined_filename}"
        
        # Get the file paths
        file_paths = ordered_files.map { |f| f[:path] }.join(" ")
        
        # Use system command to combine files
        # This assumes ffmpeg is installed on the server
        # You might need to customize this based on your server environment
        if system("which ffmpeg > /dev/null 2>&1")
          # Create file list for ffmpeg
          list_file = "#{Rails.root}/tmp/ffmpeg_list_#{timestamp}.txt"
          File.open(list_file, "w") do |f|
            ordered_files.each do |audio|
              f.puts "file '#{audio[:path]}'"
            end
          end
          
          # Use ffmpeg to concatenate the files
          system("ffmpeg -f concat -safe 0 -i #{list_file} -c copy #{combined_path}")
          
          # Clean up the list file
          File.delete(list_file) if File.exist?(list_file)
        else
          # Fallback to simple concatenation
          system("cat #{file_paths} > #{combined_path}")
        end
        
        # Return the URL for the combined file
        "/uploads/expert_dialog/#{combined_filename}"
      rescue => e
        Rails.logger.error("Audio combining error: #{e.message}")
        nil
      end
    end
  end
end 