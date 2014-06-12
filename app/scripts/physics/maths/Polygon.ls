require! {
  'physics/maths/AABB'
  'physics/maths/Geom'
  'physics/maths/Vector'
}

module.exports = class Polygon extends Geom
  (shape) ->
    @_type = \polygon
    @_shape = shape
    update!

    @aabb = new AABB this

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
