var Recorder = window.Recorder = {
    ins: undefined,
    playbackPoints: [],
    settings: {},
    initialize: function (params) {
      _.each(params, function(v,k){Recorder.settings[k] = v});
      Recorder.initInscription();
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
    mergeRecord: function(){
      $('.rec-save').attr("disabled","true");
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
          console.log(Recorder.settings.timing);
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
        console.log(points);
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
          Recorder.pausePlay();
        }
        else if (state === "playing"){
          Recorder.startPlay();
        }
        else if (state === "ready"){
          Recorder.stopRecord();
          ins.record.stop();
        }
      }

      var onRecorderReady = function(status){
        if (status == true){
          $('.b-recorder__tools').fadeIn();
        }
      }

      ins.on('play',  onPlay);
      ins.on('stateChange', onStateChage);
      ins.on('recorderReady', onRecorderReady);
      Recorder.ins = ins;
    },
    startPlay: function(){
      $('.mv-play').attr("disabled","true");
      $('.mv-stop').removeAttr('disabled');
      $('.mv-pause').removeAttr('disabled');
    },
    stopPlay: function(){
      $('.mv-pause').attr("disabled","true");
      $('.rec-stop').attr("disabled","true");
      $('.mv-play').removeAttr('disabled');
    },
    pausePlay: function(){
      $('.mv-pause').attr("disabled","true");
      $('.mv-play').removeAttr('disabled');
    },
    startRecord: function(){
      $('.rec-start').attr("disabled","true");
      $('.rec-stop').removeAttr('disabled');
    },
    stopRecord: function(){
      $('.rec-stop').attr("disabled","true");
      $('.rec-start').removeAttr('disabled');
      $('.rec-save').removeAttr('disabled');
    }
  }

  $(document)
    .on('click', '.rec-start', function(){
      Recorder.ins.record.start(Recorder.settings.recordFileName);
      Recorder.startRecord();
      return false;
    })

    .on('click', '.rec-stop', function(){
      Recorder.ins.record.stop();
      Recorder.stopRecord();
      return false;
    })

    .on('click', '.rec-save', function(){
      Recorder.mergeRecord();
      return false;
    })

    .on('click', '.mv-play', function(){
      Recorder.ins.movie.play();
      Recorder.startPlay();
      return false;
    })

    .on('click', '.mv-pause', function(){
      Recorder.ins.movie.pause();
      Recorder.pausePlay();
      return false;
    })

    .on('click', '.mv-stop', function(){
      Recorder.ins.movie.stop();
      Recorder.stopPlay();
      return false;
    });