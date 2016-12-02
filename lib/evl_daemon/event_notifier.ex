defmodule EvlDaemon.EventNotifier do
  @callback filter(term :: String.t) :: boolean
  @callback notify(event :: {String.t, non_neg_integer}) :: atom
end
