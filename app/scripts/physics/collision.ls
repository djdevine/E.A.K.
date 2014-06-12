require! {
  'physics/Vector'
}

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

  # Rotated rectangles involve... MATHS! :D
  if a.geom-invalid then a.find-geometry!
  if b.geom-invalid then b.find-geometry!

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

transform-to-local-space = (shape, point) --> point.minus shape.p |> shape.imatrix.transform

# Get a list of potential contacts between one node and a list of nodes
get-contacts = (node, nodes) -> filter (has-contact node), nodes

module.exports = {get-aabb, get-poly, bbox-intersects, get-contacts, has-contact}
