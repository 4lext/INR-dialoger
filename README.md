# Discourse Expert Dialog Plugin

This plugin generates analytical dialogs between expert personas based on forum discussions about international relations and defense policy. It transforms complex technical discussions into engaging, educational dialogs between domain experts.

## Features

- Analyzes forum topics to extract key insights, patterns, and technical points
- Generates natural-sounding dialog between two IR/defense expert personas using Claude API
- Posts dialog either as a topic amendment or as a new reply
- Supports Text-to-Speech (TTS) for listening to expert dialogs
- Self-documenting architecture with state tracking and performance monitoring
- Compatible with Discourse 3.5+ and ember-cli

## Core Philosophy

Every aspect of this plugin is designed to enhance the creation of natural, insightful dialogs between IR/defense experts that effectively distill complex forum discussions.

The plugin prioritizes:
1. **Dialog Quality**: Generating natural, insightful conversations that accurately represent IR/defense discussions
2. **Domain Integrity**: Preserving technical accuracy and appropriate terminology within the international relations and defense policy domain
3. **Self-Documentation**: Maintaining its own documentation and state awareness
4. **User Experience**: Making dialog generation and consumption intuitive
5. **Content Accessibility**: Supporting multiple consumption modes (reading, listening) while maintaining content quality

## Installation

Follow the [plugin installation guide](https://meta.discourse.org/t/install-plugins-in-discourse/19157).

```
cd /var/discourse
./launcher enter app
cd /var/www/discourse/plugins
git clone https://github.com/yourusername/discourse-expert-dialog.git
cd /var/www/discourse
RAILS_ENV=production bundle exec rake assets:precompile
./launcher rebuild app
```

## Configuration

1. Go to Admin > Settings > Plugins
2. Find "Expert Dialog" settings
3. Configure the following:

### Core Settings
- `expert_dialog_enabled`: Enable/disable the plugin
- `expert_dialog_claude_api_key`: Your Anthropic API key
- `expert_dialog_claude_model`: Claude model to use (default: "claude-3-5-sonnet-20241022")
- `expert_dialog_temperature`: Generation temperature (default: 0.7)
- `expert_dialog_max_length`: Maximum dialog length (default: 1200)
- `expert_dialog_publish_method`: How to publish dialogs ("reply" or "edit_topic")

### TTS Settings
- `expert_dialog_enable_tts`: Enable/disable TTS functionality
- `expert_dialog_tts_provider`: TTS provider ("openai" or "custom")
- `expert_dialog_tts_service_url`: URL for custom TTS service
- `expert_dialog_openai_api_key`: OpenAI API key for TTS
- `expert_dialog_tts_model`: OpenAI TTS model ("tts-1" or "tts-1-hd")
- `expert_dialog_tts_voice_1`: Voice for first expert (options: "alloy", "echo", "fable", "onyx", "nova", "shimmer")
- `expert_dialog_tts_voice_2`: Voice for second expert (options: "alloy", "echo", "fable", "onyx", "nova", "shimmer")

## Usage

### Generating a Dialog

1. Navigate to any topic
2. Click the admin wrench icon (requires staff permissions)
3. Select "Generate Expert Dialog"
4. The plugin will analyze the topic and generate a dialog
5. The dialog will be posted according to your settings (as a reply or an edit to the topic)

### Using TTS Functionality

When TTS is enabled:

1. After a dialog is generated, a "Listen to Dialog" button will appear below the post
2. Click the button to generate and play audio
3. The audio will feature different voices for each expert persona
4. You can pause, resume, and download the audio

## Architecture

The plugin uses a self-documenting architecture with the following key components:

### Server-Side Components
- **DocumentationRegistry**: Self-documents plugin components
- **StateStore**: Redux-inspired state management
- **ContentAnalyzer**: Analyzes forum topics
- **PromptBuilder**: Constructs prompts for Claude API
- **ClaudeClient**: Communicates with Claude API
- **DialogFormatter**: Formats dialogs for Discourse
- **ContentPublisher**: Publishes dialogs
- **TTSGenerator**: Generates audio for dialogs

### Client-Side Components
- **TopicAdminMenuButton**: Adds button to the topic admin menu
- **ExpertDialogAudio**: Audio player for dialogs
- **DialogService**: Communicates with server endpoints

For more detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Technical Details

This plugin is built using:
- Modern ember-cli patterns for Discourse 3.5+
- Glimmer components with decorators
- Plugin outlet system for UI integration
- Redux-inspired state management on the server side

## Requirements

- Discourse v3.5.0 or higher
- Anthropic API access for Claude
- (Optional) OpenAI API access for TTS or custom TTS service

## Contributing

Contributions are welcome! When contributing, please follow the core philosophy of the plugin and ensure that all changes enhance the creation of natural, insightful dialogs between IR/defense experts.

## License

MIT 