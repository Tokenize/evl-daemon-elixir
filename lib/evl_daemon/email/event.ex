defmodule EvlDaemon.Email.Event do
  import Bamboo.Email

  def build(event, recipient, sender) do
    utc_timestamp =
      event.timestamp
      |> DateTime.from_unix!()
      |> DateTime.to_string()

    new_email()
    |> from(sender)
    |> to(recipient)
    |> subject("Event #{event.description} (#{event.command}) triggered at #{utc_timestamp}")
    |> text_body("Event: [#{event.command}:#{event.data}] triggered at #{utc_timestamp}.")
  end
end
