defmodule CliTest do
  use ExUnit.Case

  test ":help returned by option parsing with -h and --help options" do
    assert Issues.CLI.parse_args(["-h", "anything"]) == :help
    assert Issues.CLI.parse_args(["--help", "anything"]) == :help
  end

  test "three values returned if three given" do
    assert Issues.CLI.parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "count is defaulted if two values given" do
    assert Issues.CLI.parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort ascending orders the correct way" do
    result = Issues.CLI.sort_into_ascending_order(fake_created_at_list(["c", "a", "b"]))
    issues = for issue <- result, do: issue["created_at"]
    assert issues = ~w{a b c}
  end

  defp fake_created_at_list(values) do
    data = for value <- values do
      [{"created_at", value}, {"other_data", "xxx"}]
    end
    Issues.CLI.convert_to_list_of_hashdicts(data)
  end
end
