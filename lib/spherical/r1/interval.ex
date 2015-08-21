defmodule Spherical.R1.Interval do
  @moduledoc ~S"""
  Represents a closed interval on ℝ¹.
  """
  defstruct lo: 1.0, hi: 0.0    # Return an empty interval by default

  alias __MODULE__
  import Kernel, except: [length: 1]

  @type t :: %Interval{lo: number, hi: number}

  # API

  @doc "Returns an empty interval."
  def new do
    %__MODULE__{lo: 1.0, hi: 0.0}
  end

  @doc "Returns an interval representing a single `point`."
  def new(point) when is_number(point) do
    %__MODULE__{lo: point, hi: point}
  end

  @doc "Returns an interval between `a` and `b`."
  def new(a, b) when is_number(a) and is_number(b) do
    %__MODULE__{lo: a, hi: b}
  end

  # epsilon represents a reasonable level of noise between two values
  # that can be considered to be equal.
  @epsilon 1.0e-14

  # API

  @doc "Checks whether the `interval` is empty."
  def is_empty?(%Interval{lo: lo, hi: hi}), do: lo > hi
  def is_empty?(_interval),                 do: false

  @doc "Checks if the intervals contains the same points."
  def is_equal?(%Interval{lo: lo, hi: hi}, %Interval{lo: lo, hi: hi}), do: true
  def is_equal?(%Interval{}=first, %Interval{}=second) do
    is_empty?(first) && is_empty?(second)
  end
  def is_equal?(_first, _second), do: false

  @doc "Returns the midpoint of the `interval`."
  def center(%Interval{lo: lo, hi: hi}), do: 0.5 * (lo + hi)

  @doc """
  Returns the length of the `interval`.

  The length of an empty interval is negative.
  """
  def length(%Interval{lo: lo, hi: hi}), do: hi - lo

  @doc "Checks if the interval contains `point`."
  def contains?(%Interval{}=first, %Interval{}=second) do
    case is_empty? second do
      true  -> true
      false -> first.lo <= second.lo && second.hi <= first.hi
    end
  end
  def contains?(%Interval{lo: lo, hi: hi}, point) when is_number(point) do
    lo <= point && point <= hi
  end


  @doc "Checks if the `interval` strictly contains `point`."
  def interior_contains?(%Interval{lo: lo, hi: hi}, point) when is_number(point) do
    lo < point && point < hi
  end
  def interior_contains?(%Interval{}=first, %Interval{}=second) do
    case is_empty? second do
      true -> true
      false -> first.lo < second.lo && second.hi < first.hi
    end
  end

  @doc "Check if `first` contains any points in common with `second`."
  def intersects?(%Interval{}=first, %Interval{}=second) do
    if first.lo <= second.lo do
      second.lo <= first.hi && second.lo <= second.hi
    else
      first.lo <= second.hi && first.lo <= first.hi
    end
  end

  @doc """
  Check if the interior of the `first` contains any points in common
  with `second`, including the latter's boundary.
  """
  def interior_intersects?(%Interval{}=first, %Interval{}=second) do
    second.lo    <  first.hi
    && first.lo  <  second.hi
    && first.lo  <  first.hi
    && second.lo <= first.hi
  end

  @doc """
  Returns the interval containing **all** points common to `first` and
  `second`.
  """
  def intersection(%Interval{}=first, %Interval{}=second) do
    Interval.new(max(first.lo, second.lo),
                 min(first.hi, second.hi))
  end

  @doc "Returns a copy of `interval` containing the given `point`."
  def add_point(%Interval{}=interval, point) when is_number(point) do
    cond do
      is_empty? interval  -> Interval.new(point, point)
      point < interval.lo -> Interval.new(point, interval.hi)
      point > interval.hi -> Interval.new(interval.lo, point)
      true -> interval
    end
  end

  @doc """
  Returns the closest point in the `interval` to the given `point`.

  The interval must be non-empty.
  """
  def clamp_point(%Interval{}=interval, point) when is_number(point) do
    max(interval.lo, min(interval.hi, point))
  end

  @doc """
  Returns an `interval` that has been expanded on each side by
  `margin`.

  If `margin` is negative, then the function shrinks the `interval` on
  each side by margin instead. The resulting interval may be empty.

  Any expansion of an empty interval remains empty.
  """
  def expanded(%Interval{lo: lo, hi: hi}=interval, margin) when is_number(margin) do
    case is_empty? interval do
      true  -> interval
      false -> Interval.new(lo - margin, hi + margin)
    end
  end

  @doc """
  Returns the smallest interval that contains the `first` and `second`
  intervals.
  """
  def union(%Interval{}=first, %Interval{}=second) do
    cond do
      is_empty? first  -> second
      is_empty? second -> first
      true ->
        Interval.new(min(first.lo, second.lo),
                     max(first.hi, second.hi))
    end
  end

  @doc """
  Reports whether the `first` interval can be transformed into the
  `second` interval by moving each endpoint a small distance.

  The empty interval is considered to be positioned arbitrarily on the
  real line, so any interval with a small enough length will match the
  empty interval.
  """
  def approx_equal(%Interval{}=first, %Interval{}=second) do
    cond do
      is_empty? first  -> length(second) <= 2 * @epsilon
      is_empty? second -> length(first)  <= 2 * @epsilon
      true ->
        abs(second.lo - first.lo) <= @epsilon &&
        abs(second.hi - first.hi) <= @epsilon
    end
  end

end
