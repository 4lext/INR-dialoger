# Discourse Expert Dialog Plugin - Architecture

This document describes the architecture of the Discourse Expert Dialog Plugin, which is compatible with Discourse 3.5+ and uses the ember-cli approach.

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
│       │   │   ├── expert-dialog-audio.hbs
│       │   │   ├── topic-admin-menu-button.js
│       │   │   └── topic-admin-menu-button.hbs
│       │   ├── connectors/
│       │   │   └── after-post-contents/
│       │   │       ├── expert-dialog-audio.js
│       │   │       └── expert-dialog-audio.hbs
│       │   ├── services/
│       │   │   └── dialog.js
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

### Client-Side (ember-cli)

1. **TopicAdminMenuButton**: Component that adds a button to the topic admin menu
2. **ExpertDialogAudio**: Glimmer component for audio playback
3. **DialogService**: Service to communicate with server endpoints
4. **ExpertDialogInit**: Initializer that registers components with plugin outlets
5. **Connectors**: Integration points for post content and other Discourse elements

## Modern Frontend Architecture

The plugin uses modern Discourse 3.5+ frontend patterns:

1. **Glimmer Components**: Using `@glimmer/component` instead of classic Ember components
2. **Tracked Properties**: Using `@tracked` from `@glimmer/tracking` for reactivity
3. **Decorators**: Using `@service`, `@action` decorators
4. **Plugin Outlets**: Using `api.renderInOutlet()` for admin menu integration
5. **Widget Decoration**: Using `api.decorateWidget()` for post content integration
6. **Connectors**: For specific integration points like after-post-contents
7. **Modern Templates**: Using angle bracket component syntax and modifiers

Example of a modern component:

```javascript
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";

export default class ExpertDialogAudio extends Component {
  @service dialog;
  @tracked isPlaying = false;
  
  @action
  toggleAudio() {
    this.isPlaying = !this.isPlaying;
  }
}
```

## Data Flow

1. User clicks "Generate Expert Dialog" button in topic admin menu
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

## Integration with Discourse 3.5+

The plugin integrates with Discourse 3.5+ through:

1. **Plugin Outlets**: Using `api.renderInOutlet()` to add UI elements
2. **API Initialization**: Using `apiInitializer` with version compatibility
3. **Model Extensions**: Using `api.modifyClass()` to extend core models
4. **Widget Decoration**: Using `api.decorateWidget()` for post modifications
5. **Connectors**: Traditional connector pattern for specific integration points 