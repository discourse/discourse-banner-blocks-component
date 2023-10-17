import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

function mockWithSolved() {
  settings.banner_blocks = JSON.stringify([
    {
      title: "Manual Content",
      source: "manual",
      content: "Some Content",
      color: "#ff0000",
    },
    {
      title: "Solved Topics",
      source: "solved_topics",
      content: "",
      color: "#00ff00",
    },
  ]);
}

function mockWithoutSolved() {
  settings.banner_blocks = JSON.stringify([
    {
      title: "Manual Content",
      source: "manual",
      content: "Some Content",
      color: "#ff0000",
    },
    {
      title: "More Manual Content",
      source: "manual",
      content: "",
      color: "#00ff00",
    },
  ]);
}

acceptance("BannerBlocks - General", function (needs) {
  test("Banner blocks are visible on a top route", async function (assert) {
    mockWithoutSolved();
    await visit("/");
    assert.dom(".banner-blocks").exists("the banner blocks should appear");
  });

  test("Banner blocks are not visible on other routes", async function (assert) {
    mockWithoutSolved();
    await visit("/u");
    assert
      .dom(".banner-blocks")
      .doesNotExist("the banner blocks should not appear");
  });

  test("Renders solved topics when source is 'solved_topics'", async function (assert) {
    mockWithSolved();
    await visit("/");
    assert
      .dom(".banner-blocks__block-feed")
      .exists("solved topics list should appear");
  });

  test("Does not render solved topics when source is not 'solved_topics'", async function (assert) {
    mockWithoutSolved();
    await visit("/");
    assert
      .dom(".banner-blocks__block-feed")
      .doesNotExist("solved topics list should not appear");
  });

  test("Correct custom styles are applied", async function (assert) {
    mockWithoutSolved();
    await visit("/");

    assert.ok(
      document
        .querySelector(".banner-blocks__block-title")
        .style[0].includes("--banner-box-color"),
      "custom property exists",
    );
  });
});
