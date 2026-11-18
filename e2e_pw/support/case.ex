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

  def projects(devices \\ ["Desktop Chrome", "Desktop Firefox"]),
    do: for(device <- devices, do: Playwright.Test.parameters(Playwright.device(device)))

  using opts do
    quote do
      use Playwright.Case, unquote(opts)
      import Voyager.E2E.Fixtures
      @moduletag :e2e
    end
  end
end
