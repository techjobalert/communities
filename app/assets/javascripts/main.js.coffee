timer_popup = undefined
redactor = undefined
$ ->
  $("#sign-up .toggler label").live "click", ->
    elem = $(this)
    unless elem.hasClass("checked")
      $(".toggler label").toggleClass "checked"
      $(".doctor-only").toggleClass "hidden"
  
  $(".b-auth .buttons a").live "click", ->
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
    
  $(".popup-user-info").live
    mouseover: (e) ->
      timer_popup = window.setTimeout(->
        showUserPopup e
      , 500)
    click: (e) ->
      clearTimeout(timer_popup)
      showUserPopup e

  $(".popup-item-info").live
    mouseover: (e) ->
      timer_popup = window.setTimeout(->
        showItemPopup e
      , 500)
    click: (e) ->
      clearTimeout(timer_popup)
      showItemPopup e

  $(".popup-item-info, .popup-user-info").live "mouseleave", ->
    obj_id = $(this).attr "id"
    unless $("." + obj_id + ":visible").length
      clearTimeout(timer_popup)
    
  $(".popup-container").live "mouseleave", ->
    $(this).css("display","none")  

  $(".light-button.set-preview").toggle (->
    obj_offset = $(this).offset()
    $(".b-popup-set-preview").css(
      top: (obj_offset.top + 55) + "px"
      left: (obj_offset.left - 135) + "px"
    ).fadeIn "fast"
  ), ->
    $(".b-popup-set-preview").fadeOut "fast"
    
  $(".b-settings-nav a").live "click", ->
    unless $(this).hasClass("selected")
      $(".b-settings-nav a").toggleClass "selected"
      $(".b-settings-tab").toggleClass "hidden"
    false
    
  $(document).on "click", ".main-content .navigation a", ->
    $(".l-settings-navigation").html("")
    $(".main-content .navigation a").removeClass "selected"
    $(this).addClass "selected"
    false

  $(".go-to-profile, .go-to-article, .main-content .navigation a").live "click", ->
    $(".popup-container").fadeOut "fast"

  $(".list-header .nav a").live "click", ->
    unless $(this).hasClass("selected")
      $(".list-header .nav a").removeClass "selected"
      $(this).addClass("selected")

  $(".refresh-captcha").live "click", ->
    $(".simple_captcha").html('<div class="loading">Loading...</div>');