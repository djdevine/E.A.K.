require! {
  'game/physics/Vector'
}

# aabb: Axis Aligned Bounding Box. E.G:
#
# This:
#        /\
#       /  \
#      /    \
#      \    /
#       \  /
#        \/
#
# Has an AABB like this:
#      ______
#     |  /\  |
#     | /  \ |
#     |/    \|
#     |\    /|
#     | \  / |
#     |__\/__|
#
# We use AABBs in collision detection because it is very fast to check if two of them intersect.
# This means we can rule out collisions between two shapes that are miles away from each other
# very quickly, and then move on to more advanced and slower techniques for seeing if two thins
# are actually colliding.

# Get AABB takes an object and returns the aabb for it.
get-aabb = (obj) ->
  {x, y} = obj.p
  {width, height, radius, rotation} = obj

  switch
  # A rectangle with no rotation is its own bounding box. Easy!
  | obj.type is 'rect' and rotation is 0
    {
      left: x - width / 2
      right: x + width / 2
      top: y - height / 2
      bottom: y + height / 2
    }

  # Finding the aabb of a rotated rectangle is a little trickier. See http://i.stack.imgur.com/0SH6d.png
  | obj.type is 'rect' and rotation isnt 0
    sint = Math.abs obj.sin
    cost = Math.abs obj.cos
    aabb-width = height * sint + width * cost
    aabb-height = width * sint + height * cost

    {
      left: x - aabb-width / 2
      right: x + aabb-width / 2
      top: y - aabb-height / 2
      bottom: y + aabb-height / 2
    }

  # A circle's aabb is the same regardless of rotation
  | obj.type is 'circle'
    {
      left: x - radius
      right: x + radius
      top: y - radius
      bottom: y + radius
    }

get-poly = (shape) ->
  if shape.type is 'rect'
    {x, y} = shape.p
    {width, height, rotation} = shape

    hw = width / 2
    hh = height / 2
    poly = [
      new Vector x - hw, y - hh
      new Vector x + hw, y - hh
      new Vector x + hw, y + hh
      new Vector x - hw, y + hh
    ]

    # If rotated, rotate each point on the polygon accordingly:
    if rotation isnt 0
      poly .= map (point) ->
        start = point.{x, y}
        # center on origin:
        c = point .minus shape.p

        # Apply rotation matrix, translate back to original position
        end = shape.matrix.transform c .add shape.p
        mark-level end
        end

    return poly

  else
    throw new Error "Can only get poly for rect, not '#{shape.type}'"

# bbox-intersects takes two nodes, and returns true if their aabbs intersect, false in not.
bbox-intersects = (shape-a, shape-b) -->
  # If the shapes are the same, ignore
  if shape-a is shape-b then return false

  a = shape-a.aabb
  b = shape-b.aabb

  # Simple bounding box test (separating axis theorem)
  not (
    b.left > a.right or
    b.top > a.bottom or
    b.bottom < a.top or
    b.right < a.left
  )

has-contact = (a, b) -->
  # If the aabbs don't intersect, there's no way they're touching:
  unless bbox-intersects a, b then return false

  # We only do rectangles at the moment:
  if a.type isnt \rect and b.type isnt \rect
    throw new Error "Cannot detect collision between '#{a.type}' and '#{b.type}'"

  # non-rotated rectangles are easy
  if a.rotation is 0 and b.rotation is 0 then return true

  # Rotated rectangles involve... MATHS! :D
  if a._poly-invalid
    a.poly = get-poly a
    a._poly-invalid = false
  if a._poly-invalid
    b.poly = get-poly b
    b._poly-invalid = false

  check-rotated-rect-contact a, b

# Our algorithm for testing this is as follows:
# 1. Transform the pair into a's local space:
# 1.a. Translate the pair so a's center is at the origin
# 1.b. Rotate the pair about the origin so a is at 0 rotation
# 2. Calculate the new AABBs of a and b, and test those
# 3. Transform the pair into b's local space (see 1)
# 4. Calculate the new AABBs, and test those.
# 5. If both AABBs were intersecting, the shapes intersect
check-rotated-rect-contact = (a, b) ->
  mark-level {x: 150, y: 200} 'magenta'
  mark-level {x: 600, y: 200} 'magenta'

  if a.rotation isnt 0
    # step 1:
    local-trans = transform-to-local-space a
    a-poly = a.poly |> map local-trans
    b-poly = b.poly |> map local-trans

    # step 2:
    bbi-a = bbox-intersects {aabb: aabb-from-poly a-poly}, {aabb: aabb-from-poly b-poly}

  else bbi-a = true

  if b.rotation isnt 0
    # step 3:
    local-trans = transform-to-local-space b
    a-poly = a.poly |> map local-trans
    b-poly = b.poly |> map local-trans

    # step 4:
    bbi-b = bbox-intersects {aabb: aabb-from-poly a-poly}, {aabb: aabb-from-poly b-poly}

  else bbi-b = true

  # step 5:
  bbi-a and bbi-b

aabb-from-poly = (poly) ->
  xs = poly |> map ( .x )
  ys = poly |> map ( .y )
  {
    left: minimum xs
    right: maximum xs
    top: minimum ys
    bottom: maximum ys
  }

aabb-poly-intersect = (a-poly, b-poly) ->
  a-xs = a-poly |> map ( .x )
  a-ys = a-poly |> map ( .y )
  b-xs = b-poly |> map ( .x )
  b-ys = b-poly |> map ( .y )
  not (
    (minimum a-xs) > (maximum b-xs) or
    (minimum b-ys) > (maximum a-ys) or
    (maximum b-ys) < (minimum a-ys) or
    (maximum b-xs) < (minimum a-xs)
  )

transform-to-local-space = (shape, point) -->
  p = point.minus shape.p |> shape.imatrix.transform
  t = if shape.data.player then new Vector 150, 200 else new Vector 600, 200
  col = if shape.data.player then 'cyan' else 'lime'
  mark-level (p.add t), col
  p

# Get a list of potential contacts between one node and a list of nodes
get-contacts = (node, nodes) -> filter (has-contact node), nodes

module.exports = {get-aabb, get-poly, bbox-intersects, get-contacts, has-contact}
