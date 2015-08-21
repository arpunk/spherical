defmodule Spherical.R2.Point do
  @moduledoc ~S"""
  Represents a point in ℝ².
  """
  defstruct x: 0, y: 0

  @type t :: %__MODULE__{x: number, y: number}

  @doc "Returns a point."
  def new(x) when is_number(x) do
    %__MODULE__{x: x, y: x}
  end

  @doc "Returns a point from `a` to `b`."
  def new(x, y) when is_number(x) and is_number(y) do
    %__MODULE__{x: x, y: y}
  end
end
