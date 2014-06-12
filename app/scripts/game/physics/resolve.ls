require! 'game/physics/Vector'

const pad = 0.1
const rad-to-degrees = 180 / Math.PI

rect = (obj, contact) ->
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
  m = 1
  if point is undefined
    [line, point] = get-line-and-point contact, obj
    m = -1

    if point is undefined
      console.log 'Both undefined'
      return # TODO: Resolve this case
    else
      console.log 'One undefined'

  ([point] ++ line) .for-each (point) -> mark-level point

  # Find how far we need to move the obj:

  d = m * line-distance point, line
  line-ang = rad-to-degrees * line-angle line
  on-thing = obj.p.y < point.y and -50 < line-ang < 50

  if on-thing
    obj.state = 'on-thing'
    obj.v.y = 0
    d -= pad
    if obj.data?.player
      obj.rotate-trans = line-ang

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

line-angle = ([a, b]) -> b .minus a .angle!

module.exports = {rect}
