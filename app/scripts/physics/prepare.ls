require! {
  'physics/collision'
  'physics/maths/Matrix'
  'physics/maths/Polygon'
  'physics/maths/Vector'
}

prepare-one = (node) ->
  unless node.prepared
    node.prepared = true
    node.prepare = -> prepare-one node
    node.destroy = -> node._destroyed = true

    # Save ids:
    ids = ['*']
    if node.id then ids[*] = that
    if node.data?.id then ids[*] = that

    if node.el?
      if node.el.id then ids[*] = '#' + that

      for class-name in node.el.class-list => ids[*] = '.' + class-name

    node.ids = ids

    # Initialize velocity, position, and jump-frames (used to control height of jump)
    node.v = node.last-v = new Vector 0, 0
    node.p = new Vector node.{x, y}
    node.fall-start = node.y
    node.jump-frames = node.fall-dist = 0
    node.jump-state = \ready

    # Player stuff:
    if node.data?.player then node.handle-input = true

    # Is this a sensor?
    if node.data?.sensor? then node.sensor = true else node.sensor = false

    # Transformations:
    unless node.rotation? then node.rotation = 0
    node.sin = sint = sin node.rotation
    node.cos = cost = cos node.rotation
    node.matrix = matrix = new Matrix cost, -sint, sint, cost
    node.imatrix = matrix.invert!

    # Geometry
    node.geom = geom-from-def node

  node

prepare = (nodes) ->
  # Map the nodes to their prepared versions.
  nodes = nodes |> map prepare-one

  sort-points = (node) ->
    p = 0
    if node.data?.player? then p -= 10
    if node.data?.dynamic? then p += 1
    p

  nodes = nodes.sort (a, b) -> (sort-points a) - (sort-points b)

  dynamics = nodes |> filter -> it.data?.player? or it.data?.dynamic?

  {dynamics, nodes}

geom-from-def = (node) ->
  | node.type is 'rect' => new Polygon node
  | otherwise => throw new Error "Unrecognized type #{node.type}"

module.exports = prepare
