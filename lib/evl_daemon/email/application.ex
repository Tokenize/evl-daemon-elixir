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

  def process_terminating(module, {reason, trace} = payload) when is_tuple(payload) do
    base_email()
    |> subject("#{module} terminating due to #{inspect reason}")
    |> text_body(default_body() <> format_trace(trace))
  end

  def process_terminating(module, reason) do
    base_email()
    |> subject("#{module} terminating due to #{inspect reason}")
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

  defp format_trace(trace) when is_list(trace) do
    trace |> Exception.format_stacktrace
  end

  defp format_trace(trace) do
    (trace |> inspect) <> "\n"
  end
end
