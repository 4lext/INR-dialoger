import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import I18n from "I18n";

export default class ExpertDialogAudio extends Component {
  @service dialog;
  @service modal;
  
  @tracked isPlaying = false;
  @tracked audioUrl = null;
  @tracked loading = false;
  @tracked error = null;
  
  @action
  async generateAndPlayAudio() {
    if (this.audioUrl) {
      // Audio already generated, just toggle play/pause
      this.toggleAudio();
      return;
    }
    
    this.loading = true;
    this.error = null;
    
    try {
      const result = await this.dialog.generateTTS(
        this.args.topicId,
        this.args.postId
      );
      
      if (result.success) {
        this.audioUrl = result.tts_result.combined_audio;
        // Auto-play after generation
        this.isPlaying = true;
      } else {
        this.error = result.error || "Unknown error generating audio";
        this.modal.show({
          title: I18n.t("expert_dialog.error_title"),
          message: this.error
        });
      }
    } catch (err) {
      this.error = err.message || "Error generating audio";
      this.modal.show({
        title: I18n.t("expert_dialog.error_title"),
        message: this.error
      });
    } finally {
      this.loading = false;
    }
  }
  
  @action
  toggleAudio() {
    this.isPlaying = !this.isPlaying;
  }
  
  @action
  downloadAudio() {
    if (this.audioUrl) {
      // Create a temporary anchor element
      const a = document.createElement("a");
      a.href = this.audioUrl;
      a.download = `expert-dialog-${this.args.postId}.mp3`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }
  }
} 