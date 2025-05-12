module ExpertDialog
  class DocumentationRegistry
    @@components = {}
    @@dependencies = {}
    
    def self.register(metadata)
      component_id = "#{metadata[:type]}.#{metadata[:name]}"
      @@components[component_id] = metadata
      
      # Analyze the file to extract dependencies if file is provided
      if metadata[:file].present?
        dependencies = extract_dependencies(metadata[:file])
        @@dependencies[component_id] = dependencies
      
        # Auto-generate documentation
        generate_documentation(component_id)
      end
    end
    
    def self.extract_dependencies(file_path)
      # Skip if file doesn't exist
      return { requires: [], includes: [] } unless File.exist?(file_path)
      
      # Parse the Ruby file to find required/imported modules
      content = File.read(file_path)
      requires = content.scan(/require ['"](.*?)['"]/).flatten
      includes = content.scan(/include ([A-Z][A-Za-z0-9::]*)/).flatten
      
      {
        requires: requires,
        includes: includes
      }
    end
    
    def self.generate_documentation(component_id)
      component = @@components[component_id]
      deps = @@dependencies[component_id]
      
      # Generate markdown documentation
      doc = "## #{component[:name]} (#{component[:type]})\n\n"
      doc += "### Methods\n\n"
      if component[:methods].present?
        component[:methods].each do |method|
          doc += "- `#{method}`\n"
        end
      else
        doc += "- No methods documented\n"
      end
      
      doc += "\n### Dependencies\n\n"
      if deps.present?
        deps[:requires].each do |req|
          doc += "- Requires: `#{req}`\n"
        end
        deps[:includes].each do |inc|
          doc += "- Includes: `#{inc}`\n"
        end
        
        if deps[:requires].empty? && deps[:includes].empty?
          doc += "- No dependencies found\n"
        end
      else
        doc += "- No dependencies analyzed\n"
      end
      
      # Get the docs dir path
      docs_dir = "#{Rails.root}/plugins/discourse-expert-dialog/docs/components"
      
      # Create directory if it doesn't exist
      FileUtils.mkdir_p(docs_dir) unless Dir.exist?(docs_dir)
      
      # Save to documentation folder
      File.write(
        "#{docs_dir}/#{component_id}.md",
        doc
      )
    end
    
    def self.components
      @@components
    end
    
    def self.dependencies
      @@dependencies
    end
  end
end 