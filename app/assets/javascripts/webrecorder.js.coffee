$ ->
  recorder = document.getElementById("recorder");
  if recorder.lenght
    recordind = false

    $(".link rec-start").on "click", (->
      record()
    )
    $(".link rec-stop").on "click", (->
      stopRecord() if recordind

    jsListener = (type, arguments) ->
      console.debug type + ":" + arguments

    record = (filename) ->
      unless filename
        _date = new Date()
        today = [ _date.getDate(), _date.getMonth() + 1, _date.getFullYear(), _date.getTime() ].join("-")
        filename = today + "_webcamvideo.mp4"
        recordind = true
      recorder.record filename
      $(".rec-start").attr('disabled','true');
      $(".rec-stop").removeAttr('disabled');

      $(".recorder-status").text = "Recording.."
    stopRecord = ->
      recorder.stopRecording()
      $(".rec-stop").attr('disabled','true');
      $(".rec-start").removeAttr('disabled');
      $(".recorder-status").text = ""
      recordind = false