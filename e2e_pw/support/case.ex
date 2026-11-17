defmodule Voyager.E2E.Case do
  @moduledoc false

  # playwright.config.ts sequences projects around the app's global state (one NodeSession,
  # the mock tree on the target node, the pid format, saved connections). ExUnit runs every
  # async module first, then the sync ones one by one:
  #
  #   * async: the projects that only read a connected session (ets, node, sidebar) and the
  #     supervision-tree projects. `group:` runs a spec file's modules in sequence, as
  #     upstream's `fullyParallel: false` plus the chromium -> firefox dependency.
  #   * sync: everything that disconnects or reconnects (connect-form, connect,
  #     unreadable-secrets, recent-connections) and processes (global pid format).
  use ExUnit.CaseTemplate
  use Playwright.Test

  alias Playwright.{Browser, BrowserContext}
  alias Playwright.Test.BrowserPool

  @devices %{chromium: "Desktop Chrome", firefox: "Desktop Firefox"}

  def projects(names \\ [:chromium, :firefox]), do: for(name <- names, do: %{browser_name: name})

  using do
    quote do
      use Playwright.Test
      alias Playwright.{Browser, BrowserContext, Expect, Locator, Page}
      import Voyager.E2E.Fixtures
      @moduletag :e2e
    end
  end

  setup_all %{browser_name: name} do
    %{browser: BrowserPool.browser(browser_name: name)}
  end

  setup %{browser: browser, browser_name: name} do
    device = Map.fetch!(Playwright.devices(BrowserPool.playwright(browser)), @devices[name])
    context = Browser.new_context!(browser, device)
    %{context: context, page: BrowserContext.new_page!(context)}
  end
end
