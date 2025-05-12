import { apiInitializer } from "discourse/lib/api";
import TopicAdminMenuButton from "../components/topic-admin-menu-button";

export default apiInitializer("0.11.1", api => {
  // Register our component to be used in the topic admin menu
  api.renderInOutlet("topic-admin-menu-buttons", TopicAdminMenuButton);
  
  // Add can_generate_expert_dialog property to topic model
  api.modifyClass("model:topic", {
    pluginId: "discourse-expert-dialog",
    
    can_generate_expert_dialog: function() {
      const siteSettings = api.container.lookup("service:site-settings");
      const currentUser = api.getCurrentUser();
      
      return siteSettings.expert_dialog_enabled && 
             currentUser && 
             currentUser.staff;
    }.property("currentUser.staff")
  });
  
  // Add dialog service
  api.modifyClass("route:application", {
    pluginId: "discourse-expert-dialog",
    
    beforeModel() {
      this._super(...arguments);
      
      // Ensure dialog service is available
      this.container.lookup("service:dialog");
    }
  });
  
  // We're using the after-post-contents connector for the audio component,
  // so we don't need to use the widget decoration approach.
  // This avoids duplication of the audio component in posts.
});
