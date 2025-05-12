module ExpertDialog
  class PersistenceMiddleware
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "middleware",
        name: "persistence_middleware",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def before(action, state)
      # No pre-processing needed
    end
    
    def after(action, prev_state, new_state)
      # Save state to database
      PluginStore.set(
        "expert_dialog", 
        "state_#{Time.now.to_i}", 
        {
          action: action,
          prev_state: prev_state,
          new_state: new_state,
          timestamp: Time.now
        }
      )
    end
  end
end 