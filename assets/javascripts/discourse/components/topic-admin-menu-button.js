import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { getOwner } from "@ember/application";
import bootbox from "bootbox";
import I18n from "I18n";

export default class TopicAdminMenuButton extends Component {
  @service dialog;

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
    
    // Show a confirmation dialog
    bootbox.confirm({
      title: I18n.t("expert_dialog.confirm_title"),
      message: I18n.t("expert_dialog.confirm_message"),
      buttons: {
        confirm: {
          label: I18n.t("expert_dialog.confirm_button"),
          className: "btn-primary"
        }
      },
      callback: result => {
        if (result) {
          // Show a loading modal
          const loading = bootbox.dialog({
            message: `<div class="loading-container">
                        <div class="loading-spinner"></div>
                        <div class="loading-message">${I18n.t("expert_dialog.generating")}</div>
                      </div>`,
            closeButton: false
          });
          
          // Call the dialog service
          this.dialog.generateDialogForTopic(topicId).then(result => {
            loading.modal("hide");
            
            if (result.success) {
              bootbox.alert(I18n.t("expert_dialog.success"));
              
              // Refresh the topic
              const controller = getOwner(this).lookup("controller:topic");
              controller.get("model.postStream").refresh();
            } else {
              bootbox.alert(I18n.t("expert_dialog.error") + ": " + (result.error || "Unknown error"));
            }
          });
        }
      }
    });
  }
} 