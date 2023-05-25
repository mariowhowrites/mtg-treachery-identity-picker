defmodule MtgTreachery.Airtable.Client do
  def get_roles do
    res = make_airtable_request()

    Map.get(res.body, "records")
    |> get_fields_from_roles()
  end

  defp make_airtable_request do
    [api_key: api_key] = Application.fetch_env!(:mtg_treachery, MtgTreachery.Airtable.Client)

    Req.get!(
      "https://api.airtable.com/v0/app74trpMh7O2kQ3l/Roles",
      headers: [
        authorization:
          "Bearer #{api_key}"
      ]
    )
  end

  defp get_fields_from_roles(roles) do
    Enum.map(roles, fn role -> Map.get(role, "fields") end)
  end
end
