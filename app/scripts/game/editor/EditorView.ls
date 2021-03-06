require! {
  'channels'
  'game/editor/CodeMirrorExtras'
  'game/editor/NiceComments'
  'translations'
}

module.exports = class EditorView extends Backbone.View
  initialize: (options) ->
    html = @model.get \html

    @render-el = options.render-el if options.render-el?
    @renderer = @model.get \renderer

    @entities = @render-el.children \.entity

    cm = CodeMirror (@$ '.editor-html' .0),
      value: html
      mode: \htmlmixed
      theme: \jsbin
      tabsize: 2
      line-wrapping: true
      line-numbers: true

    cm.on \change @handle-change

    @ <<< {cm}
    @has-errors = false

    @listen-to @model, \change:html @on-change

    @extras = CodeMirrorExtras cm
    NiceComments cm

  events:
    'tap .save': \save
    'tap .cancel': \cancel
    'tap .undo': \undo
    'tap .redo': \redo
    'tap .reset': \reset

  handle-change: (cm) ~> @model.set \html cm.get-value!

  render: -> $ document.body .add-class \editor

  remove: ~>
    $ document.body .remove-class \editor
    @stop-listening!
    @cm.off \change @handle-change
    $ @cm.get-wrapper-element! .remove!

  on-change: (m, html) ~>
    # preserve entities
    @entities.detach!
    e = @render-el

    parsed = @extras.process html
    @has-errors = parsed.error isnt null

    e.empty!
    e.append parsed.document

    e.find 'style' .each (i, style) ~>
      $style = $ style
      $style |> ( .text! ) |> @renderer.preprocess-css |> $style.text

    @entities.append-to e

  restore-entities: ~>
    @render-el.children \.entity .detach!
    @entities.append-to @render-el

  cancel: ~>
    @model.set \html @model.get \startHTML
    @model.trigger \save

  reset: ~>
    html = @model.get \originalHTML
    @model.set \html html
    @cm.set-value html
    NiceComments @cm

  save: ~>
    if @has-errors
      channels.alert.publish msg: translations.errors.code-errors
      return

    @model.trigger \save

  undo: ~> @cm.undo!

  redo: ~> @cm.redo!
