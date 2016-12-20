defmodule EvlDaemon.Email.Event do
  import Bamboo.Email

  def build(event, timestamp, recipient, sender) do
    new_email
    |> from(sender)
    |> to(recipient)
    |> subject("Event #{EvlDaemon.Event.description(event)} triggered at #{timestamp}")
    |> text_body("Event: [#{event}] triggered at #{timestamp}.")
  end
end
