# EvlDaemon

**An Elixir API to the Envisa TPI (DSC) module**

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

