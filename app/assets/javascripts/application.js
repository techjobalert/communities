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
