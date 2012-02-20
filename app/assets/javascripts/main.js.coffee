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
    obj_id = $(this).attr "id"
    obj_offset = $(this).offset()
    window_width = $(window).width()
    corner_class = ""
    timer_popup = window.setTimeout (->

      if (window_width - obj_offset.left > 500)
        settings = 
          top: (obj_offset.top - 43) + "px"
          left: (obj_offset.left + 85) + "px"
        corner_class = "left"
      else
        settings = 
          top: (obj_offset.top - 43) + "px"
          left: (obj_offset.left - 470) + "px"        

      if $("." + obj_id).length
        if $("." + obj_id + ":hidden").length
          $(".popup-container").fadeOut "fast"     
          $("." + obj_id).css(settings).fadeIn "fast"                
      else
        $(".popup-container").fadeOut "fast" 
        $(".tmp .popup-container")
          .clone()
          .addClass(obj_id + " b-popup-user-info " + corner_class)
          .appendTo("body")
          .css(settings)
          .fadeIn "fast"
        $.get "/users/" + parseInt(obj_id.replace(/\D+/g, "")),
          type: "popup"
        , (() ->), "script"
    ), 500


  $(".popup-item-info").live "mouseover", ->

    obj_id = $(this).attr "id"
    obj_offset = $(this).offset()
    obj_width = $(this).width()

    timer_popup = window.setTimeout (->
      settings = 
        top: (obj_offset.top - 100) + "px"
        left: (obj_offset.left - (442 - obj_width)/2) + "px"

      if $("." + obj_id).length
        if $("." + obj_id + ":hidden").length
          $(".popup-container").fadeOut "fast"
          $("." + obj_id).css(settings).fadeIn "fast"      
      else
        $(".popup-container").fadeOut "fast" 
        $(".tmp .popup-container")
          .clone()
          .addClass(obj_id + " b-popup-item-info")
          .appendTo("body")
          .css(settings)
          .fadeIn "fast"
        $.get "/items/" + parseInt(obj_id.replace(/\D+/g, "")),
          type: "popup"
        , (() ->), "script"
    ), 500

  $(".popup-item-info, .popup-user-info").live "mouseleave", ->
    obj_id = $(this).attr "id"
    unless $("." + obj_id + ":visible").length
      clearTimeout(timer_popup)
    
  $(".popup-container").live "mouseleave", ->
    $(this).fadeOut "fast"    

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

  $(".main-content .navigation a").live "click", ->
    $(".l-settings-navigation").html("")
    $(".main-content .navigation a").removeClass "selected"
    $(this).addClass "selected"

  $(".go-to-profile, .go-to-article, .main-content .navigation a").live "click", ->
    $(".popup-container").fadeOut "fast"

  $(".list-header .nav a").live "click", ->   
    unless $(this).hasClass("selected")
      $(".list-header .nav a").removeClass "selected"
      $(this).addClass("selected")