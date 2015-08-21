defmodule Spherical.R1.Test do
  use ExUnit.Case, async: true

  alias Spherical.R1.Interval

  @epsilon 1.0e-14

  @empty    Interval.new
  @unit     Interval.new(0, 1)
  @negative Interval.new(-1, 0)
  @half     Interval.new(0.5)

  @centers  [{@unit, 0.5}, {@negative, -0.5}, {@half, 0.5}]
  @lengths  [{@unit, 1},   {@negative, 1},    {@half, 0}]

  @intersections [{@unit, @half, @half},
		              {@unit, @negative, Interval.new(0)},
		              {@negative, @half, @empty},
		              {@unit, @empty, @empty},
		              {@empty, @unit, @empty}]

  @unions [{Interval.new(99, 100), @empty, Interval.new(99, 100)},
           {@empty, Interval.new(99, 100), Interval.new(99, 100)},
           {Interval.new(5, 3), Interval.new(0, -2), @empty},
           {Interval.new(0, -2), Interval.new(5, 3), @empty},
           {@unit, @unit, @unit},
           {@unit, @negative, Interval.new(-1, 1)},
           {@negative, @unit, Interval.new(-1, 1)},
           {@half, @unit, @unit}]

  @points [{@empty, 5, Interval.new(5, 5)},
		       {Interval.new(5, 5), -1, Interval.new(-1, 5)},
		       {Interval.new(-1, 5), 0, Interval.new(-1, 5)},
		       {Interval.new(-1, 5), 6, Interval.new(-1, 6)}]

  @clamp_points [{Interval.new(0.1, 0.4), 0.3, 0.3},
		             {Interval.new(0.1, 0.4), -7.0, 0.1},
		             {Interval.new(0.1, 0.4), 0.6, 0.4}]

  @expanded [{@empty, 0.45, @empty},
		         {@unit, 0.5, Interval.new(-0.5, 1.5)},
		         {@unit, -0.5, Interval.new(0.5, 0.5)},
		         {@unit, -0.51, @empty}]

  @intervals [{@empty, @empty, true},
		          {Interval.new(0), @empty, true},
		          {@empty, Interval.new(0), true},
		          {Interval.new(1), @empty, true},
		          {@empty, Interval.new(1), true},
		          {@empty, Interval.new(0, 1), false},
		          {@empty, Interval.new(1, 1 + 2 * @epsilon), true},

		          {Interval.new(1), Interval.new(1), true},
		          {Interval.new(1), Interval.new(1 - @epsilon, 1 - @epsilon), true},
		          {Interval.new(1), Interval.new(1 + @epsilon, 1 + @epsilon), true},
		          {Interval.new(1), Interval.new(1 - 3 * @epsilon, 1), false},
		          {Interval.new(1), Interval.new(1, 1 + 3 * @epsilon), false},
		          {Interval.new(1), Interval.new(1 - @epsilon, 1 + @epsilon), true},
		          {Interval.new(0), Interval.new(1), false},

		          {Interval.new(1 - @epsilon, 2 + @epsilon), Interval.new(1, 2), false},
		          {Interval.new(1 + @epsilon, 2 - @epsilon), Interval.new(1, 2), true},
		          {Interval.new(1 - 3 * @epsilon, 2 + @epsilon), Interval.new(1, 2), false},
		          {Interval.new(1 + 3 * @epsilon, 2 - @epsilon), Interval.new(1, 2), false},
		          {Interval.new(1 - @epsilon, 2 + 3 * @epsilon), Interval.new(1, 2), false},
		          {Interval.new(1 + @epsilon, 2 - 3 * @epsilon), Interval.new(1, 2), false}]

  test "Computes interval center" do
    for {interval, center} <- @centers do
      assert center == Interval.center(interval)
    end
  end

  test "Interval lengths" do
    for {interval, wanted_length} <- @lengths do
      assert wanted_length == Interval.length(interval)
    end

    if Interval.length(%Interval{}) >= 0 do
      raise "empty interval has non-negative length"
    end
  end

  test "Interval intersections" do
    for {first, second, wanted_result} <- @intersections do
      intersection = Interval.intersection(first, second)
      assert Interval.is_equal?(intersection, wanted_result)
    end
  end

  test "Interval unions" do
    for {first, second, wanted_result} <- @unions do
      union = Interval.union(first, second)
      assert Interval.is_equal?(union, wanted_result)
    end
  end

  test "Adding points to intervals" do
    for {interval, point, wanted_result} <- @points do
      result = Interval.add_point(interval, point)
      assert Interval.is_equal?(result, wanted_result)
    end
  end

  test "Interval clamp points" do
    for {interval, margin, wanted_result} <- @clamp_points do
      clamp_point = Interval.clamp_point(interval, margin)
      assert wanted_result == clamp_point
    end
  end

  test "Expanded intervals" do
    for {interval, margin, wanted_result} <- @expanded do
      expanded_interval = Interval.expanded(interval, margin)
      assert Interval.is_equal?(expanded_interval, wanted_result)
    end
  end

  test "Interval approx equals" do
    for {interval, other, wanted_result} <- @intervals do
      assert wanted_result == Interval.approx_equal(interval, other)
    end
  end

end
