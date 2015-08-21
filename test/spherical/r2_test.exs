defmodule Spherical.R2.Test do
  use ExUnit.Case, async: true

  alias Spherical.R1.Interval
  alias Spherical.R2.Point
  alias Spherical.R2.Rectangle

  @sw Point.new(0, 0.25)
  @se Point.new(0.5, 0.25)
  @ne Point.new(0.5, 0.75)
  @nw Point.new(0, 0.75)

  @empty Rectangle.new

  @rectangle Rectangle.from_points([@sw, @ne])
  @rect_mid  Rectangle.from_points([Point.new(0.25, 0.5), Point.new(0.25, 0.5)])
  @rect_sw   Rectangle.from_points([@sw, @sw])
  @rect_ne   Rectangle.from_points([@ne, @ne])

  test "Valid rectangles" do
    assert Rectangle.is_valid?(Rectangle.new)
    assert Rectangle.is_empty?(Rectangle.new)
  end

  test "Approx equals" do
    d1 = Rectangle.from_points([Point.new(0.1, 0), Point.new(0.25, 1)])
    tests =
      [{Rectangle.from_center(Point.new(0.3, 0.5), Point.new(0.2, 0.4)),
        Rectangle.from_points([Point.new(0.2, 0.3), Point.new(0.4, 0.7)])},
       {Rectangle.from_center(Point.new(0.3, 0.5), Point.new(0.2, 0.4)),
        Rectangle.from_points([Point.new(0.2, 0.3), Point.new(0.4, 0.7)])},
       {d1,
        Rectangle.new(d1.x, d1.y)},
       {Rectangle.from_points([Point.new(0.15, 0.3), Point.new(0.35, 0.9)]),
        Rectangle.from_points([Point.new(0.15, 0.9), Point.new(0.35, 0.3)])},
       {Rectangle.from_points([Point.new(0.12, 0), Point.new(0.83, 0.5)]),
        Rectangle.from_points([Point.new(0.83, 0), Point.new(0.12, 0.5)])
       }]

    for {r1, r2} <- tests do
      assert Rectangle.approx_equals(r1, r2)
    end
  end

  test "Rectangle centers" do
    centers = [{@empty, Point.new(0.5, 0.5)},
               {@rectangle, Point.new(0.25, 0.5)}]
    for {rectangle, wanted_result} <- centers do
      assert ^wanted_result = Rectangle.center(rectangle)
    end
  end

  test "Rectangle vertices" do
    assert [@sw, @se, @ne, @nw] == Rectangle.vertices(@rectangle)
  end

  test "Rectangle contains point" do
    tests = [
      {@rectangle, Point.new(0.2, 0.4), true},
      {@rectangle, Point.new(0.2, 0.8), false},
      {@rectangle, Point.new(-0.1, 0.4), false},
      {@rectangle, Point.new(0.6, 0.1), false},
      {@rectangle, Point.new(@rectangle.x.lo, @rectangle.y.lo), true},
      {@rectangle, Point.new(@rectangle.x.hi, @rectangle.y.hi), true}
    ]

    for {rectangle, point, result} <- tests do
      assert result == Rectangle.contains_point?(rectangle, point)
    end
  end

  test "Interior rectangle contains point" do
    tests = [
      {@rectangle, @sw, false},
		  {@rectangle, @ne, false},

		  # Check a point on the border is not contained.
		  {@rectangle, Point.new(0, 0.5), false},
		  {@rectangle, Point.new(0.25), false},
		  {@rectangle, Point.new(0.5), false},

		  # Check points inside are contained.
		  {@rectangle, Point.new(0.125, 0.6), true}
    ]

    for {rectangle, point, expected} <- tests do
      assert expected == Rectangle.interior_contains_point?(rectangle, point)
    end
  end

  test "Interval operations" do
    tests = [
      {@rectangle, @rect_mid, true, true, true, true, @rectangle, @rect_mid},
      {@rectangle, @rect_sw, true, false, true, false, @rectangle, @rect_sw},
      {@rectangle, @rect_ne, true, false, true, false, @rectangle, @rect_ne},

      {@rectangle,
       Rectangle.from_points([Point.new(0.45, 0.1), Point.new(0.75, 0.3)]),
       false, false, true, true,
       Rectangle.from_points([Point.new(0, 0.1), Point.new(0.75)]),
       Rectangle.from_points([Point.new(0.45, 0.25), Point.new(0.5, 0.3)])},

      {@rectangle,
       Rectangle.from_points([Point.new(0.5, 0.1), Point.new(0.7, 0.3)]),
       false, false, true, false,
       Rectangle.from_points([Point.new(0, 0.1), Point.new(0.7, 0.75)]),
       Rectangle.from_points([Point.new(0.5, 0.25), Point.new(0.5, 0.3)])},

      {@rectangle,
       Rectangle.from_points([Point.new(0.45, 0.1), Point.new(0.7, 0.25)]),
       false, false, true, false,
       Rectangle.from_points([Point.new(0, 0.1), Point.new(0.7, 0.75)]),
       Rectangle.from_points([Point.new(0.45, 0.25), Point.new(0.5, 0.25)])},

      {Rectangle.from_points([Point.new(0.1, 0.2), Point.new(0.1, 0.3)]),
       Rectangle.from_points([Point.new(0.15, 0.7), Point.new(0.2, 0.8)]),
       false, false, false, false,
       Rectangle.from_points([Point.new(0.1, 0.2), Point.new(0.2, 0.8)]),
       Rectangle.new},

      # Check that the intersection of two rectangles that
      # overlap in x but not y is valid, and vice versa.
      {Rectangle.from_points([Point.new(0.1, 0.2), Point.new(0.4, 0.5)]),
       Rectangle.from_points([Point.new(0), Point.new(0.2, 0.1)]),
       false, false, false, false,
       Rectangle.from_points([Point.new(0), Point.new(0.4, 0.5)]),
       Rectangle.new},

      {Rectangle.from_points([Point.new(0), Point.new(0.1, 0.3)]),
       Rectangle.from_points([Point.new(0.2, 0.1), Point.new(0.3, 0.4)]),
       false, false, false, false,
       Rectangle.from_points([Point.new(0), Point.new(0.3, 0.4)]),
       Rectangle.new}]

    for {r1, r2, contains, int_contains, intersects, int_intersects, want_union, want_intersection} <- tests do
      t_contains     = Rectangle.contains?(r1, r2)
      t_intersects   = Rectangle.intersects?(r1, r2)
      t_rect         = Rectangle.add_rectangle(r1, r2)
      contains_res   = Rectangle.union(r1, r2) |> Rectangle.approx_equals(r1)
      intersects_res = Rectangle.intersection(r1, r2) |> Rectangle.is_empty?

      assert contains          == Rectangle.contains?(r1, r2)
      assert int_contains      == Rectangle.interior_contains?(r1, r2)
      assert intersects        == Rectangle.intersects?(r1, r2)
      assert int_intersects    == Rectangle.interior_intersects?(r1, r2)
      assert contains_res      == t_contains
      refute intersects_res    == t_intersects
      assert want_union        == Rectangle.union(r1, r2)
      assert want_intersection == Rectangle.intersection(r1, r2)
      assert want_union        == t_rect
    end
  end

  test "Add point to rectangle" do
    rectangle =
      Rectangle.new
      |> Rectangle.add_point(@sw)
      |> Rectangle.add_point(@se)
      |> Rectangle.add_point(@nw)
      |> Rectangle.add_point(Point.new(0.1, 0.4))

    assert Rectangle.approx_equals(@rectangle, rectangle)
  end

  test "Rectangle clamp points" do
    rectangle = Rectangle.new(Interval.new(0, 0.5),
                              Interval.new(0.25, 0.75))

    tests = [
      {Point.new(-0.01, 0.24), Point.new(0, 0.25)},
      {Point.new(-5.0, 0.48), Point.new(0, 0.48)},
      {Point.new(-5.0, 2.48), Point.new(0, 0.75)},
      {Point.new(0.19, 2.48), Point.new(0.19, 0.75)},

      {Point.new(6.19, 2.48), Point.new(0.5, 0.75)},
      {Point.new(6.19, 0.53), Point.new(0.5, 0.53)},
      {Point.new(6.19, -2.53), Point.new(0.5, 0.25)},
      {Point.new(0.33, -2.53), Point.new(0.33, 0.25)},
      {Point.new(0.33, 0.37), Point.new(0.33, 0.37)}
    ]

    for {point, wanted_result} <- tests do
      assert wanted_result == Rectangle.clamp_point(rectangle, point)
    end
  end

  test "Expanded empty rectangle" do
    rectangle = Rectangle.from_points([Point.new(0.2, 0.4),
                                       Point.new(0.3, 0.7)])
    tests = [
      {@empty, Point.new(0.1, 0.3)},
      {@empty, Point.new(-0.1, -0.3)},
      {rectangle, Point.new(-0.1, 0.3)},
      {rectangle, Point.new(0.1, -0.2)}
    ]

    for {rectangle, point} <- tests do
      assert Rectangle.expanded(rectangle, point) |> Rectangle.is_empty?
    end
  end

  test "Expanded equals" do
    rectangle = Rectangle.from_points([Point.new(0.2, 0.4),
                                       Point.new(0.3, 0.7)])
    tests = [
      {rectangle, Point.new(0.1, 0.3), Rectangle.from_points([Point.new(0.1),
                                                              Point.new(0.4, 1.0)])},
      {rectangle, Point.new(0.1, -0.1), Rectangle.from_points([Point.new(0.1, 0.5),
                                                               Point.new(0.4, 0.6)])},
      {rectangle, Point.new(0.1), Rectangle.from_points([Point.new(0.1, 0.3),
                                                         Point.new(0.4, 0.8)])}
    ]

    for {rectangle, point, wanted_result} <- tests do
      assert Rectangle.expanded(rectangle, point) |> Rectangle.approx_equals(wanted_result)
    end
  end

end
