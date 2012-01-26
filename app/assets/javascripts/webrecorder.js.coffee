$ ->
  recorder = document.getElementById("recorder");
  if recorder.lenght
    recordind = false

    $(".recorder-stop-start").on "click", (->
      (if recordind then stopRecord() else record())
    )

    jsListener = (type, arguments) ->
      console.debug type + ":" + arguments

    record = (filename) ->
      unless filename
        _date = new Date()
        today = [ _date.getDate(), _date.getMonth() + 1, _date.getFullYear(), _date.getTime() ].join("-")
        filename = today + "_webcamvideo.mp4"
        console.log "filename autogenerated: " + filename
        recordind = true
      recorder.record filename
      $(".recorder-stop-start").text = "stop"
      $(".recorder-status").text = "Recording.."
    stopRecord = ->
      recorder.stopRecording()
      $(".recorder-stop-start").text = "start"
      $(".recorder-status").text = ""
      recordind = false