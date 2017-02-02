# EvlDaemon

**An Elixir API & daemon for the Envisa TPI (DSC) module**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `evl_daemon` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:evl_daemon, "~> 0.1.0"}]
    end
    ```

  2. Ensure `evl_daemon` is started before your application:

    ```elixir
    def application do
      [applications: [:evl_daemon]]
    end
    ```

## Usage

  1. Edit the *evl_daemon.conf* file under the **config** directory (you can use evl_daemon.conf.sample as a template) and set your API keys, IP address and password.

  2. Build a release by running one of the two commands:
    - `mix release` to build a release in development mode (no emails will be sent in this mode).
    - `MIX_ENV=prod mix release --env prod` to build a release in production mode.
   
  3. Run evl_daemon in one of the following ways (replace env with either *prod* / *dev*):
    - Interactive: `_build/env/rel/evl_daemon/bin/evl_daemon console`
    - Foreground: _build/env/rel/evl_daemon/bin/evl_daemon foreground
    - Daemon: _build/env/rel/evl_daemon/bin/evl_daemon start
