import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "expert-dialog-init",
  
  initialize() {
    withPluginApi("0.8.31", api => {
      // Add an icon to the topic admin dropdown
      api.addTopicAdminMenuButton({
        icon: "discourse-sparkles",
        title: "expert_dialog.generate_button",
        action: "generateExpertDialog",
        position: "second-last-visible"
      });
      
      // Create the topic admin action
      api.attachWidgetAction("topic-admin-menu", "generateExpertDialog", function() {
        const topicId = this.attrs.topic.id;
        const appController = api.container.lookup("controller:application");
        const dialogService = api.container.lookup("service:dialog");
        
        appController.set("generating", true);
        
        dialogService.generateDialogForTopic(topicId).then(result => {
          if (result.success) {
            window.location.reload();
          } else {
            bootbox.alert(result.error || I18n.t("expert_dialog.error"));
          }
        }).finally(() => {
          appController.set("generating", false);
        });
      });
    });
  }
}; 