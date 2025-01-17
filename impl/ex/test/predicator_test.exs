defmodule PredicatorTest do
  use ExUnit.Case
  import Predicator
  doctest Predicator

  @moduletag :parsing

  describe "BOOLEAN" do
    test "commpiles string key instructions" do
      assert {:ok, [["load", "foo"], ["to_bool"]]} = Predicator.compile("foo")
      assert {:ok, [["load", "foo"], ["to_bool"], ["not"]]} = Predicator.compile("!foo")
      assert {:ok, [["lit", true]]} = Predicator.compile("true")
      assert {:ok, [["lit", false]]} = Predicator.compile("false")
    end

    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:to_bool]]} = Predicator.compile("foo", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:to_bool], [:not]]} =
               Predicator.compile("!foo", :atom_key_inst)

      assert {:ok, [[:lit, true]]} = Predicator.compile("true", :atom_key_inst)
      assert {:ok, [[:lit, false]]} = Predicator.compile("false", :atom_key_inst)
      assert {:ok, [[:lit, true], [:not]]} = Predicator.compile("!true", :atom_key_inst)
      assert {:ok, [[:lit, false], [:not]]} = Predicator.compile("!false", :atom_key_inst)
    end

    test "evaluates to true" do
      assert Predicator.matches?("true") == true
      assert Predicator.matches?("!false") == true
      assert Predicator.matches?("foo", foo: true) == true
      assert Predicator.matches?("!foo", foo: false) == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("!true") == false
      assert Predicator.matches?("false") == false
      assert Predicator.matches?("foo", foo: false) == false
      assert Predicator.matches?("!foo", foo: true) == false
    end
  end

  describe "BETWEEN" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :age], [:lit, 5], [:lit, 10], [:compare, :BETWEEN]]} =
               Predicator.compile("age between 5 and 10", :atom_key_inst)

      assert {:ok, [[:load, :age], [:lit, 5], [:lit, 10], [:compare, :BETWEEN], [:not]]} =
               Predicator.compile("!age between 5 and 10", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "age"], ["lit", 5], ["lit", 10], ["compare", "BETWEEN"], ["not"]]} =
               Predicator.compile("!age between 5 and 10")
    end

    test "evaluates to true" do
      assert Predicator.matches?("7 between 5 and 10") == true
      assert Predicator.matches?("!32 between 5 and 10") == true
      assert Predicator.matches?("age between 5 and 10", age: 7) == true
      assert Predicator.matches?("!age between 5 and 10", age: 14) == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("32 between 5 and 10") == false
      assert Predicator.matches?("!7 between 5 and 10") == false
      assert Predicator.matches?("age between 5 and 10", age: 14) == false
      assert Predicator.matches?("!age between 5 and 10", age: 7) == false
      assert Predicator.matches?("age between 5 and 10", age: nil) == false
    end
  end

  describe "STARTSWITH" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :name], [:lit, "stuff"], [:compare, :STARTSWITH]]} =
               Predicator.compile("name starts with 'stuff'", :atom_key_inst)

      assert {:ok, [[:load, :name], [:lit, "stuff"], [:compare, :STARTSWITH], [:not]]} =
               Predicator.compile("!name starts with 'stuff'", :atom_key_inst)

      assert {:ok, [[:lit, "name"], [:lit, "stuff"], [:compare, :STARTSWITH]]} =
               Predicator.compile("'name' starts with 'stuff'", :atom_key_inst)

      assert {:ok, [[:lit, "name"], [:lit, "stuff"], [:compare, :STARTSWITH], [:not]]} =
               Predicator.compile("!'name' starts with 'stuff'", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "name"], ["lit", "stuff"], ["compare", "STARTSWITH"]]} =
               Predicator.compile("name starts with 'stuff'")

      assert {:ok, [["load", "name"], ["lit", "stuff"], ["compare", "STARTSWITH"], ["not"]]} =
               Predicator.compile("!name starts with 'stuff'")

      assert {:ok, [["lit", "name"], ["lit", "stuff"], ["compare", "STARTSWITH"]]} =
               Predicator.compile("'name' starts with 'stuff'")

      assert {:ok, [["lit", "name"], ["lit", "stuff"], ["compare", "STARTSWITH"], ["not"]]} =
               Predicator.compile("!'name' starts with 'stuff'")

      assert {:ok, [["lit", "name"], ["lit", "stuff"], ["compare", "STARTSWITH"]]} =
               Predicator.compile("\"name\" starts with \"stuff\"")
    end

    test "returns true" do
      assert Predicator.matches?("'joaquin' starts with 'joa'") == true
      assert Predicator.matches?("!'name' starts with 'stuff'") == true
      assert Predicator.matches?("name starts with 'joa'", name: "joaquin") == true
      assert Predicator.matches?("!name starts with 'stuff'", name: "joaquin") == true
    end

    test "returns false" do
      assert Predicator.matches?("'name' starts with 'stuff'") == false
      assert Predicator.matches?("!'joaquin' starts with 'joa'") == false
      assert Predicator.matches?("name starts with 'stuff'", name: "joaquin") == false
      assert Predicator.matches?("!name starts with 'joa'", name: "joaquin") == false
      assert Predicator.matches?("name starts with 'joa'", name: nil) == false
    end
  end

  describe "ENDSWITH" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foobar], [:lit, "bar"], [:compare, :ENDSWITH]]} =
               Predicator.compile("foobar ends with 'bar'", :atom_key_inst)

      assert {:ok, [[:load, :foobar], [:lit, "bar"], [:compare, :ENDSWITH], [:not]]} =
               Predicator.compile("!foobar ends with 'bar'", :atom_key_inst)

      assert {:ok, [[:lit, "foobar"], [:lit, "bar"], [:compare, :ENDSWITH]]} =
               Predicator.compile("'foobar' ends with 'bar'", :atom_key_inst)

      assert {:ok, [[:lit, "foobar"], [:lit, "bar"], [:compare, :ENDSWITH], [:not]]} =
               Predicator.compile("!'foobar' ends with 'bar'", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["lit", "foobar"], ["lit", "bar"], ["compare", "ENDSWITH"]]} =
               Predicator.compile("'foobar' ends with 'bar'")

      assert {:ok, [["lit", "foobar"], ["lit", "bar"], ["compare", "ENDSWITH"], ["not"]]} =
               Predicator.compile("!'foobar' ends with 'bar'")

      assert {:ok, [["load", "foobar"], ["lit", "bar"], ["compare", "ENDSWITH"]]} =
               Predicator.compile("foobar ends with 'bar'")

      assert {:ok, [["load", "foobar"], ["lit", "bar"], ["compare", "ENDSWITH"], ["not"]]} =
               Predicator.compile("!foobar ends with 'bar'")
    end

    test "evaluates to true" do
      assert Predicator.matches?("'foobar' ends with 'bar'") == true
      assert Predicator.matches?("!'world' ends with 'bar'") == true
      assert Predicator.matches?("foobar ends with 'bar'", foobar: "foobar") == true
      assert Predicator.matches?("!foobar ends with 'bar'", foobar: "world") == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("'world' ends with 'bar'") == false
      assert Predicator.matches?("!'foobar' ends with 'bar'") == false
      assert Predicator.matches?("foobar ends with 'bar'", foobar: "world") == false
      assert Predicator.matches?("!foobar ends with 'bar'", foobar: "foobar") == false
      assert Predicator.matches?("foobar ends with 'bar'", foobar: nil) == false
    end
  end

  describe "EQ" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:lit, 1], [:compare, :EQ]]} =
               Predicator.compile("foo = 1", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:lit, "bar"], [:compare, :EQ], [:not]]} =
               Predicator.compile("!foo = \"bar\"", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["lit", 1], ["compare", "EQ"]]} =
               Predicator.compile("foo = 1")

      assert {:ok, [["load", "foo"], ["lit", "bar"], ["compare", "EQ"], ["not"]]} =
               Predicator.compile("!foo = \"bar\"")
    end

    test "returns true if the equality is true" do
      assert Predicator.matches?("1 = 1") == true
      assert Predicator.matches?("foo = 1", foo: 1) == true
      assert Predicator.matches?("!12 = 1") == true
      assert Predicator.matches?("!foo = 1", foo: 2) == true
    end

    test "returns false if the equality is untrue" do
      assert Predicator.matches?("12 = 1") == false
      assert Predicator.matches?("foo = 1", foo: 2) == false
      assert Predicator.matches?("!1 = 1") == false
      assert Predicator.matches?("!foo = 1", foo: 1) == false
      assert Predicator.matches?("foo = 1", foo: nil) == false
    end
  end

  describe "GT" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:lit, 1], [:compare, :GT]]} =
               Predicator.compile("foo > 1", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:lit, 1], [:compare, :GT], [:not]]} =
               Predicator.compile("!foo > 1", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["lit", 1], ["compare", "GT"]]} =
               Predicator.compile("foo > 1")

      assert {:ok, [["load", "foo"], ["lit", 1], ["compare", "GT"], ["not"]]} =
               Predicator.compile("!foo > 1")
    end

    test "returns true if the inequality is true" do
      assert Predicator.matches?("3 > 1") == true
      assert Predicator.matches?("foo > 1", foo: 2) == true
      assert Predicator.matches?("!0 > 1") == true
      assert Predicator.matches?("!foo > 1", foo: 0) == true
    end

    test "returns false if the inequality is untrue" do
      assert Predicator.matches?("0 > 1") == false
      assert Predicator.matches?("foo > 1", foo: 0) == false
      assert Predicator.matches?("foo > 1", foo: nil) == false
      assert Predicator.matches?("!3 > 1") == false
      assert Predicator.matches?("!foo > 1", foo: 2) == false
    end
  end

  describe "LT" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:lit, 1], [:compare, :LT]]} =
               Predicator.compile("foo < 1", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:lit, 1], [:compare, :LT], [:not]]} =
               Predicator.compile("!foo < 1", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["lit", 1], ["compare", "LT"]]} =
               Predicator.compile("foo < 1")

      assert {:ok, [["load", "foo"], ["lit", 1], ["compare", "LT"], ["not"]]} =
               Predicator.compile("!foo < 1")
    end

    test "returns true if the inequality is true" do
      assert Predicator.matches?("0 < 1") == true
      assert Predicator.matches?("!12 < 1") == true
      assert Predicator.matches?("foo < 1", foo: 0) == true
      assert Predicator.matches?("!foo < 1", foo: 1) == true
    end

    test "returns false if the inequality is untrue" do
      assert Predicator.matches?("!0 < 1") == false
      assert Predicator.matches?("12 < 1") == false
      assert Predicator.matches?("!foo < 1", foo: 0) == false
      assert Predicator.matches?("foo < 1", foo: 1) == false
      assert Predicator.matches?("foo < 1", foo: nil) == false
    end
  end

  describe "IN" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:array, [1, 5, 7, 20]], [:compare, :IN]]} =
               Predicator.compile("foo in [1, 5, 7, 20]", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:array, ["foo", "bar"]], [:compare, :IN]]} =
               Predicator.compile("foo in ['foo', 'bar']", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:array, ["foo", "bar"]], [:compare, :IN], [:not]]} =
               Predicator.compile("!foo in ['foo', 'bar']", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["array", [1, 5]], ["compare", "IN"]]} =
               Predicator.compile("foo in [1, 5]")

      assert {:ok, [["load", "foo"], ["array", ["foo", "bar"]], ["compare", "IN"]]} =
               Predicator.compile("foo in ['foo', 'bar']")

      assert {:ok, [["load", "foo"], ["array", ["foo", "bar"]], ["compare", "IN"], ["not"]]} =
               Predicator.compile("!foo in ['foo', 'bar']")
    end

    test "returns compilation error when trying to compare to string" do
      assert {:error, _error} = Predicator.compile("foo in 'foo'")
      assert {:error, _error} = Predicator.compile("foo in 1", :atom_key_inst)
    end

    test "evaluates to true" do
      assert Predicator.matches?("2 in [0, 1, 2, 3]") == true
      assert Predicator.matches?("!666 in [0, 1, 2, 3]") == true
      assert Predicator.matches?("foo in [0, 1, 2, 3]", foo: 0) == true
      assert Predicator.matches?("!foo in [0, 1, 2, 3]", foo: 666) == true
      assert Predicator.matches?("foo in ['foo', 'bar']", foo: "foo") == true
      assert Predicator.matches?("!foo in ['foo', 'bar']", foo: "foobar") == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("666 in [0, 1, 2, 3]") == false
      assert Predicator.matches?("!2 in [0, 1, 2, 3]") == false
      assert Predicator.matches?("foo in [0, 1, 2, 3]", foo: 666) == false
      assert Predicator.matches?("!foo in [0, 1, 2, 3]", foo: 0) == false
      assert Predicator.matches?("foo in ['foo', 'bar']", foo: "foobar") == false
      assert Predicator.matches?("!foo in ['foo', 'bar']", foo: "foo") == false
      assert Predicator.matches?("foo in ['foo', 'bar']", foo: nil) == false
    end
  end

  describe "NOTIN" do
    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:array, [1, 2, 3]], [:compare, :NOTIN]]} =
               Predicator.compile("foo not in [1, 2, 3]", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:array, ["foo", "bar"]], [:compare, :NOTIN]]} =
               Predicator.compile("foo not in ['foo', 'bar']", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:array, ["foo", "bar"]], [:compare, :NOTIN], [:not]]} =
               Predicator.compile("!foo not in ['foo', 'bar']", :atom_key_inst)
    end

    test "compiles" do
      assert {:ok, [["load", "foo"], ["array", [1, 2, 3]], ["compare", "NOTIN"]]} =
               Predicator.compile("foo not in [1, 2, 3]")

      assert {:ok, [["load", "foo"], ["array", ["foo", "bar"]], ["compare", "NOTIN"]]} =
               Predicator.compile("foo not in ['foo', 'bar']")

      assert {:ok, [["load", "foo"], ["array", ["foo", "bar"]], ["compare", "NOTIN"], ["not"]]} =
               Predicator.compile("!foo not in ['foo', 'bar']")
    end

    test "returns compilation error when trying to compare to string" do
      assert {:error, _error} = Predicator.compile("!foo in 'foo'")
      assert {:error, _error} = Predicator.compile("!foo in 1", :atom_key_inst)
    end

    test "evaluates to true" do
      assert Predicator.matches?("12 not in [1, 2, 3]") == true
      assert Predicator.matches?("!2 not in [1, 2, 3]") == true
      assert Predicator.matches?("foo not in [1, 2, 3]", foo: 0) == true
      assert Predicator.matches?("foo not in ['foo', 'bar']", foo: "foobar") == true
      assert Predicator.matches?("!foo not in ['foo', 'bar']", foo: "foo") == true
      assert Predicator.matches?("foo not in ['foo', 'bar']", foo: nil) == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("2 not in [1, 2, 3]") == false
      assert Predicator.matches?("!12 not in [1, 2, 3]") == false
      assert Predicator.matches?("foo not in [1, 2, 3]", foo: 2) == false
      assert Predicator.matches?("foo not in ['foo', 'bar']", foo: "foo") == false
      assert Predicator.matches?("!foo not in ['foo', 'bar']", foo: "foobar") == false
    end
  end

  describe "AND" do
    test "compiles atom key instructions" do
      assert {:ok,
              [
                [:load, :foo],
                [:lit, 90],
                [:compare, :GT],
                [:jfalse, 4],
                [:load, :foo],
                [:lit, 90],
                [:compare, :EQ]
              ]} = Predicator.compile("foo > 90 and foo = 90", :atom_key_inst)

      assert {:ok, [[:lit, true], [:jfalse, 2], [:lit, true], [:not]]} =
               Predicator.compile("!true and true", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok,
              [
                ["load", "a"],
                ["lit", 90],
                ["compare", "GT"],
                ["jfalse", 4],
                ["load", "a"],
                ["lit", 90],
                ["compare", "EQ"]
              ]} = Predicator.compile("a > 90 and a = 90")

      assert {:ok, [["lit", true], ["jfalse", 2], ["lit", true], ["not"]]} =
               Predicator.compile("!true and true")
    end

    test "evaluates to true" do
      assert Predicator.matches?("true and true") == true
      assert Predicator.matches?("!true and false") == true
      assert Predicator.matches?("foo and foo", foo: true) == true
      assert Predicator.matches?("!foo and foo", foo: false) == true
      assert Predicator.matches?("foo and foo and foo", foo: true) == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("true and false") == false
      assert Predicator.matches?("!true and true") == false
      assert Predicator.matches?("true and true and false") == false
      assert Predicator.matches?("foo and foo", foo: false) == false
      assert Predicator.matches?("!foo and foo", foo: true) == false
      assert Predicator.matches?("foo and foo and bar", foo: true, bar: false) == false
    end
  end

  describe "OR" do
    test "compiles atom key instructions" do
      assert {:ok,
              [
                [:load, :foo],
                [:lit, 90],
                [:compare, :GT],
                [:jtrue, 4],
                [:load, :foo],
                [:lit, 90],
                [:compare, :EQ]
              ]} = Predicator.compile("foo > 90 or foo = 90", :atom_key_inst)

      assert {:ok, [[:lit, true], [:jtrue, 2], [:lit, false], [:not]]} =
               Predicator.compile("!true or false", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok,
              [
                ["load", "foo"],
                ["lit", 90],
                ["compare", "GT"],
                ["jtrue", 4],
                ["load", "foo"],
                ["lit", 90],
                ["compare", "EQ"]
              ]} = Predicator.compile("foo > 90 or foo = 90")

      assert {:ok, [["lit", true], ["jtrue", 2], ["lit", false], ["not"]]} =
               Predicator.compile("!true or false")
    end

    test "evaluates to true" do
      assert Predicator.matches?("true or true") == true
      assert Predicator.matches?("!false or false") == true
      assert Predicator.matches?("false or true") == true
      assert Predicator.matches?("true or false") == true
      assert Predicator.matches?("false or true or false") == true
      assert Predicator.matches?("foo or bar", foo: true, bar: false) == true
      assert Predicator.matches?("!foo or foo", foo: false) == true
    end

    test "evaluates to false" do
      assert Predicator.matches?("false or false") == false
      assert Predicator.matches?("!true or true") == false
      assert Predicator.matches?("foo or foo", foo: false) == false
      assert Predicator.matches?("foo or bar or foo", foo: false, bar: false) == false
      assert Predicator.matches?("!foo or bar", foo: true, bar: false) == false
    end
  end

  describe "JUMP" do
  end

  describe "PRESENT" do
    setup do
      %{eval_opts: [map_type: :atom, nil_values: [nil, ""]]}
    end

    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:present]]} =
               Predicator.compile("foo is present", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:present], [:not]]} =
               Predicator.compile("!foo is present", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["present"]]} = Predicator.compile("foo is present")

      assert {:ok, [["load", "foo"], ["present"], ["not"]]} =
               Predicator.compile("!foo is present")
    end

    test "evaluates to true", %{eval_opts: eval_opts} do
      assert Predicator.matches?("'foo' is present", [], eval_opts) == true
      assert Predicator.matches?("!'' is present", [], eval_opts) == true
      assert Predicator.matches?("foo is present", [foo: "bar"], eval_opts) == true
      assert Predicator.matches?("!foo is present", [foo: ""], eval_opts) == true
    end

    test "evaluates to false", %{eval_opts: eval_opts} do
      assert Predicator.matches?("'' is present", [], eval_opts) == false
      assert Predicator.matches?("!'foo' is present", [], eval_opts) == false
      assert Predicator.matches?("foo is present", [foo: ""], eval_opts) == false
      assert Predicator.matches?("!foo is present", [foo: "bar"], eval_opts) == false
      assert Predicator.matches?("foo is present", [foo: nil], eval_opts) == false
    end
  end

  describe "BLANK" do
    setup do
      %{eval_opts: [map_type: :atom, nil_values: [nil, ""]]}
    end

    test "compiles atom key instructions" do
      assert {:ok, [[:load, :foo], [:blank]]} = Predicator.compile("foo is blank", :atom_key_inst)

      assert {:ok, [[:load, :foo], [:blank], [:not]]} =
               Predicator.compile("!foo is blank", :atom_key_inst)
    end

    test "compiles string key instructions" do
      assert {:ok, [["load", "foo"], ["blank"]]} = Predicator.compile("foo is blank")
      assert {:ok, [["load", "foo"], ["blank"], ["not"]]} = Predicator.compile("!foo is blank")
    end

    test "evaluates to true", %{eval_opts: eval_opts} do
      assert Predicator.matches?("'' is blank", [], eval_opts) == true
      assert Predicator.matches?("!'foo' is blank", [], eval_opts) == true
      assert Predicator.matches?("foo is blank", [foo: ""], eval_opts) == true
      assert Predicator.matches?("!foo is blank", [foo: "bar"], eval_opts) == true
      assert Predicator.matches?("foo is blank", [foo: nil], eval_opts) == true
    end

    test "evaluates to false", %{eval_opts: eval_opts} do
      assert Predicator.matches?("'foo' is blank", [], eval_opts) == false
      assert Predicator.matches?("!'' is blank", [], eval_opts) == false
      assert Predicator.matches?("foo is blank", [foo: "bar"], eval_opts) == false
      assert Predicator.matches?("!foo is blank", [foo: ""], eval_opts) == false
    end
  end
end
