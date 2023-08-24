defmodule MtgTreachery.Scryfall.Client do
  def search_scryfall(_query) do
    res = Req.get!("https://api.scryfall.com/cards/search?unique=art&q=sidisi")

    Map.get(res.body, "data")
  end
end
