require! {
  'physics/collision'
  'physics/Matrix'
  'physics/Vector'
}

prepare-one = (shape) ->
  unless shape.prepared
    shape.prepared = true
    shape.prepare = -> prepare-one shape
    shape.destroy = -> shape._destroyed = true

    # Save ids:
    ids = ['*']
    if shape.id then ids[*] = that
    if shape.data?.id then ids[*] = that

    if shape.el?
      if shape.el.id then ids[*] = '#' + that

      for class-name in shape.el.class-list => ids[*] = '.' + class-name

    shape.ids = ids

    # Initialize velocity, position, and jump-frames (used to control height of jump)
    shape.v = shape.last-v = new Vector 0, 0
    shape.p = new Vector shape.{x, y}
    shape.fall-start = shape.y
    shape.jump-frames = shape.fall-dist = 0
    shape.jump-state = \ready

    # Is this a sensor?
    if shape.data?.sensor? then shape.sensor = true else shape.sensor = false

    # pre-calculate basic trig stuff
    unless shape.rotation? then shape.rotation = 0
    shape.sin = sint = sin shape.rotation
    shape.cos = cost = cos shape.rotation
    shape.matrix = matrix = new Matrix cost, -sint, sint, cost
    shape.imatrix = matrix.invert!

    # Player stuff:
    if shape.data?.player then shape.handle-input = true

    # Geometry:
    shape.find-geometry = ->
      shape.aabb = collision get-aabb shape
      shape.poly = collision.get-poly shape
      shape.geom-invalid = false

    shape.find-geometry!

  shape

prepare = (nodes) ->
  # Map the nodes to their prepared versions.
  nodes = nodes |> map prepare-one

  sort-points = (shape) ->
    p = 0
    if shape.data?.player? then p -= 10
    if shape.data?.dynamic? then p += 1
    p

  nodes = nodes.sort (a, b) -> (sort-points a) - (sort-points b)

  dynamics = nodes |> filter -> it.data?.player? or it.data?.dynamic?

  {dynamics, nodes}

module.exports = prepare
