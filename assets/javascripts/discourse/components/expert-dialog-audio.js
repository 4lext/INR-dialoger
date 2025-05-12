import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class ExpertDialogAudio extends Component {
  @service dialog;
  
  @tracked isGenerating = false;
  @tracked audioUrl = null;
  @tracked errorMessage = "";
  
  @action
  async generateAudio() {
    this.isGenerating = true;
    this.errorMessage = "";
    
    try {
      const result = await this.dialog.generateTTS(this.topicId, this.postId);
      
      if (result.success && result.tts_result && result.tts_result.success) {
        this.audioUrl = result.tts_result.combined_audio;
      } else {
        this.errorMessage = result.error || I18n.t("expert_dialog.tts_error");
      }
    } catch (error) {
      this.errorMessage = error.message || I18n.t("expert_dialog.tts_error");
    } finally {
      this.isGenerating = false;
    }
  }
} 