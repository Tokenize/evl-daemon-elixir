defmodule EvlDaemon.EventNotifier do
  @moduledoc """
  This module defines the behaviour of an event notifier.
  """

  @callback filter(event :: EvlDaemon.Event) :: boolean
  @callback notify(event :: EvlDaemon.Event, opts :: [any]) :: atom

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour EvlDaemon.EventNotifier

      alias Experimental.GenStage
      use GenStage
      require Logger

      def start_link(opts \\ []) do
        GenStage.start_link(__MODULE__, opts)
      end

      def init(opts) do
        {:consumer, opts, subscribe_to: [{EvlDaemon.EventDispatcher, selector: fn (event) -> filter(event) end}]}
      end

      @doc """
      Used by the dispatcher to only send events that we are interested in.
      """
      def filter(_term) do
        true
      end

      @doc """
      Log the notification for the event.
      """
      def notify(_event, _opts), do: raise "Override me!"

      # Callbacks

      @doc false
      def handle_events(events, _from, opts) do
        notify(events, opts)

        {:noreply, [], opts}
      end

      defoverridable [filter: 1, notify: 2]
    end
  end
end
