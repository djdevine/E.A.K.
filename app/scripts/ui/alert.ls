require! 'channels'

$body = $ document.body

$notification-container = $ '<div></div>'
  ..add-class \notification-container
  ..append-to $body

channels.alert.subscribe ({msg, timeout = 5000ms}) ->
  $alert = $ '<div></div>'
    ..add-class \notification
    ..prepend-to $notification-container

  $inner = $ '<div></div>'
    ..add-class \notification-inner
    ..text msg
    ..append-to $alert

  # If the timeout is 0, the alert stays forever
  if timeout is 0ms then return

  # Notifications are hidden after 5 seconds
  <- set-timeout _, timeout
  $alert.add-class \hidden

  <- $alert.on window.prefixed.animation-end
  $alert.remove!
