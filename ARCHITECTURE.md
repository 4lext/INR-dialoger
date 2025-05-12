# Discourse Expert Dialog Plugin - Architecture

This document describes the architecture of the Discourse Expert Dialog Plugin.

## Overview

The plugin is designed with a self-documenting architecture and follows a Redux-inspired state management pattern. It consists of several components that work together to:

1. Analyze forum topics
2. Generate expert dialogs using Claude API
3. Publish dialogs to topics
4. (Optional) Generate Text-to-Speech audio

## Component Architecture

```
discourse-expert-dialog/
├── assets/
│   └── javascripts/
│       ├── discourse/
│       │   ├── components/
│       │   │   ├── expert-dialog-audio.js
│       │   │   └── expert-dialog-button.js
│       │   ├── connectors/
│       │   │   ├── topic-admin-menu-buttons/
│       │   │   │   ├── generate-expert-dialog.js
│       │   │   │   └── generate-expert-dialog.hbs
│       │   │   └── after-post-contents/
│       │   │       ├── expert-dialog-audio.js
│       │   │       └── expert-dialog-audio.hbs
│       │   ├── services/
│       │   │   └── dialog.js
│       │   ├── templates/
│       │   │   └── components/
│       │   │       ├── expert-dialog-audio.hbs
│       │   │       └── expert-dialog-button.hbs
│       │   └── initializers/
│       │       └── expert-dialog-init.js
│   └── stylesheets/
│       └── expert-dialog.scss
├── config/
│   ├── locales/
│   │   └── en.yml
│   └── settings.yml
├── lib/
│   └── expert_dialog/
│       ├── documentation_registry.rb
│       ├── state_store.rb
│       ├── state_tracker.rb
│       ├── performance_monitor.rb
│       ├── persistence_middleware.rb
│       ├── actions.rb
│       ├── claude_client.rb
│       ├── prompt_builder.rb
│       ├── content_analyzer.rb
│       ├── dialog_formatter.rb
│       ├── content_publisher.rb
│       └── tts_generator.rb
├── docs/
│   └── components/
├── plugin.rb
└── README.md
```

## Key Components

### Server-Side

1. **DocumentationRegistry**: Self-documents the plugin components and tracks dependencies
2. **StateStore**: Redux-inspired state management with immutable state and actions
3. **ContentAnalyzer**: Analyzes forum topics to extract key insights
4. **PromptBuilder**: Constructs prompts for Claude API
5. **ClaudeClient**: Communicates with Claude API to generate dialogs
6. **DialogFormatter**: Formats Claude responses for Discourse
7. **ContentPublisher**: Publishes dialogs to topics
8. **TTSGenerator**: Generates audio for dialogs

### Client-Side

1. **ExpertDialogButton**: Button to trigger dialog generation
2. **ExpertDialogAudio**: Audio player for generated dialogs
3. **Dialog Service**: Service to communicate with server endpoints

## Data Flow

1. User clicks "Generate Expert Dialog" button
2. Request is sent to server
3. Server initializes state and tracks operation
4. Content analyzer extracts key information from topic
5. Prompt builder creates a prompt for Claude
6. Claude API generates the dialog
7. Dialog is formatted and published to the topic
8. (Optional) TTS is generated for the dialog
9. User sees the new dialog in the topic

## State Management

The plugin uses a Redux-inspired state management pattern:

1. **Actions**: Define state changes through action creators
2. **State Store**: Maintains immutable state
3. **Middlewares**: Handle side effects like persistence
4. **Operation Tracking**: Records performance and errors

## Self-Documentation

The plugin continuously documents itself through:

1. **Component Registry**: Every component registers metadata
2. **Dependency Analysis**: Dependencies are tracked automatically
3. **Documentation Generation**: Markdown files are generated in the docs/components directory

## Performance Monitoring

The plugin includes built-in performance monitoring:

1. **Operation Tracking**: Tracks timing for key operations
2. **API Metrics**: Records API call performance
3. **Error Tracking**: Logs errors and exceptions

## TTS Integration

The Text-to-Speech integration:

1. Extracts dialog parts by speaker
2. Chunks long text for better TTS quality
3. Uses different voices for different experts
4. Combines audio files into a single track
5. Provides download and playback options 