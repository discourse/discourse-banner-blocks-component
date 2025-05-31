import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import BannerBlocks from "../../components/banner-blocks";

@classNames("above-main-container-outlet", "banner-block-connectors")
export default class BannerBlockConnectors extends Component {
  <template><BannerBlocks /></template>
}
