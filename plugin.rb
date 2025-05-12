# name: discourse-expert-dialog
# about: Generate analytical dialogs between expert personas based on forum discussions about international relations and defense policy
# version: 0.1
# authors: Claude Developer
# url: https://github.com/yourusername/discourse-expert-dialog

register_asset "stylesheets/expert-dialog.scss"

enabled_site_setting :expert_dialog_enabled

PLUGIN_NAME ||= "ExpertDialog".freeze

after_initialize do
  module ::ExpertDialog
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace ExpertDialog
    end
  end
  
  # Load dependencies
  %w[
    lib/expert_dialog/documentation_registry.rb
    lib/expert_dialog/state_store.rb
    lib/expert_dialog/state_tracker.rb
    lib/expert_dialog/performance_monitor.rb
    lib/expert_dialog/persistence_middleware.rb
    lib/expert_dialog/actions.rb
    lib/expert_dialog/claude_client.rb
    lib/expert_dialog/prompt_builder.rb
    lib/expert_dialog/content_analyzer.rb
    lib/expert_dialog/dialog_formatter.rb
    lib/expert_dialog/content_publisher.rb
    lib/expert_dialog/tts_generator.rb
  ].each do |file|
    load File.expand_path("../#{file}", __FILE__) if File.exist?(File.expand_path("../#{file}", __FILE__))
  end
  
  # Initialize documentation directory
  docs_dir = "#{Rails.root}/plugins/discourse-expert-dialog/docs/components"
  FileUtils.mkdir_p(docs_dir) unless Dir.exist?(docs_dir)
  
  # Create controllers
  require_dependency "application_controller"
  
  class ::ExpertDialog::ExpertDialogController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    before_action :ensure_logged_in
    before_action :ensure_staff
    
    def generate
      topic_id = params.require(:topic_id)
      
      # Initialize state for this operation
      state_store = ExpertDialog::StateStore.new({
        status: "initializing",
        topic_id: topic_id,
        start_time: Time.now
      })
      
      # Track the complete dialog generation operation
      ExpertDialog::StateTracker.track_operation("generate_dialog") do
        # Dispatch action to update state
        state_store.dispatch(ExpertDialog::Actions.initialize_topic_analysis(topic_id))
        
        # Get the topic
        topic = Topic.find_by(id: topic_id)
        
        if topic.nil?
          state_store.dispatch(ExpertDialog::Actions.set_analysis_status("error"))
          render json: { success: false, error: "Topic not found" }
          return
        end
        
        # Update state
        state_store.dispatch(ExpertDialog::Actions.set_analysis_status("analyzing"))
        
        # Analyze topic content
        analyzer = ExpertDialog::ContentAnalyzer.new
        analysis = analyzer.analyze_topic(topic)
        
        # Update state with analysis results
        state_store.dispatch(ExpertDialog::Actions.update_topic_data(analysis))
        state_store.dispatch(ExpertDialog::Actions.set_analysis_status("generating"))
        
        # Build prompt for Claude
        prompt_builder = ExpertDialog::PromptBuilder.new
        prompt = prompt_builder.build_dialog_prompt(
          analysis[:topic],
          analysis[:posts],
          {
            max_length: SiteSetting.expert_dialog_max_length || 1200
          }
        )
        
        # Call Claude API
        client = ExpertDialog::ClaudeClient.new
        response = client.generate_dialog(prompt, {
          model: SiteSetting.expert_dialog_claude_model,
          temperature: SiteSetting.expert_dialog_temperature || 0.7
        })
        
        if response.nil?
          state_store.dispatch(ExpertDialog::Actions.set_analysis_status("error"))
          render json: { success: false, error: "Failed to generate dialog" }
          return
        end
        
        # Update state with Claude response
        state_store.dispatch(ExpertDialog::Actions.set_claude_response(response))
        state_store.dispatch(ExpertDialog::Actions.set_analysis_status("formatting"))
        
        # Format the dialog
        formatter = ExpertDialog::DialogFormatter.new
        formatted_dialog = formatter.format_dialog(response)
        
        # Update state with formatted dialog
        state_store.dispatch(ExpertDialog::Actions.set_dialog_text(formatted_dialog))
        state_store.dispatch(ExpertDialog::Actions.set_analysis_status("publishing"))
        
        # Publish the dialog
        publisher = ExpertDialog::ContentPublisher.new
        publish_result = publisher.publish_dialog(topic, formatted_dialog)
        
        # Update state with publishing result
        state_store.dispatch(ExpertDialog::Actions.set_publishing_result(publish_result))
        
        if !publish_result[:success]
          state_store.dispatch(ExpertDialog::Actions.set_analysis_status("error"))
          render json: { success: false, error: publish_result[:error] }
          return
        end
        
        # Generate TTS if enabled
        tts_result = nil
        if SiteSetting.expert_dialog_enable_tts
          state_store.dispatch(ExpertDialog::Actions.set_analysis_status("generating_tts"))
          
          # Generate audio
          tts_generator = ExpertDialog::TTSGenerator.new
          tts_result = tts_generator.generate_audio_for_dialog(response["content"][0]["text"])
          
          # Update state with TTS result
          state_store.dispatch(ExpertDialog::Actions.set_tts_result(tts_result))
        end
        
        # Dialog created successfully
        state_store.dispatch(ExpertDialog::Actions.set_analysis_status("completed"))
        
        # Return the result
        render json: { 
          success: true, 
          result: publish_result,
          tts_enabled: SiteSetting.expert_dialog_enable_tts,
          tts_result: tts_result
        }
      end
    end
    
    def tts
      # Generate TTS for an existing dialog
      topic_id = params.require(:topic_id)
      post_id = params.require(:post_id)
      
      # Find the post
      post = Post.find_by(id: post_id)
      
      if post.nil?
        render json: { success: false, error: "Post not found" }
        return
      end
      
      # Extract the dialog text
      formatter = ExpertDialog::DialogFormatter.new
      dialog_parts = formatter.extract_dialog_parts(post.raw)
      
      if dialog_parts.empty?
        render json: { success: false, error: "No dialog found in post" }
        return
      end
      
      # Combine all dialog parts into a single text
      dialog_text = dialog_parts.map { |part| "#{part[:speaker]}: #{part[:text]}" }.join("\n\n")
      
      # Generate audio
      tts_generator = ExpertDialog::TTSGenerator.new
      tts_result = tts_generator.generate_audio_for_dialog(dialog_text)
      
      render json: { 
        success: tts_result[:success],
        error: tts_result[:error],
        tts_result: tts_result
      }
    end
  end
  
  # Add routes
  ExpertDialog::Engine.routes.draw do
    post "/generate/:topic_id" => "expert_dialog#generate"
    post "/tts" => "expert_dialog#tts"
  end
  
  Discourse::Application.routes.append do
    mount ::ExpertDialog::Engine, at: "expert-dialog"
  end
  
  # Add to topic view
  add_to_serializer(:topic_view, :can_generate_expert_dialog) do
    scope.is_staff? && SiteSetting.expert_dialog_enabled
  end
  
  # Site settings
  DiscoursePluginRegistry.serialized_current_user_fields << "can_generate_expert_dialog"
  
  # Register admin route
  Discourse::Application.routes.append do
    get '/admin/plugins/expert-dialog' => 'admin/plugins#index', constraints: StaffConstraint.new
  end
end 