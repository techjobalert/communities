$ ->
  $(".toggler label").live "click", ->
    elem = $(this)
    unless elem.hasClass("checked")
      $(".toggler label").toggleClass "checked"
      $(".doctor-only").toggleClass "hidden"

  $("#search-engine .btn.explore").live "click", ->
    $("#explore-popup").toggleClass "hidden"
