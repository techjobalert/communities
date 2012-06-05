
;(function(){
    'use strict';

    this.Inscription = function(options){
        return this.init(options);
    };

    Inscription.run = function(options) {
        Inscription.instance = new Inscription(options);
        return Inscription.instance;
    };

    Inscription.filename = function() {
        return (Math.floor(Math.random()*1000*1000*1000)).toString(36) + '.flv';
    };

    Inscription.Movie = function(container) {
        this.container = container;
    };

    Inscription.Record = function(container) {
        this.container = container;
    };

    Inscription.Point = function(container) {
        this.container = container;
    };

    Inscription.Point.read = function(line) {

        var time = function(string) {
            return (function(arr) {
                return {
                    seconds: parseInt(arr[0]),
                    milliseconds: parseInt(arr[1])
                }
            })(string.split(','));
        };

        var convert = function(string) {
            return (function(parts) {
                return _.extend({
                    hours: parseInt(parts[0]),
                    minutes: parseInt(parts[1]),
                }, time(parts[2]))
            })(string.split(':'))
        };

        var points = line.split(';');
        var output = [];
        _.each(points, function(point){
            point = convert(point);

            console.log(point);

            output.push(
                point.hours * 3600 * 1000 +
                point.minutes * 60 * 1000 +
                point.seconds * 1000 +
                point.milliseconds
            );
        });
        return output;
    }

    Inscription.Movie.prototype = {
        play: function() {
            this.container.moviePlay();
        },

        stop: function() {
            this.container.movieStop();
        },

        pause: function() {
            this.container.moviePause();
        }
    };

    Inscription.Record.prototype = {
        start: function(filename) {
            this.container.recordStart(filename);
        },

        stop: function() {
            this.container.recordStop();
        },
    };

    Inscription.Point.prototype = {
        add: function(point) {
            this.container.addCuePoint(point);
        },
    };

    Inscription.prototype = {
        init: function(options) {
            _.extend(this, Backbone.Events);

            this.element = options.container;
            this.flashvars  = options.player;

            this.embed();

            this.on('load', _.bind(function(){
                this.container = document.getElementById(this.element);

                this.movie  = new Inscription.Movie(this.container);
                this.record = new Inscription.Record(this.container);
                this.point  = new Inscription.Point(this.container);
            }, this))
        },

        embed: function() {
            var flashvars = this.flashvars,
            params = {
                menu: false,
                allowscriptaccess: 'always'
            },
            attrs = {};

            var args = [
                "/assets/Inscription.swf", this.element,
                "800", "600", "11.0",
                "/aseets/expressInstall.swf",
                flashvars, params, attrs,
                _.bind(function(e){
                    if(e.success) {
                        this.trigger('load');
                    }
                }, this)
            ];

            swfobject.embedSWF.apply(this, args);
        }
    };

    Inscription.trigger = function(name, value) {
        Inscription.instance.trigger(name, value);
    };

}).call(this);
