defmodule EvlDaemon.EventNotifier do
  @callback filter(term :: String.t) :: boolean
  @callback notify(event :: String.t) :: atom
end
