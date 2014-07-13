err = (name) ->
  -> throw new Error "Error: method '#name' not implemented on '#{@_type}'"

module.exports = class Geom
  ->
    @_type = 'Raw Geom'

  update: err \update
  get-axes: err \get-axes
  centre: err \centre

  get-collision: (other) ~>
    axes = (@get-axes other) ++ (other.get-axes this)
      |> map ( .abs! )
      |> unique-by (-> Math.abs it.angle! )
    overlap = Infinity

    for axis in axes

      p1 = this.project axis
      p2 = other.project axis

      unless p1.overlap p2
        return false
      else
        o = p1.get-overlap p2
        if o < overlap
          overlap = o
          smallest = axis

    mtv = smallest.mult-n overlap
    c1 = this.centre!
    c2 = other.centre!
    if (mtv.dot c2.minus c1) > 0 then mtv = mtv.mult-n -1
    return mtv

  above: (other) ~>
    return @_shape.p.y < other.p.y
