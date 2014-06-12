err = (name) ->
  -> throw new Error "Error: method '#name' not implemented on '#{@_type}'"

module.exports = class Geom
  ->
    @_type = 'Raw Geom'

  update: err \update
