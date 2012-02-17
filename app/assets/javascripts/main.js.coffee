timer_popup = undefined

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
    
  $(".popup-user-info").live "mouseover", ->
    id = $(this).attr "id"
    t = $(this).offset()

    timer_popup = window.setTimeout (->
      settings = 
        top: (t.top - 43) + "px"
        left: (t.left + 85) + "px"

      if $("." + id).length
        if $("." + id + ":hidden").length
          $(".popup-container").fadeOut "fast"     
          $("." + id).css(settings).fadeIn "fast"                
      else
        $(".popup-container").fadeOut "fast" 
        $(".tmp .popup-container")
          .clone()
          .addClass(id + " left b-popup-user-info")
          .appendTo("body")
          .css(settings)
          .fadeIn "fast"
        $.get "/users/" + parseInt(id.replace(/\D+/g, "")),
          type: "popup"
        , (() ->), "script"
    ), 1500


  $(".popup-item-info").live "mouseover", ->

    id = $(this).attr "id"
    t = $(this).offset()

    timer_popup = window.setTimeout (->
      settings = 
        top: (t.top - 43) + "px"
        left: (t.left + 285) + "px"

      if $("." + id).length
        if $("." + id + ":hidden").length
          $(".popup-container").fadeOut "fast"
          $("." + id).css(settings).fadeIn "fast"      
      else
        $(".popup-container").fadeOut "fast" 
        $(".tmp .popup-container")
          .clone()
          .addClass(id + " left b-popup-item-info")
          .appendTo("body")
          .css(settings)
          .fadeIn "fast"
        $.get "/items/" + parseInt(id.replace(/\D+/g, "")),
          type: "popup"
        , (() ->), "script"
    ), 1500

  $(".popup-item-info, .popup-user-info").live "mouseleave", ->
    id = $(this).attr "id"
    unless $("." + id + ":visible").length
      clearTimeout(timer_popup)
    
  $(".popup-container").live "mouseleave", ->
    $(this).fadeOut "fast"    

  $(".light-button.set-preview").toggle (->
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

  $(".main-content .navigation a").live "click", ->
    $(".l-settings-navigation").html("")
    $(".main-content .navigation a").removeClass "selected"
    $(this).addClass "selected"

  $(".list-header .nav a").live "click", ->   
    unless $(this).hasClass("selected")
      $(".list-header .nav a").removeClass "selected"
      $(this).addClass("selected")