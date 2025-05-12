module ExpertDialog
  class ContentAnalyzer
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "content_analyzer",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def analyze_topic(topic)
      ExpertDialog::StateTracker.track_operation("analyze_topic") do
        # Get topic data
        topic_data = {
          id: topic.id,
          title: topic.title,
          tags: topic.tags.map(&:name),
          created_at: topic.created_at,
          posts_count: topic.posts_count,
          views: topic.views,
          category_id: topic.category_id
        }
        
        # Get posts data
        posts_data = []
        
        # Get up to 100 posts (paginate for larger topics)
        Post.where(topic_id: topic.id)
            .where(deleted_at: nil)
            .where(hidden: false)
            .order(created_at: :asc)
            .limit(100)
            .each do |post|
              
          # Skip the system post
          next if post.post_type != Post.types[:regular]
          
          post_data = {
            id: post.id,
            post_number: post.post_number,
            username: post.user.username,
            created_at: post.created_at,
            updated_at: post.updated_at,
            like_count: post.like_count,
            raw: post.raw,
            cooked: post.cooked,
            reply_to_post_number: post.reply_to_post_number,
            quote_count: post.quote_count,
            incoming_link_count: post.incoming_link_count,
            reads: post.reads,
            score: calculate_post_score(post)
          }
          
          # Add link data if present
          if post.link_counts.present?
            post_data[:link_counts] = post.link_counts
          end
          
          posts_data << post_data
        end
        
        # Return combined analysis
        {
          topic: topic_data,
          posts: posts_data,
          analyzed_at: Time.now
        }
      end
    end
    
    private
    
    def calculate_post_score(post)
      # Simple scoring algorithm to identify relevant posts
      score = 0
      score += post.like_count * 2
      score += post.quote_count * 3
      score += post.incoming_link_count * 2
      score += post.reads * 0.1
      score += post.raw.length * 0.01 # Slight bonus for longer posts
      
      # Penalty for very old posts
      days_old = (Time.now - post.created_at) / 86400
      score -= (days_old * 0.1) if days_old > 30
      
      score.round(2)
    end
  end
end 