$(function() {

  if ($('#upcontainer').length){
    var uploader = new plupload.Uploader({
      runtimes: "html5,html4,flash",
      browse_button: "pickfiles",
      container: "upcontainer",
      max_file_size: "6mb",
      url: "/upload_avatar.json",
      flash_swf_url: "assets/plupload/plupload.flash.swf",
      multipart: true,
      multipart_params: {
        authenticity_token: $("meta[name=csrf-token]").attr("content")
      },
      filters: [
        {
          title: "Images",
          extensions: "jpg,jpeg,png,JPG,JPEG,PNG"
        }
      ]
    });

    uploader.init();
    
    uploader.bind("FilesAdded", function(up, files) {
      uploader.start();
      up.refresh();
    });

    uploader.bind('FileUploaded', function(up, file, response) {
      var obj = jQuery.parseJSON(response.response);
      $.map(obj, function(value, key){
        $('.my-'+key).attr('src',value);
      });    
    });

    uploader.bind("BeforeUpload", function(up, file, info) {
      $('.spinner').removeClass('hidden');
    });

    uploader.bind("UploadComplete", function(up, files) {
      $('.spinner').addClass('hidden');
    });

    uploader.bind("Error", function(up, error) {
      alert(error.message);
    });
  }
});