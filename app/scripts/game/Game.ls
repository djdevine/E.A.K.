require! {
  'channels'
  'game/CutScene'
  'game/Events'
  'game/Level'
  'logger'
  'ui/Bar'
}

first-path = window.location.pathname |> split '/' |> reject empty |> first
if first-path in window.LANGUAGES
  prefix = "/#first-path"
else prefix = ''

module.exports = class Game extends Backbone.Model
  initialize: (load, @logger-parent) ->
    if load then @load! else @save!

    @on \change @save

    @$level-title = $ \.levelname
    @$level-no = @$level-title.find \span
    @$level-name = @$level-title.find \h4

    bar-view = new Bar el: $ \#bar

    channels.stage.filter ( .type is 'level' ) .subscribe ({url}) ~> @start-level url
    channels.stage.filter ( .type is 'cutscene' ) .subscribe ({url}) ~> @start-cutscene url

  defaults: level: '/levels/index.html'

  start-level: (level-url) ~>
    {level-source, event} <~ @load-level level-url
    parsed = Slowparse.HTML document, level-source, [TreeInspectors.forbidJS]

    if parsed.error isnt null
      channels.alert.publish msg: 'There are errors in that level!'
      return

    for node in parsed.document.child-nodes
      if typeof! node is 'HTMLHtmlElement' then $level = $ node

    @$level-name.text ($level.find 'title' .text! or '')

    <~ $.hide-dialogues

    level = new Level $level
    level.event-id = event.id
    level.on 'done' -> event.stop!

  load-level: (level-url, cb) ~>
    l = prefix + level-url + "?#{Date.now!}"
    $.ajax {
      type: \GET
      url: level-url
      data-type: \html
      success: (level-source) ~>
        event <~ logger.start 'level', {level: level-url, parent: @logger-parent}
        logger.set-default-parent event.id
        cb {level-source, event}

      error: (xhr, text-status, err) ~>
        logger.log 'level-fail', {level: level-url, err: err, parent: @logger-parent}
        if xhr.status is 404 then return @load404 cb
        channels.alert.publish msg: "Couldn't load level: #{err}"
    }

  load404: (cb) ~>
    if @four-oh-four-page?
      event <~ logger.start 'level', {level: '404', parent: @logger-parent}
      cb {event, level-source: @four-oh-four-page.replace 'LAST_LEVEL', @last-level}

    else
      $.ajax {
        type: \GET
        url: "#{prefix}/levels/404.html?#{Date.now!}"
        data-type: \html
        success: (level-source) ~>
          @four-oh-four-page = level-source
          @load404 cb

        error: (xhr, text-status, err) ~>
          logger.log 'fatal', {msg: 'Cannot load the 404 page!', err: err}
          channels.alert.publish {
            msg: 'We encountered an error whilst trying to load the error page. PANIC!?!?!'
            timeout: 0ms
          }
      }

  start-cutscene: (name) ~>
    cs = new CutScene {name: "#prefix/cutscenes/#name"}
    cs.$el.append-to document.body
    cs.render!
    event <~ logger.start 'cutscene', {name: name, parent: @logger-parent}
    cs.on 'finish' -> event.stop!
    cs.on 'skip' -> logger.log 'skip' {parent: event.id}

  save: ~> @attributes |> _.clone |> JSON.stringify |> local-storage.set-item Game::savefile, _

  load: ~> Game::savefile |> local-storage.get-item |> JSON.parse |> @set

  savefile: \kittenquest-savegame
