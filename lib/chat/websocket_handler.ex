defmodule Chat.WebsocketHandler do
  @behaviour :cowboy_websocket
  def init(req, opts) do
    {:cowboy_websocket, req, opts}
  end

  def terminate(_reason, _req, _opts) do
    Phoenix.PubSub.unsubscribe(:chat_pubsub, "mytopic")
    :ok
  end

  def websocket_init(opts) do
    Phoenix.PubSub.subscribe(:chat_pubsub, "my_topic")
    messages = Chat.Message.get("key") |> Enum.join("\r\n")
    Phoenix.PubSub.broadcast!(:chat_pubsub, "my_topic", {:text, messages})
    {:ok, opts}
  end

  def websocket_handle({:text, content}, opts) do
    Chat.Message.save(content)
    Phoenix.PubSub.broadcast!(:chat_pubsub, "my_topic", {:text, content})
    {:ok, opts}
  end

  def websocket_handle({_frame, opts}) do
    {:ok, opts}
  end

  def websocket_info({:text, content}, opts) do
    {:reply, {:text, content}, opts}
  end

  def websocket_info(_info, opts) do
    {:ok, opts}
  end
end
