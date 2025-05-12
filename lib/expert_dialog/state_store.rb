module ExpertDialog
  class StateStore
    attr_reader :state, :history

    def initialize(initial_state = {})
      @state = initial_state
      @history = []
      @reducers = {}
      @middlewares = []
      
      # Register with documentation system
      document_component
    end

    def register_reducer(key, reducer)
      @reducers[key] = reducer
      self.document_component("reducer", key, reducer.methods(false))
    end

    def register_middleware(middleware)
      @middlewares << middleware
      self.document_component("middleware", middleware.class.name, middleware.methods(false))
    end

    def dispatch(action)
      # Log the action
      @history << {action: action, timestamp: Time.now}
      
      # Run middlewares (pre-processing)
      @middlewares.each { |m| m.before(action, @state) }
      
      # Apply reducers to create new state
      new_state = @state.dup
      @reducers.each do |key, reducer|
        if new_state[key]
          new_state[key] = reducer.reduce(new_state[key], action)
        end
      end
      
      # Save previous state for history
      prev_state = @state
      @state = new_state
      
      # Run middlewares (post-processing)
      @middlewares.each { |m| m.after(action, prev_state, @state) }
      
      # Return the new state
      @state
    end

    private
    
    def document_component(type = "service", name = "state_store", methods = self.methods(false))
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: type,
        name: name,
        methods: methods,
        file: __FILE__
      )
    end
  end
end 