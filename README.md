# Discourse Expert Dialog Plugin

This plugin generates analytical dialogs between expert personas based on forum discussions about international relations and defense policy.

## Features

- Analyzes forum topics to extract key insights, patterns, and technical points
- Generates natural-sounding dialog between two IR/defense expert personas using Claude API
- Posts dialog either as a topic amendment or as a new reply
- Supports Text-to-Speech for listening to expert dialogs

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
3. Enable the plugin and configure the following:
   - API key for Claude
   - Claude model to use
   - Dialog publishing method (reply or edit topic)
   - TTS options (if needed)

## Usage

1. Navigate to any topic
2. Click the admin wrench icon (requires staff permissions)
3. Select "Generate Expert Dialog"
4. The plugin will analyze the topic and generate a dialog
5. The dialog will be posted according to your settings

## TTS Integration

The plugin supports text-to-speech generation when enabled in settings:

1. Enable TTS in plugin settings
2. Configure TTS service URL and voice settings
3. After a dialog is generated, a "Listen to Dialog" button will appear
4. Click the button to generate and play audio

## Requirements

- Discourse v2.7.0 or higher
- Claude API access
- (Optional) TTS service for audio generation

## License

MIT 