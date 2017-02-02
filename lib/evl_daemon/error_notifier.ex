defmodule EvlDaemon.ErrorNotifier do
  defmacro __using__(_) do
    quote location: :keep do
      require Logger

      def terminate(reason, _state) when reason in [:normal, :shutdown], do: nil
      def terminate(reason, _state) do
        EvlDaemon.Email.Application.process_terminating(__MODULE__, reason) |> EvlDaemon.Mailer.deliver_now
      end
    end
  end
end
