defmodule EvlDaemon.Email.ApplicationTest do
  use ExUnit.Case
  use Bamboo.Test, shared: true
  doctest EvlDaemon.Email.Application

  test "process_terminating handles atom reason" do
    notification = EvlDaemon.Email.Application.process_terminating(__MODULE__, :foobar)
    notification |> EvlDaemon.Mailer.deliver_now()

    assert_delivered_email(notification)
  end

  test "process_terminating handles tuple reason" do
    reason =
      {{:badmatch, {:error, :econnreset}},
       [
         {EvlDaemon.Connection, :handle_call, 3, [file: 'lib/evl_daemon/connection.ex', line: 55]},
         {:gen_server, :try_handle_call, 4, [file: 'gen_server.erl', line: 615]},
         {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 647]},
         {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}
       ]}

    notification = EvlDaemon.Email.Application.process_terminating(__MODULE__, reason)
    notification |> EvlDaemon.Mailer.deliver_now()

    assert_delivered_email(notification)
  end

  test "process_terminating handles list reason" do
    notification = EvlDaemon.Email.Application.process_terminating(__MODULE__, [{:foo, :bar}])
    notification |> EvlDaemon.Mailer.deliver_now()

    assert_delivered_email(notification)
  end
end
