import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class ExpertDialogButton extends Component {
  @service dialog;
  @service store;
  
  @tracked isGenerating = false;
  @tracked workingMessage = "";
  @tracked errorMessage = "";
  
  tagName = "button";
  classNames = ["btn", "btn-default", "expert-dialog-button"];
  attributeBindings = ["disabled"];
  
  get disabled() {
    return this.isGenerating;
  }
  
  @action
  async generateDialog() {
    this.isGenerating = true;
    this.workingMessage = I18n.t("expert_dialog.generating");
    this.errorMessage = "";
    
    try {
      const result = await this.dialog.generateDialogForTopic(this.topicId);
      
      if (result.success) {
        this.workingMessage = I18n.t("expert_dialog.success");
        // Refresh the page after a slight delay to show the new content
        setTimeout(() => {
          window.location.reload();
        }, 1500);
      } else {
        this.errorMessage = result.error || I18n.t("expert_dialog.error");
        this.isGenerating = false;
      }
    } catch (error) {
      this.errorMessage = error.message || I18n.t("expert_dialog.error");
      this.isGenerating = false;
    }
  }
} 