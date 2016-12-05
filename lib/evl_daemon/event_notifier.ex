defmodule EvlDaemon.EventNotifier do
  @callback filter(event :: {String.t, non_neg_integer}) :: boolean
  @callback notify(event :: {String.t, non_neg_integer}) :: atom
end
