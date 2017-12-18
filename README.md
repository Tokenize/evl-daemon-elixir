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

## HTTP JSON API

The following actions are supported via a simple API which is protected behind an authentication token.
  - Seeing the system status by visiting **/system_status**
  - Seeing a list of the latest 100 events by visiting **/events**
  - Silent-Arming the system by doing a POST request to **/tasks**
  - Deleting an existing task by doing a DELETE request to **/tasks**
  
  All the actions requires setting the *auth_token* parameter and it must match the value in the config file.
  
  ### Tasks
  Currently, there is only one support task type and that is *silent_arm* and to enable it, you can do the following:
  
  ```
  curl --verbose -X POST -H Content-Type:application/json -d "{\"type\":\"silent_arm\", \"zones\":\"[1,5]\"}" http://127.0.0.1:4000/tasks\?auth_token\=SECRET
  ```
  
  If the request is successful then you should get a response with HTTP status 201, otherwise you'll get a response with HTTP status 422 and a description of the error.
  
  To delete this task, you can do the following:
  
  ```
  curl --verbose -X DELETE -H Content-Type:application/json -d "{\"type\":\"silent_arm\", \"zones\":[\"001\",\"005\"]}" http://127.0.0.1:4000/tasks\?auth_token\=SECRET
  ```
  
  The Silent Arm task will automatically terminate when it detects a *System Arming In Progress* or *Partition Armed" event.
