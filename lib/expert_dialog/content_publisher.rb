module ExpertDialog
  class ContentPublisher
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "content_publisher",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def publish_dialog(topic, dialog_content)
      ExpertDialog::StateTracker.track_operation("publish_dialog") do
        # Determine publishing method from site settings
        method = SiteSetting.expert_dialog_publish_method || "reply"
        
        case method
        when "reply"
          create_reply(topic, dialog_content)
        when "edit_topic"
          update_topic(topic, dialog_content)
        else
          { success: false, error: "Unknown publishing method: #{method}" }
        end
      end
    end
    
    private
    
    def create_reply(topic, dialog_content)
      begin
        # Create a new post in the topic
        creator = PostCreator.new(
          Discourse.system_user,
          topic_id: topic.id,
          raw: dialog_content,
          skip_validations: true
        )
        
        post = creator.create
        
        if post.present?
          { success: true, post_id: post.id, post_number: post.post_number }
        else
          { success: false, error: creator.errors.full_messages.join(", ") }
        end
      rescue => e
        { success: false, error: e.message }
      end
    end
    
    def update_topic(topic, dialog_content)
      begin
        # Get the first post
        first_post = Post.find_by(topic_id: topic.id, post_number: 1)
        
        if first_post.nil?
          return { success: false, error: "First post not found" }
        end
        
        # Check if the post already has a dialog section
        if first_post.raw.include?("## Expert Analysis Dialog")
          # Replace existing dialog
          new_raw = first_post.raw.gsub(
            /## Expert Analysis Dialog.*?---\n\n/m,
            dialog_content
          )
        else
          # Append dialog to the end
          new_raw = first_post.raw + "\n\n" + dialog_content
        end
        
        # Update the post
        revisor = PostRevisor.new(first_post)
        result = revisor.revise!(
          Discourse.system_user,
          { raw: new_raw },
          skip_validations: true
        )
        
        if result
          { success: true, post_id: first_post.id }
        else
          { success: false, error: "Failed to update post" }
        end
      rescue => e
        { success: false, error: e.message }
      end
    end
  end
end 