defmodule KV.Bucket do
  @doc """
  Starts a new Bucket.
  """
  def start_link do
    Agent.start_link fn -> %{} end
  end

  @doc """
  Gets a value from the `bucket` by `item`,
  """
  def get(bucket, item) do
    # Agent.get(bucket, fn store -> Map.get(store, item) end)
    # Agent.get(bucket, &Map.get(&1, item))
    Agent.get(bucket, &(&1)) |> Map.get(item)
  end

  @doc """
  Puts the `quantity` for the given `item` in the `bucket`.
  """
  def put(bucket, item, quantity) do
    # Agent.update(bucket, fn store -> Map.put(store, item, quantity) end)
    Agent.update(bucket, &Map.put(&1, item, quantity))
  end

  @doc """
  Deletes `item` from `bucket`.

  Returns the deleted `item`'s quantity, if exists.
  """
  def delete(bucket, item) do
    Agent.get_and_update(bucket, &Map.pop(&1, item))
  end
end
