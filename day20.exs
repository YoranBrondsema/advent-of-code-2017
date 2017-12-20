defmodule Day20 do
  def after_collisions(particles) do
    # This is not a very nice way, but basically this is an infinite recursion.
    # We assume that the point at which the collisions stop is early enough
    # so we just do Ctrl+C in the command line to stop the program.
    IO.inspect length(particles)

    remove_collisions(particles)
    |> update_particles
    |> after_collisions
  end

  def update_particles(particles) do
    particles
    |> Enum.map(&update_particle/1)
  end

  def update_particle({index, {p_x, p_y, p_z}, {v_x, v_y, v_z}, {a_x, a_y, a_z }}) do
    v_x = v_x + a_x
    v_y = v_y + a_y
    v_z = v_z + a_z

    p_x = p_x + v_x
    p_y = p_y + v_y
    p_z = p_z + v_z

    {
      index,
      { p_x, p_y, p_z },
      { v_x, v_y, v_z },
      { a_x, a_y, a_z }
    }
  end

  def remove_collisions(particles) do
    unique_positions = particles
                       |> Enum.reduce(
                         Map.new,
                         fn({ _, p, _, _ }, counts) ->
                           Map.put(
                             counts,
                             p,
                             Map.get(counts, p, 0) + 1
                           )
                         end
                       )
                       |> Enum.filter(
                         fn({ _, count }) -> count == 1 end
                       )
                       |> Enum.map(
                         fn({ p, _ }) -> p end
                       )

    particles
    |> Enum.filter(
      fn({ _, p, _, _ }) ->
        Enum.member?(unique_positions, p)
      end
    )
  end

  def closest(particles) do
    particles
    |> Enum.min_by(
      fn({ _, _, _, { a_x, a_y, a_z }}) ->
        abs(a_x) + abs(a_y) + abs(a_z)
      end
    )
  end

  def process_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.map(
      fn({ str, index }) ->
        [ _, p_x, p_y, p_z, v_x, v_y, v_z, a_x, a_y, a_z ] =
          ~r/p=<(.+),(.+),(.+)>, v=<(.+),(.+),(.+)>, a=<(.+),(.+),(.+)>/
          |> Regex.run(str)

        [ p_x, p_y, p_z, v_x, v_y, v_z, a_x, a_y, a_z ] =
          [ p_x, p_y, p_z, v_x, v_y, v_z, a_x, a_y, a_z ]
          |> Enum.map(
            fn(s) ->
              { value, _ } = Integer.parse(s)
              value
            end
          )

        {
          index,
          { p_x, p_y, p_z },
          { v_x, v_y, v_z },
          { a_x, a_y, a_z }
        }
      end
    )
  end
end

{ :ok, input } = File.read "day20-input.txt"

particles = input
            |> Day20.process_input

particles
|> Day20.after_collisions
|> IO.inspect
