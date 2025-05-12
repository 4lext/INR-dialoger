import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

export default {
  name: "expert-dialog-init",

  initialize(container) {
    withPluginApi("1.6.0", (api) => {
      const siteSettings = container.lookup("service:site-settings");

      // Only proceed if the feature is enabled
      if (!siteSettings.expert_dialog_enabled) {
        return;
      }

      // For Discourse 3.5+ using modern API
      api.registerTopicFooterButton({
        id: "generate-expert-dialog",
        icon: "magic",
        label: "expert_dialog.generate_button",
        title: "expert_dialog.generate_button",

        // Only show for staff members
        displayed() {
          return api.getCurrentUser()?.staff;
        },

        action() {
          const topicController = container.lookup("controller:topic");
          const topic = topicController?.model;
          if (!topic) {
            return;
          }

          const dialogService = container.lookup("service:dialog");
          const appController = container.lookup("controller:application");

          if (!dialogService) {
            // Log error but don't break the page
            return;
          }

          appController.set("generating", true);

          dialogService
            .generateDialogForTopic(topic.id)
            .then((result) => {
              if (result.success) {
                window.location.reload();
              } else {
                api.dialog.alert({
                  message: result.error || i18n("expert_dialog.error"),
                });
              }
            })
            .finally(() => {
              appController.set("generating", false);
            });
        },
      });
    });
  },
};
