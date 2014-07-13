require! {
  'physics/maths/Geom'
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

module.exports = class AABB extends Geom
  (shape) ->
    @_shape = shape
    @_type = \aabb
    @aabb = this
    @update!

  update: ->
    shape = @_shape
    {x, y} = shape.p
    {width, height, radius, rotation, type} = shape

    this <<< switch
      # A rectangle with no rotation is its own bounding box. Easy!
      case type is \rect and rotation is 0
        {
          left: x - width / 2
          right: x + width / 2
          top: y - height / 2
          bottom: y + height / 2
        }

      # Finding the aabb of a rotated rectangle is a little trickier.
      case type is \rect and rotation isnt 0
        sint = Math.abs shape.sin
        cost = Math.abs shape.cos
        aabb-width = height * sint + width * cost
        aabb-height = width * sint + height * cost

        {
          left: x - aabb-width / 2
          right: x + aabb-width / 2
          top: y - aabb-height / 2
          bottom: y + aabb-height / 2
        }

      # A circle's aabb is the same regardless of rotation
      case type is \circle
        {
          left: x - radius
          right: x + radius
          top: y - radius
          bottom: y + radius
        }

      default => throw new Error "Cannot find AABB for '#type'"

  intersects: (other) ~>
    if other._type isnt \aabb then throw new Error 'Can only check intersect against another AABB!'
    not (
      other.left > this.right or
      other.top > this.bottom or
      other.bottom < this.top or
      other.right < this.left
    )
