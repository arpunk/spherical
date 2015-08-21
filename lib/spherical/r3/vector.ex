defmodule Spherical.R3.Vector do
  @moduledoc ~S"""
  Represents a point in ℝ³.
  """
  alias __MODULE__
  alias :math, as: Math

  import Kernel, except: [abs: 1]

  defstruct x: 0, y: 0, z: 0

  @type t :: %__MODULE__{x: number, y: number, z: number}

  @epsilon    1.0e-14
  @deg_to_rad 180.0 * Math.pi

  # API

  @doc "Returns an empty vector."
  def new do
    %Vector{}
  end

  @doc "Returns a vector with the given coordinates."
  def new(x, y, z) when is_number(x) and is_number(y) and is_number(z) do
    %Vector{x: x, y: y, z: z}
  end

  @doc "Returns the `vector` with non-negative components."
  def abs(%Vector{}=vector) do
    %Vector{x: Kernel.abs(vector.x),
            y: Kernel.abs(vector.y),
            z: Kernel.abs(vector.z)}
  end

  @doc "Returns the standard vector sum of `first` and `second`."
  def add(%Vector{}=first, %Vector{}=second) do
    %Vector{x: first.x + second.x,
            y: first.y + second.y,
            z: first.z + second.z}
  end

  @doc "Returns the standard vector difference of `first` and `second`."
  def sub(%Vector{}=first, %Vector{}=second) do
    %Vector{x: first.x - second.x,
            y: first.y - second.y,
            z: first.z - second.z}
  end

  @doc "Returns the standard scalar product of `vector` and `m`."
  def mul(%Vector{}=vector, m) when is_number(m) do
    %Vector{x: m * vector.x,
            y: m * vector.y,
            z: m * vector.z}
  end

  @doc "Returns the standard dot product of `first` and `second`."
  def dot(%Vector{}=first, %Vector{}=second) do
    (first.x * second.x) + (first.y * second.y) + (first.z * second.z)
  end

  @doc "Returns the standard cross product of `first` and `second`."
  def cross(%Vector{}=first, %Vector{}=second) do
    %Vector{x: first.y * second.z - first.z * second.y,
            y: first.z * second.x - first.x * second.z,
            z: first.x * second.y - first.y * second.x}
  end

  @doc "Returns the vector's norm."
  def norm(%Vector{}=vector) do
    dot(vector, vector) |> Math.sqrt
  end

  @doc "Returns the square of the vector's norm."
  def square_norm(%Vector{}=vector) do
    dot(vector, vector)
  end

  @doc "Returns a unit vector in the same direction as `vector`."
  def normalize(%Vector{x: 0, y: 0, z: 0}=vector) do
    vector
  end
  def normalize(%Vector{}=vector) do
    mul(vector, 1 / norm(vector))
  end

  @doc "Checks whether `vector` is of approximately unit length."
  def is_unit?(%Vector{}=vector) do
    epsilon = 5.0e-14 # New epsilon
    Kernel.abs(square_norm(vector) - 1) <= epsilon
  end

  @doc "Returns the Euclidean distance between `first` and `second`."
  def distance(%Vector{}=first, %Vector{}=second) do
    sub(first, second) |> norm()
  end

  @doc "Returns the angle between `first` and `second`."
  def angle(%Vector{}=_first, %Vector{}=_second) do
    # TODO: Implement S1
  end

  @doc """
  Returns a unit vector that is orthogonal to `vector`.

  `Ortho(-vector) = -Ortho(vector)` for all `vector`.
  """
  def orthogonal(%Vector{}=vector) do
    ov      = %Vector{x: 0.012, y: 0.0053, z: 0.00457}
    bigger? = Kernel.abs(vector.x) > Kernel.abs(vector.y)

    ortho =
      if bigger? do
        %{ov | y: 1}
      else
        %{ov | x: 1}
      end

    cross(vector, ortho) |> normalize()
  end

  @doc """
  Checks whether `first` and `second` are equal within a small
  epsilon.
  """
  def approx_equal(%Vector{}=first, %Vector{}=second) do
    Kernel.abs(first.x - second.x) < @epsilon &&
    Kernel.abs(first.y - second.y) < @epsilon &&
    Kernel.abs(first.z - second.z) < @epsilon
  end

end
