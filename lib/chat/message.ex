defmodule Chat.Message do
  import Exredis.Api

  def save(body) do
    :my_redis |> rpush("key", body)
  end

  def get(key) do
    :my_redis |> lrange(key, 0, 100)
  end
end
