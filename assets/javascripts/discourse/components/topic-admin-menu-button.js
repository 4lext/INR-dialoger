import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { getOwner } from "@ember/application";
import I18n from "I18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class TopicAdminMenuButton extends Component {
  @service dialog;
  @service modal;

  get shouldRender() {
    const currentUser = getOwner(this).lookup("service:current-user");
    return currentUser?.staff && this.args.topic?.can_generate_expert_dialog;
  }

  @action
  generateExpertDialog() {
    const topicId = this.args.topic?.id;
    
    if (!topicId) {
      console.error("[ExpertDialog] No topic ID available");
      return;
    }
    
    // Show a confirmation dialog using Discourse's dialog service
    this.modal.show({
      title: I18n.t("expert_dialog.confirm_title"),
      message: I18n.t("expert_dialog.confirm_message"),
      buttons: [
        {
          label: I18n.t("cancel"),
          class: "btn-cancel"
        },
        {
          label: I18n.t("expert_dialog.confirm_button"),
          class: "btn-primary",
          action: () => this.startDialogGeneration(topicId)
        }
      ]
    });
  }
  
  async startDialogGeneration(topicId) {
    // Show a loading modal
    const loadingModal = this.modal.show({
      title: I18n.t("expert_dialog.generating"),
      message: `<div class="loading-container">
                  <div class="loading-spinner"></div>
                  <div class="loading-message">${I18n.t("expert_dialog.generating")}</div>
                </div>`,
      dismissable: false
    });
    
    try {
      // Call the dialog service
      const result = await this.dialog.generateDialogForTopic(topicId);
      
      // Close loading modal
      loadingModal.close();
      
      if (result.success) {
        this.modal.show({
          title: I18n.t("expert_dialog.success_title"),
          message: I18n.t("expert_dialog.success")
        });
        
        // Refresh the topic
        const controller = getOwner(this).lookup("controller:topic");
        controller.get("model.postStream").refresh();
      } else {
        this.modal.show({
          title: I18n.t("expert_dialog.error_title"),
          message: result.error || I18n.t("expert_dialog.error")
        });
      }
    } catch (error) {
      loadingModal.close();
      popupAjaxError(error);
    }
  }
} 