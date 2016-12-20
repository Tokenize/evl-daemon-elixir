defmodule EvlDaemon.EventNotifier.EmailTest do
  use ExUnit.Case
  use Bamboo.Test, shared: true
  doctest EvlDaemon.EventNotifier.Email

  setup do
    {:ok, event_dispatcher} = EvlDaemon.EventDispatcher.start_link
    {:ok, _notifier} = EvlDaemon.EventNotifier.Email.start_link(event_dispatcher, [recipient: "person@example.com", sender: "noreply@example.com"])

    {:ok, event_dispatcher: event_dispatcher}
  end

  test "successfully emails the event", %{event_dispatcher: event_dispatcher} do
    EvlDaemon.EventDispatcher.enqueue(event_dispatcher, "60111F9")
    timestamp = DateTime.utc_now |> DateTime.to_unix |> DateTime.from_unix! |> DateTime.to_string
    notification = EvlDaemon.Email.Event.build("60111F9", timestamp, "person@example.com", "noreply@example.com")

    assert_delivered_email(notification)
  end
end
