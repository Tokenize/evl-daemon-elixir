defmodule EvlDaemon.EventSubscriber do
  @moduledoc """
  This module defines the behaviour for an event subscriber.
  """

  defmacro __using__(_) do
    quote location: :keep do
      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts)
      end

      def init(opts) do
        EvlDaemon.EventDispatcher.subscribe([])

        {:ok, opts}
      end

      def handle_info({:handle_event, event}, _opts) do
        raise "Override me!"
      end

      def handle_info(_info, state) do
        {:noreply, state}
      end

      defoverridable [start_link: 1, init: 1, handle_info: 2]
    end
  end
end
