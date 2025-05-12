module ExpertDialog
  class PerformanceMonitor
    def self.track_api_call(service, method, &block)
      start_time = Time.now
      
      # Execute the API call
      begin
        result = block.call
        
        # Calculate metrics
        end_time = Time.now
        duration = end_time - start_time
        
        # Record metrics
        record_metric("api.#{service}.#{method}", duration)
        
        result
      rescue => e
        # Record error metric
        record_metric("api.#{service}.#{method}.error", 1)
        
        # Re-raise the exception
        raise e
      end
    end
    
    def self.record_metric(key, value)
      metrics = PluginStore.get("expert_dialog_metrics", "daily_#{Date.today}") || {}
      metrics[key] ||= {count: 0, total: 0, min: nil, max: nil}
      
      metrics[key][:count] += 1
      metrics[key][:total] += value
      metrics[key][:min] = [metrics[key][:min] || value, value].min
      metrics[key][:max] = [metrics[key][:max] || value, value].max
      
      PluginStore.set("expert_dialog_metrics", "daily_#{Date.today}", metrics)
    end
    
    def self.get_daily_metrics(date = Date.today)
      metrics = PluginStore.get("expert_dialog_metrics", "daily_#{date}") || {}
      
      # Calculate averages
      metrics.each do |key, data|
        if data[:count] > 0
          data[:avg] = data[:total] / data[:count]
        end
      end
      
      metrics
    end
    
    # Register with documentation system
    ExpertDialog::DocumentationRegistry.register(
      type: "service",
      name: "performance_monitor",
      methods: self.methods(false) - Object.methods,
      file: __FILE__
    )
  end
end 