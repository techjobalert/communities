// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//  System*
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//
//  Fileupload*
//= require jquery.ui.widget
//=	require jquery.iframe-transport
//= require jquery.fileupload
//
//= require video
//= require main

//= require plupload/plupload.full
//= require plupload/plupload.flash
//= require plupload/plupload.html4
//= require plupload/plupload.html5
//= require plupload.base

function showHideNotice(type,message){
  $('body').append('<div class="flash_' + type + ' notice">' + message + '</div>');
  setTimeout(function(){
    $(".notice").remove();
  }, 7000);
}

function hideNotice(){
  setTimeout(function(){
    $(".notice").remove();
  }, 7000);
}

if (history && history.pushState) {
  $(function() {
    $("a[data-remote=true]:not(.no-history)").live("click", function(e) {
      $.getScript(this.href);
      history.pushState(null, document.title, this.href);
      //#History.pushState(null, document.title, this.href);
      e.preventDefault();
    });
    $(window).bind("popstate", function() {
      $.getScript(location.href);
    });
  });
}

function showUserPopup(e) {
    var corner_class, obj_id, obj_offset, window_width, window_height, settings,
      left_offset, top_offset;

    obj_id = $(e.target).attr("id");
    obj_offset = $(e.target).offset();
    window_width = $(window).width();
    window_height = $(window).height();
    
    if (window_width - obj_offset.left > 500)  
      left_offset = obj_offset.left + 85;
    else
      left_offset = obj_offset.left - 470;
     

    if ($("." + obj_id).length) {
      if ($("." + obj_id + ":hidden").length) {
        $(".popup-container:visible").css("display","none");

        top_offset = ((window_height - obj_offset.top) > $("." + obj_id).height())
          ? obj_offset.top - 43 
          : window_height - $("." + obj_id).height() - 50;

        settings = {
          top: top_offset + "px",
          left: left_offset + "px"};
        $("." + obj_id).css(settings).fadeIn("fast");
      }
    } else {
      $(".popup-container:visible").css("display","none");
      $(".tmp .popup-container").clone().addClass(obj_id + " b-popup-user-info " + corner_class).appendTo("body");

      $.get("/users/" + parseInt(obj_id.replace(/\D+/g, "")), {
        type: "popup"
      }, (function() {
        top_offset = ((window_height - obj_offset.top) > $("." + obj_id).height())
          ? obj_offset.top - 43 
          : window_height - $("." + obj_id).height() - 50;

        settings = {
          top: top_offset + "px",
          left: left_offset + "px"};

        $("." + obj_id).css(settings).fadeIn("fast");
      }), "script");
    }
  }

function showItemPopup(e) {
  var obj_id, obj_offset, obj_width, left_offset, window_width;
  obj_id = $(e.target).attr("id");
  obj_offset = $(e.target).offset();
  obj_width = $(e.target).width();
  window_width = $(window).width();

  var settings;

  left_offset = obj_offset.left - (442 - obj_width) / 2;
  if (left_offset < 0) 
    left_offset = 20
  else if (left_offset > (window_width - 480)) 
    left_offset = window_width - 480;

  settings = {
    top: (obj_offset.top - 170) + "px",
    left: left_offset + "px"
  };

  if ($("." + obj_id).length) {
    if ($("." + obj_id + ":hidden").length) {
      $(".popup-container").css("display","none");;
      $("." + obj_id).css(settings).fadeIn("fast");
    }
  } else {
    $(".popup-container").css("display","none");
    $(".tmp .popup-container").clone().addClass(obj_id + " b-popup-item-info").appendTo("body").css(settings).fadeIn("fast");
    $.get("/items/" + parseInt(obj_id.replace(/\D+/g, "")), {
      type: "popup"
    }, (function() {}), "script");
  }
  
}