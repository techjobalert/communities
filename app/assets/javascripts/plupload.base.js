$(function() {
  return $.initPlupload = function(options) {
    var uploader, settings;


    settings = {
      runtimes: "html5,html4,flash",
      browse_button: "pickfiles",
      container: "upcontainer",
      max_file_size: "3mb",
      flash_swf_url: "assets/plupload/plupload.flash.swf",
      multipart: true,
      multipart_params: {
        authenticity_token: $("meta[name=csrf-token]").attr("content")},
      filters: [{ title: "Images", extensions: "jpg,jpeg,png,JPG,JPEG,PNG"}]
    };

    // Extend base settings by options
    $.extend(settings, options);
    if ( !$("#"+settings.container) || !$("#"+settings.browse_button) )
      return false;

    uploader = new plupload.Uploader(settings);
    uploader.init();

    uploader.bind("FilesAdded", function(up, files) {
      uploader.start();
      up.refresh();
    });
    $("#filelist").delegate("i.remove", "click", function() {
      if (confirm('Are you sure to remove this file?')) {
        $(this).parent("div").fadeOut("slow", function(){
          $(this).remove();
        });
      }
    });
    // uploader.bind('FileUploaded', function(up, file, response) {
    //   if (response.response === Object){
    //     var obj = jQuery.parseJSON(response.response);
    //     $.map(obj, function(value, key){
    //       $('.my-'+key).attr('src',value);
    //     });
    //   }
    // });

    uploader.bind("BeforeUpload", function(up, file, info) {
      $('.spinner').removeClass('hidden');
    });

    uploader.bind("UploadComplete", function(up, files) {
      $('.spinner').addClass('hidden');
    });

    uploader.bind('UploadProgress', function(up, file) {
      var f = $('#' + file.id + " b");
      if (f.length) f.html(file.percent + "%");
    });

    uploader.bind('FilesAdded', function(up, files) {
      $.each(files, function(i, file) {
        if ($('#filelist').length) $('#filelist').append(
          '<div id="' + file.id + '" class="filename">' +
          file.name + ' (' + plupload.formatSize(file.size) + ') <b></b>'+
          '<i class="remove web-symbols">×</i></div>');
      });

      up.refresh(); // Reposition Flash/Silverlight
    });

    uploader.bind('Error', function(up, err) {
      if ($('#filelist').length) $('#filelist').append("<div>Error: " + err.code +
        ", Message: " + err.message +
        (err.file ? ", File: " + err.file.name : "") +
        "</div>"
      );
      alert(err.message);
      up.refresh(); // Reposition Flash/Silverlight
    });

    uploader.bind("FileUploaded", function(up, file, info) {

      try {
        var response = $.parseJSON(info.response),
            coords,
            cropArea = false;

        var f = $('#' + file.id);
        if (f.length){
          f.children("b").html("100%");
          f.append('<input type="hidden" name="item[attachment_id]" value="'+response.id+'">');
        }

        if (response.url){
          $('.b-user-colorbox').colorbox();
          $.colorbox({href: response.url, close: "Закрыть", onComplete: function(){
            $(".cboxPhoto").Jcrop({minSize:[143,143], aspectRatio: 1, onSelect: Coords, onChange: Coords});
            $('<div id="crop-save">Save</div>').appendTo('#cboxContent');
          }});
        }
      } catch (e) {eval(info.response);}



      function Coords(c){
        coords = c;
        if (!cropArea){
          cropArea = true;
          $("#crop-save").fadeIn();
        }

        $("#crop-save").unbind().click(function(){
          if (cropArea) {
            var url = uploader.settings.url;

            $.ajax({
              type: "POST",
              dataType: "JSON",
              url: url + "/crop",
              data: {coords: coords},
              success: function(data){
                $.colorbox.close();
                $("#crop-save").fadeOut();
                $("#"+uploader.settings.browse_button).trigger("crop_complite", data);
                $.map(data, function(value, key){
                  $('.my-'+key).attr('src',value);
                });
                return data;
              }
            });
          }
        });
      }
    });
  }
});
