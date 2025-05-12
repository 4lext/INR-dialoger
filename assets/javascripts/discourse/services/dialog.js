import Service from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Service.extend({
  async generateDialogForTopic(topicId) {
    try {
      // Track operation in browser console for debugging
      console.log(`[ExpertDialog] Starting dialog generation for topic ${topicId}`);
      const startTime = new Date();
      
      // Call the server endpoint
      const result = await ajax(`/expert-dialog/generate/${topicId}`, {
        type: "POST"
      });
      
      // Log performance metrics
      const endTime = new Date();
      const duration = (endTime - startTime) / 1000;
      console.log(`[ExpertDialog] Completed dialog generation in ${duration.toFixed(1)}s`);
      
      return result;
    } catch (error) {
      popupAjaxError(error);
      return { success: false, error: error.message || "Unknown error" };
    }
  },
  
  async generateTTS(topicId, postId) {
    try {
      console.log(`[ExpertDialog] Starting TTS generation for post ${postId}`);
      const startTime = new Date();
      
      // Call the server endpoint
      const result = await ajax(`/expert-dialog/tts`, {
        type: "POST",
        data: {
          topic_id: topicId,
          post_id: postId
        }
      });
      
      // Log performance metrics
      const endTime = new Date();
      const duration = (endTime - startTime) / 1000;
      console.log(`[ExpertDialog] Completed TTS generation in ${duration.toFixed(1)}s`);
      
      return result;
    } catch (error) {
      popupAjaxError(error);
      return { success: false, error: error.message || "Unknown error" };
    }
  }
}); 