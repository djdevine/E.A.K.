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
  get-line-and-point = (a, b) ->
    # attempt to find the line to resolve for
    lines = b.poly |> poly-lines
    l1 = lines |> sort-by (-> line-distance a.p, it) |> first

    # Find the point furthest from that line
    point = a.poly
      |> filter (-> it.in-poly b.poly)
      |> sort-by (-> line-distance it, l1)
      |> last

    unless point is undefined
      # Confirm line to resolve for:
      line = lines |> sort-by (-> line-distance point, it) |> first

    [line, point]

  [line, point] = get-line-and-point obj, contact
  if point is undefined
    [line, point] = get-line-and-point contact, obj

    if point is undefined
      console.log 'Both undefined'
      return # TODO: Resolve this case
    else
      console.log 'One undefined'

  ([point] ++ line) .for-each (point) -> mark-level point

  # Find how far we need to move the obj:

  d = line-distance point, line
  if obj.p.y < point.y
    obj.state = 'on-thing'
    obj.v.y = 0
    d -= pad

  # And in which direction...
  vec = line.0 .minus line.1
  vec = (new Vector vec.y, -vec.x) .normalize! .mult-n d

  obj._poly-invalid = true
  obj.p.minus-eq vec

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
