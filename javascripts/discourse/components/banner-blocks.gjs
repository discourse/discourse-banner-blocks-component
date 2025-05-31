import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { eq } from "truth-helpers";
import concatClass from "discourse/helpers/concat-class";
import { renderAvatar } from "discourse/helpers/user-avatar";

export default class BannerBlocks extends Component {
  @service router;
  @service store;
  @service site;
  @service siteSettings;

  @tracked solvedTopics = null;

  constructor() {
    super(...arguments);
    const hasSolved = this.formattedSetting.some(
      (item) => item.source === "solved_topics"
    );
    if (hasSolved) {
      this.getSolvedTopics();
    }
  }

  get shouldShow() {
    const targets = this.siteSettings.top_menu
      .split("|")
      .map((opt) => `discovery.${opt}`);
    return (
      targets.includes(this.router.currentRouteName) && this.site.desktopView
    );
  }

  get formattedSetting() {
    const rawSettings = JSON.parse(settings.banner_blocks);
    return rawSettings.map((block) => {
      return {
        ...block,
        customStyles: block.color
          ? htmlSafe(`--banner-box-color: ${block.color};`)
          : null,
      };
    });
  }

  @action
  async getSolvedTopics() {
    const topicList = await this.store.findFiltered("topicList", {
      filter: "latest",
      params: {
        order: "activity",
        solved: "yes",
      },
    });

    if (topicList.topics) {
      topicList.topics.forEach((topic) => {
        const acceptedUser = topic.posters.find((poster) =>
          poster.description.includes("Accepted Answer")
        );
        if (acceptedUser) {
          topic.answered_by = acceptedUser.user;
        }
      });

      this.solvedTopics = topicList.topics.slice(0, 5);
    }
  }

  <template>
    {{#if this.shouldShow}}
      <div class="banner-blocks">
        {{#each this.formattedSetting as |block index|}}
          <div class="banner-blocks__block" data-block-index={{index}}>
            <div
              class="banner-blocks__block-title"
              style={{block.customStyles}}
            >
              {{block.title}}
            </div>
            <div
              class={{concatClass
                "banner-blocks__block-body"
                (if (eq block.source "solved_topics") "--with-feed")
              }}
            >
              {{#if (eq block.source "solved_topics")}}
                <ul class="banner-blocks__block-feed">
                  {{#each this.solvedTopics as |t|}}
                    <li>
                      <a href={{t.url}}>
                        {{htmlSafe
                          (renderAvatar t.answered_by imageSize="tiny")
                        }}
                        {{t.title}}
                      </a>
                    </li>
                  {{/each}}
                </ul>
              {{/if}}
              {{htmlSafe block.content}}
            </div>
          </div>
        {{/each}}
      </div>
    {{/if}}
  </template>
}
