module.exports = class Projection
  (min, max) ->
    if min > max then throw new Error 'Projection: min (#min) must be less then max (#max)'
    @ <<< {min, max}

  # Is there an overlap?
  overlap: (b) ->
    not (this.min > b.max or b.min > this.max)

  # What's the magnitude of the overlap?
  get-overlap: (b) ->
    unless @overlap b then return 0

    return (Math.min this.max, b.max) - (Math.max this.min, b.min)
