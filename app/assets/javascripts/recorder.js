var Recorder = window.Recorder = {
  ins: undefined,
  playbackPoints: [],
  playButton: $("#play_button"),
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
    return _.map(Recorder.playbackPoints, function(obj, num){ _.map(obj, function(o,n){ return secondsToHms(o)})})
  },
  mergeFunc: function(){
    $("#sync_button strong").text("Saving..");
    var data = {
      video_id: Recorder.settings.videoId,
      record_file_name: Recorder.settings.recordFileName,
      playback_points: Recorder.preparePoints(),
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
      container: 'inscription',
      player: {
        resource: Recorder.settings.resourceLink,
        server: 'rtmp://89.209.76.243'
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
        Recorder.playButton.removeAttr('disabled');
      }
      else if (state === "playing"){
        Recorder.playButton.attr("disabled","true");
      }
      else if (state === "ready"){
        $("#sync_button").removeAttr('disabled');
        Recorder.playButton.attr("disabled","true");
        ins.record.stop();
      }
    }

    var onRecorderReady = function(status){
      if (status == true){
        $("#start_record_button").removeAttr('disabled');
        Recorder.playButton.removeAttr('disabled');
      }
    }

    ins.on('play',  onPlay);
    ins.on('stateChange', onStateChage);
    ins.on('recorderReady', onRecorderReady);
    Recorder.ins = ins;
  }
}