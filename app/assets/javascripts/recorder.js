var Recorder = window.Recorder = {
  ins: undefined,
  playbackPoints: [],
  settings: {},
  initialize: function (params) {
    _.each(params, function(v,k){Recorder.settings[k] = v});
    Recorder.initInscription();
  },
  startRecord: function(){
    $("#start_record_button").attr("disabled","true");
    Recorder.ins.record.start(Recorder.settings.recordFileName);
  },
  preparePoints:function(){
    //NOT USING NOW
    for (var id in Recorder.playbackPoints) {
      var obj = Recorder.playbackPoints[id];
      for (var key in obj) {
         obj[key] = secondsToHms(obj[key]);
       }
    }
    return Recorder.playbackPoints;
  },
  mergeFunc: function(){
    $("#sync_button strong").text("Saving..");
    var data = {
      video_id: Recorder.settings.videoId,
      record_file_name: Recorder.settings.recordFileName,
      playback_points: Recorder.playbackPoints,
      position: $("input[type=radio]:checked").val()
    };
    $.ajax({
      url: Recorder.settings.requestUrl,
      type: "POST",
      dataType: "json",
      data: data,
      success: function(data){
        $("#sync_button strong").text("Saved");
        eval(data);
      }
    });
  },
  initInscription: function(){
    var ins;
    var loaded = false;
    ins = Inscription.run({
      container: Recorder.settings.container,
      player: {
        resource: Recorder.settings.resourceLink,
        server: Recorder.settings.server
      }
    });
    // Hack for ajax req
    setTimeout(function(){
      if (!loaded){
        ins.embed();
      }
    }, 2000);

    ins.on('load', function() {
      console.log('loaded');
      loaded = true;
      initPoints();
    });
    var initPoints = function(){
      setTimeout(function() {
        var points = Inscription.Point.read(Recorder.settings.timing);
        _.each(points, function(point) {
          ins.point.add(point);
          console.log('Added point: ' + point + ' ms...');
        });
      }, 5000);
    }
    var callback = function() {
      console.log(arguments);
    };

    var onPlay = function(points) {
      var _s = _.size(Recorder.playbackPoints);
      var points = {
        stop: points[0],
        pause_duration: points[1]/1000,
        start: _s ? Recorder.playbackPoints[_s-1].stop : 0,
        duration: points[0] - (_s ? Recorder.playbackPoints[_s-1].stop : 0)
      }
      Recorder.playbackPoints.push(points);
    }

    var onStateChage = function(state) {
      console.log(state);
      if (state === "paused"){
        $("#play_button").removeAttr('disabled');
      }
      else if (state === "playing"){
        $("#play_button").attr("disabled","true");
      }
      else if (state === "ready"){
        $("#sync_button").removeAttr('disabled');
        $("#play_button").attr("disabled","true");
        ins.record.stop();
      }
    }

    var onRecorderReady = function(status){
      if (status == true){
        $("#start_record_button").removeAttr('disabled');
        //$("#play_button").removeAttr('disabled');
      }
    }

    ins.on('play',  onPlay);
    ins.on('stateChange', onStateChage);
    ins.on('recorderReady', onRecorderReady);
    Recorder.ins = ins;
  }
}