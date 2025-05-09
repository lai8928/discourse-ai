import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { defaultHomepage } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";
import { composeAiBotMessage } from "../lib/ai-bot-helper";
import { AI_CONVERSATIONS_PANEL } from "../services/ai-conversations-sidebar-manager";

export default class AiBotHeaderIcon extends Component {
  @service composer;
  @service currentUser;
  @service router;
  @service sidebarState;
  @service siteSettings;

  get bots() {
    const availableBots = this.currentUser.ai_enabled_chat_bots
      .filter((bot) => !bot.is_persosna)
      .filter(Boolean);

    return availableBots ? availableBots.map((bot) => bot.model_name) : [];
  }

  get showHeaderButton() {
    console.log("[AiBotHeaderIcon] showHeaderButton 計算中: bots.length =", this.bots.length, ", ai_bot_add_to_header =", this.siteSettings.ai_bot_add_to_header);
    return this.bots.length > 0 && this.siteSettings.ai_bot_add_to_header;
  }

  get icon() {
    if (this.clickShouldRouteOutOfConversations) {
      return "shuffle";
    }
    return "robot";
  }

  get clickShouldRouteOutOfConversations() {
    return (
      this.siteSettings.ai_enable_experimental_bot_ux &&
      this.sidebarState.currentPanel?.key === AI_CONVERSATIONS_PANEL
    );
  }

  @action
  onClick() {
    if (this.clickShouldRouteOutOfConversations) {
      return this.router.transitionTo(`discovery.${defaultHomepage()}`);
    }

    if (this.siteSettings.ai_enable_experimental_bot_ux) {
      return this.router.transitionTo("discourse-ai-bot-conversations");
    }

    composeAiBotMessage(this.bots[0], this.composer);
  }

  <template>
    {{#if this.showHeaderButton}}
      <li>
        <DButton
          @action={{this.onClick}}
          @icon={{this.icon}}
          title={{i18n "discourse_ai.ai_bot.shortcut_title"}}
          class="ai-bot-button icon btn-flat"
        />
      </li>
    {{/if}}
  </template>
}
