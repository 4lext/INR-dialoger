import Component from "@glimmer/component";
import { setOwner } from "@ember/application";
import { inject as service } from "@ember/service";

export default class ExpertDialogAudioConnector extends Component {
  @service siteSettings;
  
  get shouldRender() {
    const { post } = this.args.outletArgs;
    return post?.cooked?.includes("Expert Analysis Dialog") && 
           this.siteSettings.expert_dialog_enable_tts;
  }
  
  constructor() {
    super(...arguments);
    setOwner(this, this.args.owner);
  }
} 