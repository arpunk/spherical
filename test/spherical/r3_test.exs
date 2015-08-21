defmodule Spherical.R3.Test do
  use ExUnit.Case

  @epsilon 1.0e-14

  alias Spherical.R3.Vector

  test "Norms" do
    vectors = [
      {Vector.new(0, 0, 0), 0},
      {Vector.new(0, 1, 0), 1},
      {Vector.new(3, -4, 12), 13},
      {Vector.new(1, 1.0e-16, 1.0e-32), 1}
    ]

    for {vector, wanted_result} <- vectors do
      norm = Vector.norm(vector)
      assert float64_eq(norm, wanted_result)
    end
  end

  test "Squared norms" do
    vectors = [
      {Vector.new(0, 0, 0), 0},
		  {Vector.new(0, 1, 0), 1},
		  {Vector.new(1, 1, 1), 3},
		  {Vector.new(1, 2, 3), 14},
		  {Vector.new(3, -4, 12), 169},
		  {Vector.new(1, 1.0e-16, 1.0e-32), 1}
    ]

    for {vector, wanted_result} <- vectors do
      norm = Vector.square_norm(vector)
      assert float64_eq(norm, wanted_result)
    end
  end

  test "Normalized" do
    vectors = [
      Vector.new(1, 0, 0),
		  Vector.new(0, 1, 0),
		  Vector.new(0, 0, 1),
		  Vector.new(1, 1, 1),
		  Vector.new(1, 1.0e-16, 1.0e-32),
		  Vector.new(12.34, 56.78, 91.01)
    ]

    for v <- vectors do
      nv = Vector.normalize(v)
      assert float64_eq(v.x * nv.y, v.y * nv.x) || float64_eq(v.x * nv.z, v.z * nv.x)
      assert float64_eq(Vector.norm(nv), 1.0)
    end
  end

  test "Is unit" do
    vectors = [
      {Vector.new(0, 0, 0), false},
      {Vector.new(0, 1, 0), true},
      {Vector.new(1 + 2 * @epsilon, 0, 0), true},
      {Vector.new(1 * (1 + @epsilon), 0, 0), true},
      {Vector.new(1, 1, 1), false},
      {Vector.new(1, 1.0e-16, 1.0e-32), true},
    ]

    for {vector, wanted_result} <- vectors do
      assert wanted_result == Vector.is_unit?(vector)
    end
  end

  test "Vector dot" do
    vectors = [
      {Vector.new(1, 0, 0), Vector.new(1, 0, 0), 1},
      {Vector.new(1, 0, 0), Vector.new(0, 1, 0), 0},
      {Vector.new(1, 0, 0), Vector.new(1, 1, 1), 0},
      {Vector.new(1, 1, 1), Vector.new(-1, -1, -1), -3},
      {Vector.new(1, 2, 2), Vector.new(-0.3, 0.4, -1.2), -1.9}
    ]

    for {v1, v2, wanted_result} <- vectors do
      assert Vector.dot(v1, v2) |> float64_eq(wanted_result)
      assert Vector.dot(v2, v1) |> float64_eq(wanted_result)
    end
  end

  test "Vector adding" do
    vectors = [
      {Vector.new(0, 0, 0), Vector.new(0, 0, 0), Vector.new(0, 0, 0)},
      {Vector.new(1, 0, 0), Vector.new(0, 0, 0), Vector.new(1, 0, 0)},
      {Vector.new(1, 2, 3), Vector.new(4, 5, 7), Vector.new(5, 7, 10)},
      {Vector.new(1, -3, 5), Vector.new(1, -6, -6), Vector.new(2, -9, -1)}
    ]

    for {v1, v2, expected_vector} <- vectors do
      assert Vector.add(v1, v2) |> Vector.approx_equal(expected_vector)
    end
  end

  test "Vector substraction" do
    vectors = [
      {Vector.new(0, 0, 0), Vector.new(0, 0, 0), Vector.new(0, 0, 0)},
		  {Vector.new(1, 0, 0), Vector.new(0, 0, 0), Vector.new(1, 0, 0)},
		  {Vector.new(1, 2, 3), Vector.new(4, 5, 7), Vector.new(-3, -3, -4)},
		  {Vector.new(1, -3, 5), Vector.new(1, -6, -6), Vector.new(0, 3, 11)}
    ]

    for {v1, v2, expected_vector} <- vectors do
      assert Vector.sub(v1, v2) |> Vector.approx_equal(expected_vector)
    end
  end

  test "Vector distance" do
    vectors = [
      {Vector.new(1, 0, 0), Vector.new(1, 0, 0), 0},
		  {Vector.new(1, 0, 0), Vector.new(0, 1, 0), 1.41421356237310},
		  {Vector.new(1, 0, 0), Vector.new(0, 1, 1), 1.73205080756888},
		  {Vector.new(1, 1, 1), Vector.new(-1, -1, -1), 3.46410161513775},
      {Vector.new(1, 2, 2), Vector.new(-0.3, 0.4, -1.2), 3.80657326213486}
    ]

    for {v1, v2, expected_result} <- vectors do
      assert Vector.distance(v1, v2) |> float64_eq(expected_result)
      assert Vector.distance(v2, v1) |> float64_eq(expected_result)
    end
  end

  test "Vector multiplication" do
    vectors = [
      {Vector.new(0, 0, 0), 3, Vector.new(0, 0, 0)},
		  {Vector.new(1, 0, 0), 1, Vector.new(1, 0, 0)},
		  {Vector.new(1, 0, 0), 0, Vector.new(0, 0, 0)},
		  {Vector.new(1, 0, 0), 3, Vector.new(3, 0, 0)},
		  {Vector.new(1, -3, 5), -1, Vector.new(-1, 3, -5)},
		  {Vector.new(1, -3, 5), 2, Vector.new(2, -6, 10)}
    ]

    for {vector, m, expected_vector} <- vectors do
      assert Vector.mul(vector, m) |> Vector.approx_equal(expected_vector)
    end
  end

  test "Orthogonal vectors" do
    vectors = [
      Vector.new(0, 1, 0),
      Vector.new(1, 1, 1),
      Vector.new(1, 2, 3),
      Vector.new(1, -2, -5),
      Vector.new(0.012, 0.0053, 0.00457),
      Vector.new(-0.012, -10, -0.00457)
    ]

    for v <- vectors do
      assert Vector.orthogonal(v) |> Vector.dot(v) |> float64_eq(0)
      assert Vector.orthogonal(v) |> Vector.norm |> float64_eq(1)
    end
  end

  # Internal functions

  defp float64_eq(x, y) when is_number(x) and is_number(y) do
    Kernel.abs(x - y) < 1.0e14
  end

end
