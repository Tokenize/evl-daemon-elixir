defmodule EvlDaemon.EventNotifier.EmailTest do
  use ExUnit.Case
  use Bamboo.Test, shared: true
  doctest EvlDaemon.EventNotifier.Email

  setup do
    EvlDaemon.EventNotifier.Email.start_link(
      recipient: "person@example.com",
      sender: "noreply@example.com"
    )

    :ok
  end

  test "successfully emails the event" do
    EvlDaemon.EventDispatcher.enqueue("60111F9")
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    event = EvlDaemon.Event.new("60111F9", timestamp)
    notification = EvlDaemon.Email.Event.build(event, "person@example.com", "noreply@example.com")

    assert_delivered_email(notification)
  end
end
