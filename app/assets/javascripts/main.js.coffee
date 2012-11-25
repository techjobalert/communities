timer_popup = undefined
redactor = undefined

@changeNavigationTab = (tab) ->
  $(".main-content .navigation a").removeClass("selected");
  $(tab).addClass("selected");
  $(".l-settings-navigation").addClass('hidden') if tab != ".tab-settings"

  $(".filter-form select").chosen() if $(".filter-form select").length

@searchRelevantItems = (type) ->
  $(".list-header #_attachment_type").val type
  $(".list-header form").submit()

$ ->
  $('a.pjax, .pagination a:not([data-remote=true])').pjax("[data-pjax-container]") if $("[data-pjax-container]").length

  $(document)
    .on "pjax:start", ->
      clearTimeout(timer_popup)
      $(".popup-container").css("display","none")
    .on "pjax:end", ->
      clearTimeout(timer_popup)
      $(".popup-container").css("display","none")

    .on "click", "#sign-up .toggler label", ->
      $("#sign-up .toggler label").hasClass ""
      elem = $(this)
      $("#user_profession_and_degree").attr("data-validate", elem.hasClass "doctor" ? true : false)
      unless elem.hasClass("checked")
        $(".toggler label").toggleClass "checked"
        $(".doctor-only").toggleClass "hidden"
      $.placeholder.shim() if $.placeholder

    .on "click", ".b-auth .buttons a", ->
      elem = $(this)
      unless elem.hasClass("selected")
        $(".b-auth .buttons a").toggleClass "selected"
        $(".sign-tab").toggleClass "hidden"
        $.placeholder.shim() if $.placeholder
      false

    .on "click", ".b-popup-set-preview label", ->
      $(".b-popup-set-preview label").removeClass "checked"
      $(this).addClass "checked"

    .on "click", ".b-search-engine .btn.explore", ->
      $(".b-explore-popup").toggleClass "hidden"

    .on "click", ".tag-link", ->
      $("#main-search").val($(this).html())
      $("#main-search").closest("form").submit()
      false


    .on "click", ".notice", ->
      $(this).remove()

    .on "keypress", ".sign-tab form", (e) ->
      code = e.keyCode
      $(this).submit() if code == 13

    .on
      mouseover: (e) ->
        timer_popup = window.setTimeout(->
          getPopup e
        , 500)
      click: (e) ->
        clearTimeout(timer_popup)
        $(".popup-container").css("display","none")
      , ".popup-item-info, .popup-user-info"

    .on "mouseleave", ".popup-item-info, .popup-user-info", ->
      obj_id = $(this).attr "id"
      unless $("." + obj_id + ":visible").length
        clearTimeout(timer_popup)

    .on "mouseleave", ".popup-container:not(.b-popup-set-preview)", ->
      $(this).css("display","none")

    .on "click", ".b-settings-nav a", ->
      unless $(this).hasClass("selected")
        $(".b-settings-nav a").removeClass "selected"
        $(this).addClass "selected"
        id = $(this).attr "id"
        $(".b-settings-tab").addClass "hidden"
        $("." + id).removeClass("hidden")
      false

    .on "click", ".list-header .nav a", ->
      unless $(this).hasClass("selected")
        $(".list-header .nav a").removeClass "selected"
        $(this).addClass("selected")

    .on "click", ".refresh-captcha", ->
      $(".simple_captcha").html('<div class="loading">Loading...</div>');

    .on "click", ".popup-cleaner, .go-to-profile, .go-to-article, .main-content .navigation a:not(.tab-item)", ->
      $(".popup-container").css("display","none");
      $(".l-settings-navigation").addClass('hidden') unless $(this).hasClass "tab-settings"

    .on "click", "#payment-type-toogler .lb", ->
      unless $(this).hasClass("selected")
        $("#payment-type-toogler .lb").removeClass "selected"
        $(this).addClass "selected"
        cvv_input = $("input#pay_account_verification_value")
        cvv_input.val("")
        if $(this).hasClass("ae") then cvv_input.attr("maxlength","4") else cvv_input.attr("maxlength","3")

    .on "change", "form[data-validate=true][data-remote=true]", ->
      $(this).validate()

  $(".b-popup-set-preview form #item_preview_length").data('val',$(".b-popup-set-preview form #item_preview_length").val())

  $(".btn.set-preview").toggle ((e) ->

    obj_offset = $(e.target).offset()
    console.log($(e.target))
    $(".b-popup-set-preview").css(
      top: (obj_offset.top + 55) + "px"
      left: (obj_offset.left - 135) + "px"
    ).fadeIn "fast"
  ), ->
    if $(".b-popup-set-preview").is(":visible")
      $(".b-popup-set-preview").fadeOut "fast"
      popup_input = $(".b-popup-set-preview form #item_preview_length")
      if popup_input.data('val') != popup_input.val()
        popup_input.data('val',popup_input.val())
        popup_input.closest('form').submit()

  msearch = $("#main-search")
  if msearch.length
    msearch.autocomplete(
      source: "/items/qsearch"
      minLength: 3
      width: 100
      select: (event, ui) ->
        window.location.assign ui.item.url
        $(this).autocomplete "close"
    ).data("autocomplete")._renderItem = (ul, item) ->
      $("<li></li>")
        .addClass("qsearch-item")
        .data("item.autocomplete", item)
        .append("<a class='pjax' href=\"" + item.url + "\">" + item.title + "</a>")
        .appendTo ul

  usearch = $("#collegues-add-form #q")
  if usearch.length
    usearch.autocomplete
      source: (request,response) ->
        form = usearch.closest('form')
        form.submit()
      minLength: 2

  ssearch = $(".filter:not(.collegues) #qsearch")
  if ssearch.length
    ssearch.autocomplete(
      source: (request,response) ->
        form = ssearch.closest('form')
        $.ajax
          url: "/items/qsearch"
          data:
            term: ssearch.val()
            filter_type: form.find("#_filter_type").val()
            attachment_type: form.find("#_attachment_type").val()
            price: form.find("#_price").val()
            date: form.find("#_date").val()
          type: "GET"
          success: (data) ->
            response $.map(data, (item) ->
              url: item.url
              title: item.title
            )
      minLength: 3
      width: 100
      select: (event, ui) ->
        window.location.assign ui.item.url
        $(this).autocomplete "close"
    ).data("autocomplete")._renderItem = (ul, item) ->
      $("<li></li>")
        .addClass("qsearch-item")
        .data("item.autocomplete", item)
        .append("<a class='pjax' href=\"" + item.url + "\">" + item.title + "</a>")
        .appendTo ul

  msearch.closest('form').submit ->
    msearch.autocomplete "close"

  $(".sign-in").click() if window.location.hash.indexOf("#sign-in") >= 0