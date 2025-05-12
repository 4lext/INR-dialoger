require 'fileutils'

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
      @tts_service_url = SiteSetting.expert_dialog_tts_service_url
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
        
        # Skip if TTS service URL is not configured
        if @tts_service_url.blank?
          return { success: false, error: "TTS service URL is not configured" }
        end
        
        # Extract each speaker's parts
        dialog_parts = parse_dialog_into_parts(dialog_text)
        
        # Generate audio for each part
        audio_files = []
        
        dialog_parts.each do |part|
          # Generate audio for this part
          audio_data = generate_audio_for_part(part[:speaker], part[:text])
          
          if audio_data
            filename = "dialog_part_#{part[:index]}.mp3"
            path = "#{Rails.root}/public/uploads/expert_dialog/#{filename}"
            
            # Create directory if it doesn't exist
            FileUtils.mkdir_p(File.dirname(path))
            
            # Write audio data to file
            File.open(path, 'wb') do |file|
              file.write(audio_data)
            end
            
            audio_files << {
              path: path,
              url: "/uploads/expert_dialog/#{filename}",
              speaker: part[:speaker],
              index: part[:index]
            }
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
        
        # Split long text into manageable chunks (3000 chars max)
        text_chunks = chunk_text(speaker_text, 3000)
        
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
        # Call TTS service (this is a simplified example)
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
          # Return the binary audio data
          response.body
        else
          Rails.logger.error("TTS generation failed: #{response.body}")
          nil
        end
      rescue => e
        Rails.logger.error("TTS service error: #{e.message}")
        nil
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
        # This is a placeholder - actual implementation depends on available tools
        # You might need to customize this based on your server environment
        system("cat #{file_paths} > #{combined_path}")
        
        # Return the URL for the combined file
        "/uploads/expert_dialog/#{combined_filename}"
      rescue => e
        Rails.logger.error("Audio combining error: #{e.message}")
        nil
      end
    end
  end
end 