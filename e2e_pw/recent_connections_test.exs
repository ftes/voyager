defmodule Voyager.E2E.RecentConnectionsTest do
  use Voyager.E2E.Case, async: false, parameterize: Voyager.E2E.Case.projects()

  # test.describe.configure({ mode: 'serial' }): in order under `--seed 0`.
  setup_all %{browser: browser} do
    context = Browser.new_context!(browser)
    page = BrowserContext.new_page!(context)
    ensure_connected(page)
    BrowserContext.close!(context)
    :ok
  end

  describe "ConnectLive › recent connections" do
    test "shows recent connection and disables fill while connected", %{page: page} do
      Page.goto!(page, "/")
      wait_for_live_view(page)

      Expect.to_be_visible!(Page.locator(page, sel(:recent_connections)))
      Expect.to_contain_text!(Page.locator(page, sel(:recent_connections)), node_name())
      Expect.to_be_visible!(Page.locator(page, sel(:disconnect_from_connect)))
      Expect.to_be_disabled!(Page.locator(page, sel(:connect_btn)))
      page |> fill_recent_btn() |> Locator.first() |> Expect.to_be_disabled!()
    end

    test "disconnects from the connect page and re-enables the form", %{page: page} do
      Page.goto!(page, "/")
      wait_for_live_view(page)
      Locator.click!(Page.locator(page, sel(:disconnect_from_connect)))

      Expect.to_be_hidden!(Page.locator(page, sel(:disconnect_from_connect)))
      Expect.to_be_enabled!(Page.locator(page, sel(:connect_btn)))
      page |> fill_recent_btn() |> Locator.first() |> Expect.to_be_enabled!()
    end

    test "fills the form from a recent connection row", %{page: page} do
      ensure_disconnected(page)

      page |> fill_recent_btn() |> Locator.first() |> Locator.click!()
      Expect.to_have_value!(Page.locator(page, sel(:node_name_input)), node_name())
    end
  end
end
