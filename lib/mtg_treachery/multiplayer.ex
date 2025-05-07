defmodule MtgTreachery.Multiplayer do
  @moduledoc """
  The Multiplayer context.
  """

  import Ecto.Query, warn: false
  alias MtgTreachery.Multiplayer
  alias MtgTreachery.LifeTotals
  alias Ecto.Changeset
  alias MtgTreachery.Repo

  alias MtgTreachery.Multiplayer.{Game, Player, Identity, IdentityPicker}
  alias MtgTreachery.LifeTotals

  #
  # Game Functions
  #

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game, preload: [:players])
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id) |> Repo.preload(:players)

  # return the most recent game that inclues the user_uuid amongst players
  def get_game_by_user_uuid(user_uuid) do
    Repo.one(
      from(g in Game,
        join: p in assoc(g, :players),
        where: p.user_uuid == ^user_uuid,
        where: p.game_id == g.id,
        where: p.status != :inactive,
        preload: [:players],
        order_by: [desc: :inserted_at],
        limit: 1
      )
    )
  end

  def get_game_by_game_id(game_id) do
    Repo.one(
      from g in Game,
        where: g.id == ^game_id,
        join: players in assoc(g, :players),
        preload: [players: players]
    )
  end

  # get all games created before provided datetime
  def get_games_older_than_datetime(cutoff_date) do
    Repo.all(
      from(g in Game,
        where: g.inserted_at < ^cutoff_date,
        preload: [:players]
      )
    )
  end

  def create_game(attrs \\ %{}) do
    all_codes = list_game_codes()
    game_code = generate_unique_game_code(all_codes)

    {:ok, game} =
      %Game{game_code: game_code}
      |> Game.changeset(attrs)
      |> Repo.insert()

    {:ok, game}
  end

  def is_game_full(game) do
    length(game.players) == game.player_count
  end

  def get_game_by_game_code(game_code) do
    Repo.get_by(Game, game_code: game_code)
  end

  def leave_game(player) do
    update_player(player, %{status: :inactive})

    # if all players are now inactive, mark game as inactive
    all_active_players =
      get_players_by_game_id(player.game_id)
      |> Enum.filter(&(&1.status !== :inactive))

    if Enum.empty?(all_active_players) do
      update_game(player.game, %{status: :inactive})
    end
  end

  def end_game(game) do
    {:ok, game} = update_game(game, %{status: :inactive})

    LifeTotals.shutdown(game.id)
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  #
  # Player Functions
  #

  def create_player(player_params, game) do
    %Player{}
    |> Player.changeset(player_params)
    |> Changeset.put_assoc(:game, game)
    |> Repo.insert()
    |> maybe_broadcast_new_player(game)
  end

  def get_player_by_user_uuid(user_uuid) do
    player_query =
      from(p in Player,
        where: p.user_uuid == ^user_uuid,
        order_by: [desc: :inserted_at],
        limit: 1
      )

    Repo.one(player_query)
  end

  def get_players_by_game_id(game_id) do
    Repo.all(
      from p in Player,
        where: p.game_id == ^game_id
    )
  end

  def update_player(%Player{} = player, attrs) do
    result =
      player
      |> Player.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, player} ->
        Game.broadcast_game(player.game_id)
        {:ok, player}

      _ ->
        result
    end
  end

  def update_player_identity(player, %{"name" => name, "identity_id" => identity_id}) do
    update_player(player, %{"identity_id" => identity_id, "name" => name})
  end

  def update_player_identity(player, %{"name" => name}) do
    update_player(player, %{"name" => name})
  end

  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  def get_player_by_id!(id),
    do: Repo.get!(Player, id) |> Repo.preload(game: [:players])

  #
  # Multiplayer Functions (interactions between players and games)
  #

  def create_game_with_player(game_params, user_uuid) do
    {:ok, game} = create_game(game_params)
    create_player(%{user_uuid: user_uuid, creator: true}, game)

    {:ok, game}
  end

  def maybe_create_player(player_params, game) do
    case is_game_full(game) do
      true -> {:error, :game_full}
      false -> create_player(player_params, game)
    end
  end

  def maybe_broadcast_new_player({:ok, player}, game) do
    Game.broadcast_game(game.id)

    LifeTotals.add_player(game.id, player.id)
    {:ok, player}
  end

  def maybe_broadcast_new_player({:error, changeset}, _game) do
    {:error, changeset}
  end

  def list_game_codes() do
    codes_query =
      from(g in Game,
        select: {g.game_code}
      )

    Repo.all(codes_query)
  end

  def generate_unique_game_code(all_codes) do
    potential_code = for _ <- 1..6, into: "", do: <<Enum.random(~c"0123456789ABCEFG")>>

    is_duplicate_code =
      Enum.any?(all_codes, fn existing_code ->
        Enum.member?(Tuple.to_list(existing_code), potential_code)
      end)

    case is_duplicate_code do
      true -> generate_unique_game_code(all_codes)
      false -> potential_code
    end
  end

  @doc """
  Starts a game from the pregame lobby.

  The most important thing to do here is assign identities.
  We may also need a "started" toggle on the game itself,
  although we can also infer these things from the presence or absence of identities.
  """
  def start_game(game) do
    picked_identities =
      IdentityPicker.pick_identities(game.player_count, game.rarities)
      |> Enum.shuffle()

    game.players
    |> Enum.zip(picked_identities)
    |> Enum.map(fn {player, identity} -> assign_player_identity(player, identity) end)

    case update_game(game, %{status: :live}) do
      {:ok, _updated_game} ->
        Game.broadcast_game(game.id)
        Game.broadcast_game_start(game.id)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def list_identities() do
    Identity.all()
  end

  def import_all_identities() do
    # This function is now a no-op since we're using JSON as the source of truth
    :ok
  end

  def assign_player_identity(player, identity) do
    attrs = %{
      identity_name: identity.name,
      identity_role: identity.role,
      identity_description: identity.description,
      identity_unveil_cost: identity.unveil_cost,
      identity_rarity: identity.rarity
    }

    # If the player is the Leader, automatically unveil them
    attrs = if identity.role == "Leader", do: Map.put(attrs, :status, :unveiled), else: attrs

    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  def maybe_join_game(%{game_code: game_code, user_uuid: user_uuid, name: name}) do
    possible_game = Repo.get_by(Game, game_code: game_code)

    cond do
      possible_game == nil -> {:error, :invalid_game_code}
      Multiplayer.is_game_full(possible_game) -> {:error, :game_full}
      true -> create_player(%{user_uuid: user_uuid, name: name}, possible_game)
    end
  end
end
