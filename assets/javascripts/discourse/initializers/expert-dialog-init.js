import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";

export default {
  name: "expert-dialog-init",
  
  initialize(container) {
    withPluginApi("1.6.0", api => {
      const siteSettings = container.lookup('service:site-settings');
      
      // Only proceed if the feature is enabled
      if (!siteSettings.expert_dialog_enabled) {
        return;
      }
      
      // For Discourse 3.5+ using Glimmer components
      api.registerTopicDropdownMenuOptions({
        id: "generate-expert-dialog",
        icon: "magic",
        label: "expert_dialog.generate_button",
        title: "expert_dialog.generate_button_title",
        position: 998, // Just before the last built-in option
        group: "moderation",
        
        // Only show for staff members
        displayed() {
          return api.getCurrentUser()?.staff;
        },
        
        action(params) {
          const { topic } = params;
          if (!topic) return;
          
          const dialogService = container.lookup("service:dialog");
          const appController = container.lookup("controller:application");
          
          if (!dialogService) {
            console.error("[ExpertDialog] Dialog service not found");
            return;
          }
          
          appController.set("generating", true);
          
          dialogService.generateDialogForTopic(topic.id).then(result => {
            if (result.success) {
              window.location.reload();
            } else {
              api.dialog.alert({
                message: result.error || I18n.t("expert_dialog.error")
              });
            }
          }).finally(() => {
            appController.set("generating", false);
          });
        }
      });
    });
  }
}; 