module ExpertDialog
  class DialogFormatter
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "dialog_formatter",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def format_dialog(claude_response)
      ExpertDialog::StateTracker.track_operation("format_dialog") do
        # Extract the dialog text from Claude response
        dialog_text = claude_response["content"][0]["text"]
        
        # Add header and metadata
        formatted = <<~MARKDOWN
          ## Expert Analysis Dialog
          
          _The following is an analytical dialog between two experts reflecting on the discussion in this topic._
          
          ---
          
          #{dialog_text}
          
          ---
          
          _This dialog was automatically generated based on the discussion in this topic using advanced language models. It represents a synthesis of the key points and perspectives shared by forum participants._
        MARKDOWN
        
        formatted
      end
    end
    
    def extract_dialog_parts(dialog_text)
      parts = []
      
      # Simple regex to extract speaker parts
      # This assumes dialog format like: "Dr. Phillips: Lorem ipsum..."
      dialog_text.scan(/([A-Za-z\.\s]+):\s(.*?)(?=(?:[A-Za-z\.\s]+):|$)/m) do |speaker, text|
        # Clean up speaker name and text
        speaker_name = speaker.strip
        speaker_text = text.strip
        
        parts << {
          speaker: speaker_name,
          text: speaker_text
        }
      end
      
      parts
    end
  end
end 