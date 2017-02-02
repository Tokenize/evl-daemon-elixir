defmodule EvlDaemon.Email.Application do
  import Bamboo.Email

  def starting(version) do
    base_email()
    |> subject("EvlDaemon v#{version} starting up...")
  end

  def stopping(version) do
    base_email()
    |> subject("EvlDaemon v#{version} stopping...")
  end

  def process_terminating(module, reason) when is_tuple(reason) do
    actual_reason = elem(reason, 0)
    reason_trace = elem(reason, 1)

    base_email()
    |> subject("#{inspect module} terminating due to #{inspect actual_reason}")
    |> text_body(Exception.format_stacktrace(reason_trace) <> default_body())
  end

  def process_terminating(module, reason) do
    base_email()
    |> subject("#{inspect module} terminating due to #{inspect reason}")
  end

  def base_email do
    new_email()
    |> from(sender())
    |> to(recipient())
    |> text_body(default_body())
  end

  # Private functions

  defp sender do
    Application.get_env(:evl_daemon, :system_emails_sender)
  end

  defp recipient do
    Application.get_env(:evl_daemon, :system_emails_recipient)
  end

  defp default_body do
    "Node: #{Node.self()}, UTC Time: #{DateTime.utc_now}"
  end
end
