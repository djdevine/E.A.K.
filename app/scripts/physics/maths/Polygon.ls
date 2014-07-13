require! {
  'physics/maths/AABB'
  'physics/maths/Geom'
  'physics/maths/Projection'
  'physics/maths/Vector'
}

module.exports = class Polygon extends Geom
  (shape) ->
    @_type = \polygon
    @_shape = shape
    @aabb = new AABB shape
    @update!

  update: ->
    shape = @_shape
    switch shape.type
      case 'rect'
        {x, y} = shape.p
        {width, height, rotation} = shape

        hw = width / 2
        hh = height / 2
        points = [
          new Vector x - hw, y - hh
          new Vector x + hw, y - hh
          new Vector x + hw, y + hh
          new Vector x - hw, y + hh
        ]

        # If rotated, rotate each point on the polygon accordingly:
        if rotation isnt 0
          points .= map (point) ->
            start = point.{x, y}
            # center on origin:
            c = point .minus shape.p

            # Apply rotation matrix, translate back to original position
            shape.matrix.transform c .add shape.p

        @_points = points

      default => throw new Error "Cannot find polygon for '#that'"

    @aabb.update!

  edges: ~>
    for i from 0 til @_points.length
      j = (i + 1) % @_points.length

      mark-level @_points[i]

      ed = @_points[i].minus @_points[j]

      ed.init = @_points[j]
      ed

  get-axes: ~>
    edges = @edges!
    edges.map (edge) ->
      n = edge.normal!normalize!
      mark-level edge.init.add(edge.mult-n 0.5), 'lime'
      mark-level edge.init.add(edge.mult-n 0.5).add(n.mult-n 20), 'lime'
      n.edge = edge
      n

    # return edges |> map ( .normal! .normalize! )

  project: (axis) ~>
    min = axis.dot @_points.0
    max = min
    for i from 1 til @_points.length
      p = axis.dot @_points[i]
      if p < min then min = p else if p > max then max = p

    p1 = axis.edge.init #.add(axis.edge.mult-n 0.5).add(axis.mult-n 50)
    nn = axis #.mult-n -1
    mark-level p1, 'cyan'
    # mark-level p1.add(nn.mult-n max), 'cyan'

    new Projection min, max

  centre: ~>
    return @_shape.p
