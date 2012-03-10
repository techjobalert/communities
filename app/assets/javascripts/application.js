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
//= require jquery.textext.js
//= require jquery.pjax
//
//= require video
//= require main
//
//  Client Side Validations*
//= require rails.validations.js
//
//= require plupload/plupload.full
//= require plupload/plupload.flash
//= require plupload/plupload.html4
//= require plupload/plupload.html5
//= require plupload.base
//
//  Misc*
//= require jquery.html5-placeholder-shim
//= require imperavi-rails/imperavi
// require pjax
//
//  History.js
// require history.js
//= require jquery.history.js

function showHideNotice(type,message){
  $(".notice").remove();
  $('body').append('<div class="flash_' + type + ' notice">' + message + '</div>');
  setTimeout(function(){
    $(".notice").remove();
  }, 5000);
}

function hideNotice(){
  setTimeout(function(){
    $(".notice").remove();
  }, 7000);
}

// Helper methods for user -> settings -> educations
function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".edu-fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function getPopup(e){
  var obj = $(e.target),
      id = obj.attr("id"),
      popup = $("." + id),
      path;

  if (popup.length)
    $("." + id + ":hidden").length && showPopup(popup, obj);
  else {
    path = (id.indexOf('-item-') >= 0) ? "/items/" : "/users/";
    path += parseInt(id.replace(/\D+/g, ""));

    $.get(path, {
      type: "popup"
    }, function() {
      showPopup($("." + id), obj);
    }, "script");
  }
}

function showPopup(popup, obj){
  var popup_width = popup.width(),
      popup_height = popup.height(),
      popup_offset = {},
      obj_width = obj.width(),
      obj_height = obj.height(),
      obj_offset = obj.offset(),
      window_width = $(window).width(),
      window_height = $("body").height();


  popup_offset.left = obj_offset.left + (obj_width / 2) - (popup_width / 2);

  if (popup_offset.left <= 0)
    popup_offset.left = 30;
  else if ((popup_offset.left + popup_width) > window_width)
    popup_offset.left = window_width - popup_width - 30;

  popup_offset.top = obj_offset.top + (obj_height / 2) - (popup_height / 2);

  if ((popup_offset.top + popup_height) > window_height)
    popup_offset.top = window_height - popup_height - 30;
  else if (popup_offset.top <= 0)
    popup_offset.top = 30;

  $(".popup-container").css("display","none");
  popup.css(popup_offset).fadeIn("fast");
}
