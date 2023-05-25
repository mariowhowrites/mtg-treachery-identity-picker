defmodule MtgTreachery.Multiplayer.Role do
  alias MtgTreachery.Airtable.Client
  # the cached json of all Treachery roles
  @roles_path "data/roles.json"

  # the cached json of all Treachery configurations per player count
  @configs_path "data/configs.json"

  def all do
    raw_roles = case File.exists?(@roles_path) do
      true -> Jason.decode!(File.read!(@roles_path))
      false -> fetch_roles()
    end

    convert_raw_roles(raw_roles)
  end

  defp fetch_roles() do
    roles = Client.get_roles()

    File.write!(@roles_path, Jason.encode!(roles))

    roles
  end

  defp convert_raw_roles(raw_roles) do
    Enum.map(raw_roles, fn role ->
      for {key, val} <- role, into: %{}, do: {String.to_atom(String.downcase(key)), val}
    end)
  end
end
