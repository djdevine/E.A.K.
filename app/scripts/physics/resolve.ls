module.exports = resolve = (obj, nodes) ->
  obj.geom.update!
  contacts = []
  # mtvs = []
  for node in nodes
    if node is obj then continue
    unless obj.geom.aabb.intersects node.geom.aabb then continue
    mtv = obj.geom.get-collision node.geom
    if mtv isnt false
      contacts[*] = node
      obj.p.add-eq mtv
      obj.geom.update!


  contacts
