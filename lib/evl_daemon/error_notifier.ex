defmodule EvlDaemon.ErrorNotifier do
  @moduledoc """
  This module overrides the terminate/2 method from GenServer and sends
  an email notification if the termination reason isn't :normal / :shutdown.
  """

  defmacro __using__(_) do
    quote location: :keep do
      require Logger

      # Callbacks

      @doc false
      def terminate(reason, _state) when reason in [:normal, :shutdown], do: nil
      def terminate(reason, _state) do
        EvlDaemon.Email.Application.process_terminating(__MODULE__, reason) |> EvlDaemon.Mailer.deliver_now
      end
    end
  end
end
