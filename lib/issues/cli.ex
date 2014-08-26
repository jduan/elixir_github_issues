defmodule Issues.CLI do
  @default_count 4
  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions that
  end up generating a table of the last n issues in a github project.
  """

  def run(argv) do
    argv |>
    parse_args |>
    process
  end

  @doc """
  'argv' can be -h or --help, which returns :help
  Otherwise it is a github username, project name, and (optionally) the number
  of entries to format.
  Return a tuple of {user, project, count}, or :help
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, [user, project, count], _} -> {user, project, String.to_integer count}
      {_, [user, project], _} -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [count | #{@default_count}]
    """
    System.halt(0)
  end

  def process({user, project, _count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> Enum.take(_count)
    # |> convert_to_list_of_hashdicts
    # |> sort_into_ascending_order
    # |> Enum.take(_count)
    # |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_hashdicts(list) do
    list |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues,
              fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end
end
