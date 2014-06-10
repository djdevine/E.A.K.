walk = (css, type, fn) ->
  for rule in css.rules
    if rule.type is type
      fn rule
    else if rule.rules?
      walk rule, type, fn

prefix = <[box-shadow animation animation-name animation-duration animation-delay
  animation-direction animation-fill-mode animation-iteration-count animation-timing-function
  transition transition-property transition-duration transition-delay transition-timing-function
  transform transform-origin perspective perspective-origin transform-style backface-visibility
  linear-gradient radial-gradient repeating-linear-gradient repearing-radial-gradient box-sizing]>

module.exports = class CSS
  (css) ->
    @source = css
    @css = rework css
    @clean = rework css

  scope: (scope) ~>
    @css.use (css) ->
      walk css, 'rule', (rule) ->
        rule.selectors .= map (selector) ->
          | selector.trim! is 'body' => "#scope"
          | selector.match 'body' => selector.replace 'body', scope
          | otherwise => "#scope #selector"

  rewrite-hover: (new-hover) ~>
    @css.use (css) ->
      walk css, 'rule', (rule) ->
        rule.selectors .= map -> it.replace ':hover', new-hover

  prefix: ~>
    @css.vendors ['-webkit-', '-moz-', '-ms-', '-o-']
    @css.use rework.keyframes!
    for prop in prefix => @css.use rework.prefix prop

  to-clean-string: (compress = false) ~>
    @clean.to-string {compress}

  to-string: (compress = false) ~>
    @css.to-string {compress}
