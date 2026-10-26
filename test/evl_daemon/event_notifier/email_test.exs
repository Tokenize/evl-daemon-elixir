defmodule EvlDaemon.EventNotifier.EmailTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions
  doctest EvlDaemon.EventNotifier.Email

  setup do
    start_supervised!(
      {EvlDaemon.EventNotifier.Email,
       [
         [
           recipient: "person@example.com",
           sender: "noreply@example.com"
         ]
       ]}
    )

    :ok
  end

  test "successfully emails the event" do
    EvlDaemon.EventDispatcher.enqueue("60111F9")
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    event = EvlDaemon.Event.new("60111F9", timestamp)
    notification = EvlDaemon.Email.Event.build(event, "person@example.com", "noreply@example.com")
    EvlDaemon.Mailer.deliver(notification)

    assert_email_sent(notification)
  end
end
