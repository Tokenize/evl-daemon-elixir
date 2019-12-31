defmodule EvlDaemon.EventNotifier do
  @moduledoc """
  This module defines the behaviour of an event notifier.
  """

  @doc "Determines if the event is interesting to us."
  @callback filter(event :: %EvlDaemon.Event{}) :: boolean

  @doc "Processes the notification for the event."
  @callback notify(event :: %EvlDaemon.Event{}, opts :: [any]) :: any
end
