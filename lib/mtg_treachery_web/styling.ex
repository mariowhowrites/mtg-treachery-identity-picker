defmodule MtgTreacheryWeb.Styling do
  def role_background(role) do
    case role do
      "Leader" -> "bg-leader"
      "Guardian" -> "bg-guardian"
      "Assassin" -> "bg-assassin"
      "Traitor" -> "bg-traitor"
    end
  end

  def role_background_color(role) do
    case role do
      "Leader" -> "bg-amber-400/50"
      "Guardian" -> "bg-cyan-600/50"
      "Assassin" -> "bg-rose-600/50"
      "Traitor" -> "bg-indigo-900/50"
      _ -> "bg-gray-700"
    end
  end

  def role_text_color(role) do
    case role do
      "Leader" -> "text-amber-400"
      "Guardian" -> "text-cyan-600"
      "Assassin" -> "text-rose-600"
      "Traitor" -> "text-black"
    end
  end
end
