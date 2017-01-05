defmodule EvlDaemon.Email.Application do
  import Bamboo.Email

  def starting(version) do
    base_email
    |> subject("EvlDaemon v#{version} starting up...")
  end

  def stopping(version) do
    base_email
    |> subject("EvlDaemon v#{version} stopping...")
  end

  def base_email do
    new_email
    |> from(sender)
    |> to(recipient)
    |> text_body("Node: #{Node.self}, UTC Time: #{DateTime.utc_now}")
  end

  # Private functions

  defp sender do
    Application.get_env(:evl_daemon, :system_emails_sender)
  end

  defp recipient do
    Application.get_env(:evl_daemon, :system_emails_recipient)
  end
end
