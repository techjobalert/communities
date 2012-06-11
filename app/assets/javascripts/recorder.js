var Recorder = window.Recorder = {
  initialize: function (params) {
    var ins,
        playbackPoints=[],
        playButton = $("#play_button"),
        recordFileName = params["fileName"],
        resourceLink = params["resourceLink"],
        requestUrl = params["requestUrl"],
        timing = params["timing"],
        videoId = params["videoId"];
  },

  startRecord: function(){
    $("#start_record_button").attr("disabled","true");
    ins.record.start(recordFileName);
  },
  preparePoints:function(){
    return _.map(playbackPoints, function(obj, num){ _.map(obj, function(o,n){ return secondsToHms(o)})})
  },
  mergeFunc: function(){
    $("#sync_button strong").text("Saving..");
    var data = {  video_id: videoId,
                  record_file_name: recordFileName,
                  playback_points: preparePoints(),
                  position: $("input[type=radio]:checked").val()};
    $.ajax({
      url: requestUrl,
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
    ins = Inscription.run({
      container: 'inscription',
      player: {
          resource: resourceLink,
          server: 'rtmp://89.209.76.243'
      }
    });

    ins.on('load', function() {
      console.log('loaded');
      setTimeout(function() {
        var points = Inscription.Point.read(timing);
        _.each(points, function(point) {
            ins.point.add(point);
            console.log('Added point: ' + point + ' ms...');
        });
      }, 5000);
    });

    var callback = function() {
      console.log(arguments);
    };

    var onPlay = function(points) {
      var _s = _.size(playbackPoints);
      var points = {
        stop: points[0],
        pause_duration: points[1]/1000,
        start: _s ? playbackPoints[_s-1].stop : 0,
        duration: points[0] - (_s ? playbackPoints[_s-1].stop : 0)
      }
      playbackPoints.push(points);
    }

    var onStateChage = function(state) {
      console.log(state);
      if (state === "paused"){
        playButton.removeAttr('disabled');
      }
      else if (state === "playing"){
        playButton.attr("disabled","true");
      }
      else if (state === "ready"){
        $("#sync_button").removeAttr('disabled');
        playButton.attr("disabled","true");
        ins.record.stop();
      }
    }

    var onRecorderReady = function(status){
      if (status == true){
        $("#start_record_button").removeAttr('disabled');
        playButton.removeAttr('disabled');
      }
    }

    ins.on('play',  onPlay);
    ins.on('stateChange', onStateChage);
    ins.on('recorderReady', onRecorderReady);
  }
}