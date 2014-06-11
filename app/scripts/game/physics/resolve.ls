require! 'game/physics/Vector'

const pad = 0.1

rect = (obj, contact) ->
  p = obj.aabb
  c = contact.aabb

  # Vertical collision
  on-top-of-thing = false
  if (p.bottom >= c.top and p.top <= c.bottom) then
    if obj.p.y < contact.p.y
      y-ofs = (c.top - obj.height / 2) - obj.p.y
      on-top-of-thing = true
    else
      y-ofs = (c.bottom + obj.height / 2 + pad) - obj.p.y

  # Horizontal collision
  if (p.right >= c.left and p.left <= c.right) then
    if obj.p.x < contact.p.x
      x-ofs = (c.left - obj.width / 2 - pad) - obj.p.x
    else
      x-ofs = (c.right + obj.width / 2 + pad) - obj.p.x

  if x-ofs? and y-ofs?
    if (Math.abs x-ofs) > (Math.abs y-ofs)
      obj._poly-invalid = true
      obj.p.y += y-ofs
      obj.v.y = 0

      # Is the obj on top of the thing?
      if on-top-of-thing
        obj._poly-invalid = true
        obj.state = 'on-thing'

    else
      obj.p.x += x-ofs
      obj.v.x = 0

  else if x-ofs?
    obj.p.x += x-ofs
    obj.v.x = 0
  else if y-ofs?
    obj.p.y += y-ofs
    obj.v.y = 0

    # Is the obj on top of the thing?
    if on-top-of-thing
      obj.state = 'on-thing'

rotated-rect = (obj, contact) ->
  # Find line to resolve for:
  line = contact.poly
    |> poly-lines
    |> sort-by (-> line-distance obj.p, it)
    |> first

  # Find the point furthest from that line
  point = obj.poly
    |> filter (-> it.in-poly contact.poly)
    |> sort-by (-> line-distance it, line)
    |> last

  ([point] ++ line) .for-each (point) -> mark-level point

  # Find how far we need to move the obj:
  d = line-distance point, line

  # And in which direction...
  vec = line.0 .minus line.1
  vec = (new Vector vec.y, -vec.x) .normalize! .mult-n d

  obj._poly-invalid = true
  obj.p.minus-eq vec

  if obj.p.y < contact.p.y then obj.state = 'on-thing'

# Get the distance between a point and a line. A line is defined by two points, [a, b]
line-distance = (p, [a, b]) ->
  dx = b.x - a.x
  dy = b.y - a.y

  (Math.abs dy*p.x - dx*p.y - a.x*b.y + b.x*a.y) / (Math.sqrt dx*dx + dy*dy)

poly-lines = (poly) ->
  l = poly.length
  lines = []
  for point, i in poly
    lines[*] = [point, poly[(i + 1) % l]]

  lines

module.exports = {rect, rotated-rect}
