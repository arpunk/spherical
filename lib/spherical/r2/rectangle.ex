defmodule Spherical.R2.Rectangle do
  @moduledoc ~S"""
  Represents a closed axis-aligned rectangle in ℝ².

  Describes every point in two-dimensional space by means of two
  coordinates.
  """
  alias __MODULE__
  alias Spherical.R1.Interval
  alias Spherical.R2.Point

  defstruct x: %Interval{}, y: %Interval{}

  @type t :: %Rectangle{x: Interval.t, y: Interval.t}

  # API

  @doc "Returns an empty rectangle."
  def new do
    %Rectangle{}
  end

  @doc "Returns a rectangle with the given intervals."
  def new(%Interval{}=x, %Interval{}=y) do
    %Rectangle{x: x, y: y}
  end

  @doc "Returns a rectangle that contains the given `points`."
  def from_points([%Point{}=first|others]) do
    rectangle = %Rectangle{x: %Interval{lo: first.x, hi: first.x},
                           y: %Interval{lo: first.y, hi: first.y}}

    others
    |> Enum.reduce rectangle, fn(point, r) -> add_point(r, point) end
  end

  @doc """
  Returns a rectangle with the given `center` and `size`.

  Both dimensions of size **must** be non-negative.
  """
  def from_center(%Point{}=center, %Point{}=size) do
    new(Interval.new(center.x - size.x / 2, center.x + size.x / 2),
        Interval.new(center.y - size.y / 2, center.y + size.y / 2))
  end

  @doc "Checks whether the `rectangle` is empty."
  def is_empty?(%Rectangle{}=rectangle) do
    Interval.is_empty?(rectangle.x)
  end

  @doc """
  Checks whether the `rectangle` is valid.

  This requires the width to be empty if the height is empty.
  """
  def is_valid?(%Rectangle{}=rectangle) do
    Interval.is_empty?(rectangle.x) == Interval.is_empty?(rectangle.y)
  end

  @doc "Returns the center of the `rectangle` in ℝ²"
  def center(%Rectangle{x: x, y: y}) do
    Point.new(Interval.center(x), Interval.center(y))
  end

  @doc """
  Returns all four vertices of the `rectangle`.

  Vertices are returned in CCW direction starting with the lower left
  corner.
  """
  def vertices(%Rectangle{x: x, y: y}) do
    [Point.new(x.lo, y.lo),
     Point.new(x.hi, y.lo),
     Point.new(x.hi, y.hi),
     Point.new(x.lo, y.hi)]
  end

  @doc """
  Returns the width and height of this `rectangle` in (x,y)-space.

  Empty rectangles have a negative width and height.
  """
  def size(%Rectangle{x: x, y: y}) do
    Point.new(Interval.length(x), Interval.length(y))
  end

  @doc """
  Checks whether the `rectangle` contains the given `point`.

  Rectangles are closed regions, i.e. they contain their boundary.
  """
  def contains_point?(%Rectangle{}=rectangle, %Point{}=point) do
    Interval.contains?(rectangle.x, point.x) &&
    Interval.contains?(rectangle.y, point.y)
  end

  @doc """
  Returns true if the given `point` is contained in the interior of the
  `rectangle` (i.e. the region excluding its boundary).
  """
  def interior_contains_point?(%Rectangle{}=rectangle, %Point{}=point) do
    Interval.interior_contains?(rectangle.x, point.x) &&
    Interval.interior_contains?(rectangle.y, point.y)
  end

  @doc "Checks whether the `first` rectangle contains the `second`."
  def contains?(%Rectangle{}=first, %Rectangle{}=second) do
    Interval.contains?(first.x, second.x) &&
    Interval.contains?(first.y, second.y)
  end

  @doc """
  Checks whether the interior of the `first` rectangle contains all of
  the points of the `second` (including its boundary).
  """
  def interior_contains?(%Rectangle{}=first, %Rectangle{}=second) do
    Interval.interior_contains?(first.x, second.x) &&
    Interval.interior_contains?(first.y, second.y)
  end

  @doc """
  Checks whether the `first` rectangle and the `second` have any
  points in common.
  """
  def intersects?(%Rectangle{}=first, %Rectangle{}=second) do
    Interval.intersects?(first.x, second.x) &&
    Interval.intersects?(first.y, second.y)
  end

  @doc """
  Checks whether the interior of the `first` rectangle intersects any
  point (including the boundary) of the `second`.
  """
  def interior_intersects?(%Rectangle{}=first, %Rectangle{}=second) do
    Interval.interior_intersects?(first.x, second.x) &&
    Interval.interior_intersects?(first.y, second.y)
  end

  @doc """
  Expands the `rectangle` to include the given `point`.

  The rectangle is expanded by the minimum amount possible.
  """
  def add_point(%Rectangle{}=rectangle, %Point{}=point) do
    # TODO: Is this an R2 function instead?
    %{rectangle| x: Interval.add_point(rectangle.x, point.x),
                 y: Interval.add_point(rectangle.y, point.y)}
  end

  @doc """
  Expands the `first` rectangle to include the `second`.

  This is the same as replacing the one rectangle by the union of the
  two rectangles, but is more efficient.
  """
  def add_rectangle(%Rectangle{}=first, %Rectangle{}=second) do
    union(first, second)
  end

  @doc """
  Returns the closest point in the `rectangle` to the given `point`.

  The `rectangle` must be non-empty.
  """
  def clamp_point(%Rectangle{}=rectangle, %Point{}=point) do
    Point.new(Interval.clamp_point(rectangle.x, point.x),
              Interval.clamp_point(rectangle.y, point.y))
  end

  @doc """
  Returns a `rectangle` that has been expanded in the x-direction by
  `margin.x` and in y-direction by `margin.y`.

  If either `margin` is empty, then shrink the interval on the
  corresponding sides instead. The resulting rectangle may be
  empty. Any expansion of an empty rectangle remains empty.
  """
  def expanded(%Rectangle{}=rectangle, %Point{}=margin) do
    x = Interval.expanded(rectangle.x, margin.x)
    y = Interval.expanded(rectangle.y, margin.y)

    if Interval.is_empty?(x) || Interval.is_empty?(y) do
      Rectangle.new
    else
      %{rectangle| x: x, y: y}
    end
  end

  @doc """
  Returns a `rectangle` that has been expanded by the amount on all
  sides by `margin`.
  """
  def expanded_by_margin(%Rectangle{}=rectangle, margin) when is_number(margin) do
    expanded(rectangle, Point.new(margin))
  end

  @doc """
  Returns the smallest rectangle containing the union of the `first`
  and `second` rectangles.
  """
  def union(%Rectangle{}=first, %Rectangle{}=second) do
    Rectangle.new(Interval.union(first.x, second.x),
                  Interval.union(first.y, second.y))
  end

  @doc """
  Returns the smallest rectangle containing the intersection of the
  `first` and `second` rectangles.
  """
  def intersection(%Rectangle{}=first, %Rectangle{}=second) do
    x = Interval.intersection(first.x, second.x)
    y = Interval.intersection(first.y, second.y)

    if Interval.is_empty?(x) || Interval.is_empty?(y) do
      Rectangle.new
    else
      Rectangle.new(x, y)
    end
  end

  @doc """
  Returns true if the x- and y-intervals of the two rectangles are the
  same up to the given tolerance.
  """
  def approx_equals(%Rectangle{}=first, %Rectangle{}=second) do
    Interval.approx_equal(first.x, second.x) &&
    Interval.approx_equal(first.y, second.y)
  end

end
