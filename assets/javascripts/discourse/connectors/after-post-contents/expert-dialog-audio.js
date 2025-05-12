import { setOwner } from "@ember/application";

export default {
  setupComponent(attrs, component) {
    const { post } = attrs;
    
    if (post) {
      // Check if this post contains an expert dialog
      component.set('hasExpertDialog', post.cooked.includes('Expert Analysis Dialog'));
      component.set('topicId', post.topic_id);
      component.set('postId', post.id);
    }
    
    // Make sure owner is properly set for service injection
    setOwner(component, this.getOwner(component));
  },
  
  shouldRender(args, component) {
    return component.hasExpertDialog && component.siteSettings.expert_dialog_enable_tts;
  }
}; 