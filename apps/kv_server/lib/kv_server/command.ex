defmodule KVServer.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KVServer.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "CREATE  shopping  \r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KVServer.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

    Unknown commands or commands with the wrong number of
    arguments return an error:

      iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KVServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["PUT", bucket, item, quantity] -> {:ok, {:put, bucket, item, quantity}}
      ["GET", bucket, item] -> {:ok, {:get, bucket, item}}
      ["DELETE", bucket, item] -> {:ok, {:delete, bucket, item}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command.
  """
  def run(_command)

  def run({:create, bucket}, pid) do
    KV.Registry.create(pid, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:put, bucket, item, quantity}, pid) do
    lookup bucket, fn bucket_pid ->
      KV.Bucket.put(bucket_pid, item, quantity)
      {:ok, "OK\r\n"}
    end, pid
  end

  def run({:get, bucket, item}, pid) do
    lookup bucket, fn bucket_pid ->
      quantity = KV.Bucket.get(bucket_pid, item)
      {:ok, "#{quantity}\r\nOK\r\n"}
    end, pid
  end

  def run({:delete, bucket, item}, pid) do
    lookup bucket, fn bucket_pid ->
      KV.Bucket.delete(bucket_pid, item)
      {:ok, "OK\r\n"}
    end, pid
  end

  defp lookup(bucket, callback, pid) do
    case KV.Registry.lookup(pid, bucket) do
      {:ok, bucket_pid} -> callback.(bucket_pid)
      :error -> {:error, :not_found}
    end
  end
end
