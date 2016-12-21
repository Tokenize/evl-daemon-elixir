defmodule EvlDaemon.EventNotifier do
  @callback filter(event :: EvlDaemon.Event) :: boolean
  @callback notify(event :: EvlDaemon.Event, opts :: [any]) :: atom
end
