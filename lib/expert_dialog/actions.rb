module ExpertDialog
  module Actions
    def self.initialize_topic_analysis(topic_id)
      {
        type: 'INITIALIZE_TOPIC_ANALYSIS',
        topic_id: topic_id,
        timestamp: Time.now
      }
    end
    
    def self.set_analysis_status(status)
      {
        type: 'SET_ANALYSIS_STATUS',
        status: status,
        timestamp: Time.now
      }
    end
    
    def self.update_topic_data(data)
      {
        type: 'UPDATE_TOPIC_DATA',
        data: data,
        timestamp: Time.now
      }
    end
    
    def self.set_claude_response(response)
      {
        type: 'SET_CLAUDE_RESPONSE',
        response: response,
        timestamp: Time.now
      }
    end
    
    def self.set_dialog_text(dialog_text)
      {
        type: 'SET_DIALOG_TEXT',
        dialog_text: dialog_text,
        timestamp: Time.now
      }
    end
    
    def self.set_publishing_result(result)
      {
        type: 'SET_PUBLISHING_RESULT',
        result: result,
        timestamp: Time.now
      }
    end
    
    def self.set_tts_result(tts_result)
      {
        type: 'SET_TTS_RESULT',
        tts_result: tts_result,
        timestamp: Time.now
      }
    end
    
    def self.set_error(error_message)
      {
        type: 'SET_ERROR',
        error_message: error_message,
        timestamp: Time.now
      }
    end
  end
  
  # Register with documentation system
  DocumentationRegistry.register(
    type: "module",
    name: "actions",
    methods: Actions.methods(false) - Module.methods,
    file: __FILE__
  )
end 