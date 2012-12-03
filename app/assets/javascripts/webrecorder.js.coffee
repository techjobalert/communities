$ ->
  recorder = $("#recorder");
  if recorder.length
    recordind = false

    $(".link rec-start").on "click", (->
      record()
    )
    $(".link rec-save").on "click", (->
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
      $(".rec-save").removeAttr('disabled');

      $(".recorder-status")
        .text = "Recording..."
        .blinkText();
    stopRecord = ->
      recorder.stopRecording()
      $(".rec-save").attr('disabled','true');
      $(".rec-start").removeAttr('disabled');
      $(".recorder-status").text = "Recording is completed"
      recordind = false