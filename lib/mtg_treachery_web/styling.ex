defmodule MtgTreacheryWeb.Styling do
  def role_background(role) do
    case role do
      "Leader" -> "bg-leader"
      "Guardian" -> "bg-guardian"
      "Assassin" -> "bg-assassin"
      "Traitor" -> "bg-traitor"
    end
  end
end
