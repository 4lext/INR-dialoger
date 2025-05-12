module ExpertDialog
  class StateTracker
    def self.track_operation(operation_name, &block)
      start_time = Time.now
      
      # Log operation start
      Rails.logger.info("[ExpertDialog] Starting operation: #{operation_name}")
      
      # Execute the operation
      begin
        result = block.call
        
        # Log operation end
        end_time = Time.now
        duration = end_time - start_time
        Rails.logger.info("[ExpertDialog] Completed operation: #{operation_name} in #{duration.round(2)}s")
        
        # Save operation metadata
        store_operation_metadata(
          operation_name,
          start_time,
          end_time,
          duration,
          true
        )
        
        result
      rescue => e
        # Log operation error
        end_time = Time.now
        duration = end_time - start_time
        Rails.logger.error("[ExpertDialog] Error in operation: #{operation_name} after #{duration.round(2)}s - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        
        # Save operation metadata with error
        store_operation_metadata(
          operation_name,
          start_time,
          end_time,
          duration,
          false,
          e.message
        )
        
        # Re-raise the exception
        raise e
      end
    end
    
    def self.list_recent_operations(limit = 10)
      operations = PluginStore.get("expert_dialog_operations") || {}
      
      # Sort by timestamp (newest first)
      operations.sort_by { |key, value| value[:start_time] }.reverse.first(limit)
    end
    
    private
    
    def self.store_operation_metadata(name, start_time, end_time, duration, success, error_message = nil)
      operations = PluginStore.get("expert_dialog_operations") || {}
      
      # Generate a unique key for this operation
      operation_key = "op_#{start_time.to_i}"
      
      # Store the operation metadata
      operations[operation_key] = {
        name: name,
        start_time: start_time,
        end_time: end_time,
        duration: duration.round(2),
        success: success
      }
      
      # Add error message if present
      if error_message.present?
        operations[operation_key][:error] = error_message
      end
      
      # Save back to the store
      PluginStore.set("expert_dialog_operations", operations)
    end
    
    # Register with documentation system
    ExpertDialog::DocumentationRegistry.register(
      type: "service",
      name: "state_tracker",
      methods: self.methods(false) - Object.methods,
      file: __FILE__
    )
  end
end 