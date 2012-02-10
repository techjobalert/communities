$ ->
  $("#sign-up .toggler label").live "click", ->
    elem = $(this)
    unless elem.hasClass("checked")
      $(".toggler label").toggleClass "checked"
      $(".doctor-only").toggleClass "hidden"
  
  $('.b-auth .buttons a').live "click", ->
    elem = $(this)
    unless elem.hasClass("selected")
      $(".b-auth .buttons a").toggleClass "selected"
      $(".sign-tab").toggleClass "hidden"
    false
    
  $("a.sign-in").click()  if window.location.hash.indexOf("#sign-in") >= 0
    
    
  $(".b-popup-set-preview label").live "click", ->
    $(".b-popup-set-preview label").removeClass "checked"
    $(this).addClass "checked"

  $(".b-search-engine .btn.explore").live "click", ->
    $(".b-explore-popup").toggleClass "hidden"
    
  $(".popup-user-info").live "click", ->
    if $(".b-popup-user-info:hidden").length
      t = $(this).offset()
      $(".b-popup-user-info").css(
        top: (t.top - 33) + "px"
        left: (t.left + 85) + "px"
      ).fadeIn "fast"
    else
      $(".b-popup-user-info").fadeOut "fast"
    
  $(".b-popup-user-info").live "mouseleave", ->
    $(this).fadeOut "fast"

  $('.light-button.set-preview').toggle (->
    t = $(this).offset()
    $(".b-popup-set-preview").css(
      top: (t.top + 55) + "px"
      left: (t.left - 135) + "px"
    ).fadeIn "fast"
  ), ->
    $(".b-popup-set-preview").fadeOut "fast"
    
  $(".b-settings-nav a").live "click", ->
    unless $(this).hasClass("selected")
      $(".b-settings-nav a").toggleClass "selected"
      $(".b-settings-tab").toggleClass "hidden"
    false
   
