module ExpertDialog
  class PromptBuilder
    def initialize
      # Register with documentation system
      ExpertDialog::DocumentationRegistry.register(
        type: "service",
        name: "prompt_builder",
        methods: self.methods(false),
        file: __FILE__
      )
    end
    
    def build_dialog_prompt(topic_data, posts_data, options = {})
      ExpertDialog::StateTracker.track_operation("build_prompt") do
        # Extract topic metadata
        title = topic_data[:title]
        tags = topic_data[:tags] || []
        
        # Format the posts data
        formatted_posts = format_posts(posts_data)
        
        # Extract key terms
        key_terms = extract_key_terms(posts_data)
        
        # Identify consensus and contention points
        consensus = identify_consensus(posts_data)
        contention = identify_contention(posts_data)
        
        # Load expert personas
        expert1 = options[:expert1] || default_expert1
        expert2 = options[:expert2] || default_expert2
        
        # Build the complete prompt
        prompt = build_system_context
        prompt += build_topic_context(title, tags, posts_data)
        prompt += build_posts_section(formatted_posts)
        prompt += build_themes_section(key_terms, consensus, contention)
        prompt += build_experts_section(expert1, expert2)
        prompt += build_dialog_instructions(options)
        
        prompt
      end
    end
    
    private
    
    def build_system_context
      "SYSTEM: You are generating a specialized analytical dialog between two experts reviewing discussions from a forum of senior policymakers and defense intellectuals. The dialog should reflect deep domain knowledge of international relations, security studies, and defense policy while maintaining a natural conversational flow. Focus on distilling complex technical discussions into accessible insights without losing substantive depth.\n\n"
    end
    
    def build_topic_context(title, tags, posts_data)
      # Format date range
      start_date = posts_data.min_by { |p| p[:created_at] }[:created_at].strftime("%B %d, %Y")
      end_date = posts_data.max_by { |p| p[:created_at] }[:created_at].strftime("%B %d, %Y")
      
      context = "FORUM TOPIC ANALYSIS:\n"
      context += "Title: \"#{title}\"\n"
      context += "Tags: #{tags.join(', ')}\n"
      context += "Timeframe: #{start_date} - #{end_date}\n\n"
      
      # Add participation metrics
      context += "PARTICIPATION METRICS:\n"
      context += "- #{posts_data.length} posts from #{posts_data.map { |p| p[:username] }.uniq.length} contributors\n"
      
      # Find most active contributors
      contributor_counts = Hash.new(0)
      posts_data.each { |p| contributor_counts[p[:username]] += 1 }
      top_contributors = contributor_counts.sort_by { |_, count| -count }.first(3)
      
      context += "- Most active contributors: #{top_contributors.map { |name, count| "#{name} (#{count})" }.join(', ')}\n\n"
      
      context
    end
    
    def build_posts_section(formatted_posts)
      section = "KEY POSTS:\n"
      section += formatted_posts
      section += "\n\n"
      
      section
    end
    
    def format_posts(posts_data)
      # Select most relevant posts (sorted by score)
      selected_posts = posts_data.sort_by { |p| p[:score] || 0 }.reverse.first(10)
      
      formatted = []
      
      selected_posts.each_with_index do |post, index|
        post_text = "#{index + 1}. Contributor: #{post[:username]}\n"
        post_text += "   Post timestamp: #{post[:created_at].strftime("%B %d, %Y, %H:%M")}\n"
        post_text += "   Content: \"#{truncate_text(post[:raw], 500)}\"\n"
        post_text += "   Reactions: #{post[:like_count] || 0} likes\n"
        
        # Extract links if available
        if post[:link_counts].present?
          links = post[:link_counts].map { |l| l[:url] }.join(", ")
          post_text += "   Referenced sources: [#{links}]\n"
        end
        
        formatted << post_text
      end
      
      formatted.join("\n")
    end
    
    def extract_key_terms(posts_data)
      # This would ideally use NLP, but for now use a simple approach
      # Combine all post content
      all_text = posts_data.map { |p| p[:raw] }.join(" ")
      
      # Simple frequency analysis (placeholder)
      # In a real implementation, this would use proper NLP techniques
      
      # For demonstration, return some dummy terms
      [
        "strategic balance",
        "deterrence theory",
        "force posture",
        "bilateral negotiations",
        "regional tensions",
        "security assurances",
        "treaty obligations",
        "military modernization"
      ]
    end
    
    def identify_consensus(posts_data)
      # Placeholder - would use sentiment analysis in real implementation
      [
        "Diplomatic channels should remain open despite tensions",
        "Regional security architecture needs strengthening",
        "Military-to-military communication is essential for crisis management",
        "Technology transfer controls need to be reevaluated"
      ]
    end
    
    def identify_contention(posts_data)
      # Placeholder - would use sentiment analysis in real implementation
      [
        "Whether sanctions are effective policy tools in this context",
        "The role of third-party mediators in the dispute",
        "Implications of new weapons deployments for strategic stability",
        "Balance between transparency and operational security"
      ]
    end
    
    def default_expert1
      {
        name: "Dr. Eleanor Phillips",
        background: [
          "15 years at the Department of Defense (Strategic Planning)",
          "Ph.D. in International Security from Georgetown",
          "Former advisor to NATO on deterrence policy"
        ],
        expertise: [
          "Nuclear strategy and non-proliferation",
          "Great power competition in multipolar contexts",
          "Defense technology assessment",
          "Military force posture and readiness"
        ],
        traits: [
          "Pragmatic with emphasis on operational realities",
          "Frequently cites historical precedents",
          "Considers resource constraints and feasibility"
        ]
      }
    end
    
    def default_expert2
      {
        name: "Professor James Chen",
        background: [
          "Director, Global Security Program at International Peace Institute",
          "Former diplomat with State Department (East Asia Bureau)",
          "Ph.D. in Political Science from Princeton"
        ],
        expertise: [
          "Alliance dynamics and security cooperation",
          "Emerging technologies and cyber warfare",
          "Regional security in the Indo-Pacific",
          "Institutional frameworks for conflict management"
        ],
        traits: [
          "Systems-oriented with focus on structural factors",
          "Emphasizes normative and legal frameworks",
          "Considers diversity of stakeholder perspectives"
        ]
      }
    end
    
    def build_experts_section(expert1, expert2)
      section = "EXPERT PROFILES:\n\n"
      
      # Format Expert 1
      section += "#{expert1[:name]}\n"
      section += "Background:\n"
      expert1[:background].each { |b| section += "- #{b}\n" }
      section += "Expertise:\n"
      expert1[:expertise].each { |e| section += "- #{e}\n" }
      section += "Communication traits:\n"
      expert1[:traits].each { |t| section += "- #{t}\n" }
      
      section += "\n"
      
      # Format Expert 2
      section += "#{expert2[:name]}\n"
      section += "Background:\n"
      expert2[:background].each { |b| section += "- #{b}\n" }
      section += "Expertise:\n"
      expert2[:expertise].each { |e| section += "- #{e}\n" }
      section += "Communication traits:\n"
      expert2[:traits].each { |t| section += "- #{t}\n" }
      
      section += "\n"
      
      section
    end
    
    def build_themes_section(key_terms, consensus, contention)
      section = "IDENTIFIED THEMES:\n"
      key_terms.each_with_index { |term, i| section += "#{i+1}. #{term}\n" }
      section += "\n"
      
      section += "AREAS OF CONSENSUS:\n"
      consensus.each { |point| section += "- #{point}\n" }
      section += "\n"
      
      section += "POINTS OF CONTENTION:\n"
      contention.each { |point| section += "- #{point}\n" }
      section += "\n"
      
      section
    end
    
    def build_dialog_instructions(options)
      max_length = options[:max_length] || SiteSetting.expert_dialog_max_length || 1200
      
      instructions = "DIALOG INSTRUCTIONS:\n"
      instructions += "Generate a natural, substantive dialog between these experts discussing the forum topic. The dialog should:\n\n"
      
      instructions += "1. Begin with #{default_expert1[:name]} establishing context on the significance of the topic\n"
      instructions += "2. Feature alternating analysis exploring the key themes identified above\n"
      instructions += "3. Reference specific points from the forum discussion\n"
      instructions += "4. Balance technical specificity with strategic implications\n"
      instructions += "5. Consider operational, technological, and strategic dimensions\n"
      instructions += "6. Conclude with forward-looking considerations\n\n"
      
      instructions += "The dialog should feel like a natural conversation between deeply knowledgeable colleagues rather than a formal debate or scripted exchange. Both experts should demonstrate domain expertise while maintaining accessibility.\n\n"
      
      instructions += "Total length: Approximately #{max_length} words with natural paragraph breaks."
      
      instructions
    end
    
    def truncate_text(text, max_length)
      if text.length <= max_length
        text
      else
        text[0..max_length] + "..."
      end
    end
  end
end 