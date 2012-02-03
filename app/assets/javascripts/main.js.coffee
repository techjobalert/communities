$ ->
  $(".toggler label").live "click", ->
    elem = $(this)
    unless elem.hasClass("checked")
      $(".toggler label").toggleClass "checked"
      $(".doctor-only").toggleClass "hidden"

  $("#popup-set-preview label").live "click", ->
    $("#popup-set-preview label").removeClass "checked"
    $(this).addClass "checked"

  $("#search-engine .btn.explore").live "click", ->
    $("#explore-popup").toggleClass "hidden"

  $(".popup-user-info").toggle (->
    t = $(this).offset()
    $("#popup-user-info").css(
      top: (t.top - 33) + "px"
      left: (t.left + 85) + "px"
    ).fadeIn "fast"
  ), ->
    $("#popup-user-info").fadeOut "fast"

  $('.light-button.set-preview').toggle (->
    t = $(this).offset()
    $("#popup-set-preview").css(
      top: (t.top + 55) + "px"
      left: (t.left - 135) + "px"
    ).fadeIn "fast"
  ), ->
    $("#popup-set-preview").fadeOut "fast"
