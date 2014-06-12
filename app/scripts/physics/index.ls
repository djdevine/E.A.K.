window.mark-level = ({x, y}, color = 'red') ->
  $ '<div></div>'
    ..css {
      width: \10px
      height: \10px
      margin-top: '-5px'
      margin-left: '-5px'
      border-radius: \100%
      border: "1px solid #color"
      position: \absolute
      left: "#{x}px"
      top: "#{y}px"
    }
    ..add-class 'level-marker'
    ..append-to $ '#levelcontainer .level'

window.clear-marks = -> $ '.level-marker' .remove!

require! {
  'physics/collision'
  'physics/events'
  'physics/Matrix'
  'physics/prepare'
  'physics/resolve'
  'physics/step'
  'physics/Vector'
}

/*

A modular physics library for use with maps from game/dom/mapper.

Usage:

  map = get-map-from-mapper!

  // state represents the entire physics world
  state = prepare map

  every frame:
    // Update runs the physics simulations to get to the next frame. time-delta should be the
    // number of milliseconds elapsed since the last frame
    state = step state, time-delta

    // Triggers events from the state on mediator.
    events state, mediator


*/

module.exports = { Vector, Matrix, prepare, step, collision, resolve, events }
