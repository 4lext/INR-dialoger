import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { computed } from "@ember/object";

export default class AdminExpertDialogSettings extends Component {
  @service siteSettings;
  @service currentUser;
  @service store;
  
  @tracked isDirty = false;
  @tracked isSaving = false;
  @tracked saveError = null;
  
  claudeModels = [
    { id: "claude-3-opus-20240229", name: "Claude 3 Opus" },
    { id: "claude-3-5-sonnet-20241022", name: "Claude 3.5 Sonnet" },
    { id: "claude-3-5-haiku-latest", name: "Claude 3 Haiku" },
    { id: "claude-3-7-sonnet-latest", name: "Claude 3.7 Sonnet" }
  ];
  
  publishMethods = [
    { id: "reply", name: I18n.t("expert_dialog.settings.publish_reply") },
    { id: "edit_topic", name: I18n.t("expert_dialog.settings.publish_edit") }
  ];
  
  ttsProviders = [
    { id: "openai", name: "OpenAI" },
    { id: "custom", name: I18n.t("expert_dialog.settings.custom_provider") }
  ];
  
  ttsModels = [
    { id: "tts-1", name: "TTS-1 (Standard)" },
    { id: "tts-1-hd", name: "TTS-1-HD (High Quality)" }
  ];
  
  get ttsVoices() {
    if (this.siteSettings.expert_dialog_tts_provider === "openai") {
      return [
        { id: "alloy", name: "Alloy" },
        { id: "echo", name: "Echo" },
        { id: "fable", name: "Fable" },
        { id: "onyx", name: "Onyx" },
        { id: "nova", name: "Nova" },
        { id: "shimmer", name: "Shimmer" }
      ];
    } else {
      return [
        { id: "female_voice_1", name: I18n.t("expert_dialog.settings.female_voice_1") },
        { id: "female_voice_2", name: I18n.t("expert_dialog.settings.female_voice_2") },
        { id: "male_voice_1", name: I18n.t("expert_dialog.settings.male_voice_1") },
        { id: "male_voice_2", name: I18n.t("expert_dialog.settings.male_voice_2") }
      ];
    }
  }
  
  get isOpenAIProvider() {
    return this.siteSettings.expert_dialog_tts_provider === "openai";
  }
  
  get isCustomProvider() {
    return this.siteSettings.expert_dialog_tts_provider === "custom";
  }
  
  @action
  updateSetting(settingName, value) {
    this.siteSettings[settingName] = value;
    this.isDirty = true;
    
    // If TTS provider is changed, update voices to defaults for that provider
    if (settingName === "expert_dialog_tts_provider") {
      if (value === "openai") {
        this.siteSettings.expert_dialog_tts_voice_1 = "alloy";
        this.siteSettings.expert_dialog_tts_voice_2 = "onyx";
      } else {
        this.siteSettings.expert_dialog_tts_voice_1 = "female_voice_1";
        this.siteSettings.expert_dialog_tts_voice_2 = "male_voice_1";
      }
    }
  }
  
  @action
  async saveSettings() {
    this.isSaving = true;
    this.saveError = null;
    
    try {
      // In a real implementation, this would save to the server
      // For now, we'll just simulate success
      await new Promise(resolve => setTimeout(resolve, 500));
      
      this.isDirty = false;
      this.isSaving = false;
    } catch (error) {
      this.saveError = error.message || I18n.t("expert_dialog.settings.save_error");
      this.isSaving = false;
    }
  }
} 