/**
 █▒▓▒░ The FlexPaper Project

 This file is part of FlexPaper.

 FlexPaper is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.

 FlexPaper is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with FlexPaper.  If not, see <http://www.gnu.org/licenses/>.

 For more information on FlexPaper please see the FlexPaper project
 home page: http://flexpaper.devaldi.com
 */

/**
*
* FlexPaper helper function for retrieving a active FlexPaper instance 
*
*/ 
window.$FlexPaper = window.getDocViewer = window["$FlexPaper"] = function(id){
	var instance = (id==="undefined")?"":id;

    if (window['ViewerMode'] == 'flash') {
		return window["FlexPaperViewer_Instance"+instance].getApi();
	}else if(window['ViewerMode'] == 'html'){
		return window["FlexPaperViewer_Instance"+instance];
	}
};

/**
 *
 * FlexPaper embedding (name of placeholder, config)
 *
 */
window.FlexPaperViewerEmbedding = window.$f = function(id, args) {
    this.id = id;

    var config = args.config;
    var _SWFFile,_PDFFile,_IMGFiles,_JSONFile  = "",_jsDirectory="",_cssDirectory="",_localeDirectory="";_WMode = (config.WMode!=null||config.wmmode!=null?config.wmmode||config.WMode:"window");
    var _uDoc = ((config.DOC !=null)?unescape(config.DOC):null);
    var instance = "FlexPaperViewer_Instance"+((id==="undefined")?"":id);
    var _JSONDataType = (config.JSONDataType!=null)?config.JSONDataType:"json";

    if (_uDoc != null) {
        _SWFFile 	= translateUrlByFormat(_uDoc,"swf");
        _PDFFile 	= translateUrlByFormat(_uDoc,"pdf");
        _JSONFile 	= translateUrlByFormat(_uDoc,_JSONDataType);
        _IMGFiles 	= translateUrlByFormat(_uDoc,"png");
    }

    _SWFFile  			= (config.SwfFile!=null?config.SwfFile:_SWFFile);
    _SWFFile  			= (config.SWFFile!=null?config.SWFFile:_SWFFile);
    _PDFFile 			= (config.PDFFile!=null?config.PDFFile:_PDFFile);
    _IMGFiles 			= (config.IMGFiles!=null?config.IMGFiles:_IMGFiles);
    _IMGFiles 			= (config.PageImagePattern!=null?config.PageImagePattern:_IMGFiles);
    _JSONFile 			= (config.JSONFile!=null?config.JSONFile:_JSONFile);
    _jsDirectory 		= (config.jsDirectory!=null?config.jsDirectory:"js/");
    _cssDirectory 		= (config.cssDirectory!=null?config.cssDirectory:"css/");
    _localeDirectory 	= (config.localeDirectory!=null?config.localeDirectory:"locale/");
    if(_SWFFile!=null && _SWFFile.indexOf("{" )==0 && _SWFFile.indexOf("[*," ) > 0 && _SWFFile.indexOf("]" ) > 0){_SWFFile = escape(_SWFFile);} // split file fix

    window[instance] = flashembed(id, {
        src						    : _jsDirectory+"../FlexPaperViewer.swf",
        version					    : [10, 0],
        expressInstall			    : "js/expressinstall.swf",
        wmode					    : _WMode
    },{
        ElementId               : id,
        SwfFile  				: _SWFFile,
        PdfFile  				: _PDFFile,
        IMGFiles  				: _IMGFiles,
        JSONFile 				: _JSONFile,
        useCustomJSONFormat 	: config.useCustomJSONFormat,
        JSONPageDataFormat 		: config.JSONPageDataFormat,
        JSONDataType 			: _JSONDataType,
        Scale 					: (config.Scale!=null)?config.Scale:0.8,
        ZoomTransition 			: (config.ZoomTransition!=null)?config.ZoomTransition:'easeOut',
        ZoomTime 				: (config.ZoomTime!=null)?config.ZoomTime:0.5,
        ZoomInterval 			: (config.ZoomInterval)?config.ZoomInterval:0.2,
        FitPageOnLoad 			: (config.FitPageOnLoad!=null)?config.FitPageOnLoad:false,
        FitWidthOnLoad 			: (config.FitWidthOnLoad!=null)?config.FitWidthOnLoad:false,
        FullScreenAsMaxWindow 	: (config.FullScreenAsMaxWindow!=null)?config.FullScreenAsMaxWindow:false,
        ProgressiveLoading 		: (config.ProgressiveLoading!=null)?config.ProgressiveLoading:false,
        MinZoomSize 			: (config.MinZoomSize!=null)?config.MinZoomSize:0.2,
        MaxZoomSize 			: (config.MaxZoomSize!=null)?config.MaxZoomSize:5,
        SearchMatchAll 			: (config.SearchMatchAll!=null)?config.SearchMatchAll:false,
        SearchServiceUrl 		: config.SearchServiceUrl,
        InitViewMode 			: config.InitViewMode,
        BitmapBasedRendering 	: (config.BitmapBasedRendering!=null)?config.BitmapBasedRendering:false,
        StartAtPage 			: config.StartAtPage,
        PrintPaperAsBitmap		: (config.PrintPaperAsBitmap!=null)?config.PrintPaperAsBitmap:false,
        AutoAdjustPrintSize		: (config.AutoAdjustPrintSize!=null)?config.AutoAdjustPrintSize:false,

        EnableCornerDragging 	: ((config.EnableCornerDragging!=null)?config.EnableCornerDragging:true), // FlexPaper Zine parameter
        BackgroundColor 		: config.BackgroundColor, // FlexPaper Zine parameter
        PanelColor 				: config.PanelColor, // FlexPaper Zine parameter
        BackgroundAlpha         : config.BackgroundAlpha, // FlexPaper Zine parameter
        UIConfig                : config.UIConfig,  // FlexPaper Zine parameter

        ViewModeToolsVisible 	: ((config.ViewModeToolsVisible!=null)?config.ViewModeToolsVisible:true),
        ZoomToolsVisible 		: ((config.ZoomToolsVisible!=null)?config.ZoomToolsVisible:true),
        NavToolsVisible 		: ((config.NavToolsVisible!=null)?config.NavToolsVisible:true),
        CursorToolsVisible 		: ((config.SearchToolsVisible!=null)?config.CursorToolsVisible:true),
        SearchToolsVisible 		: ((config.SearchToolsVisible!=null)?config.SearchToolsVisible:true),
        StickyTools				: config.StickyTools,
        Toolbar                 : config.Toolbar,
        DocSizeQueryService 	: config.DocSizeQueryService,

        RenderingOrder 			: config.RenderingOrder,

        localeChain 			: (config.localeChain!=null)?config.localeChain:"en_US",
        jsDirectory 			: _jsDirectory,
        cssDirectory 			: _cssDirectory,
        localeDirectory			: _localeDirectory,
        key 					: config.key
    });
};

function translateUrlByDocument(url,document){
	return (url!=null && url.indexOf('{doc}') > 0 ? url.replace("{doc}", document):null);	
}

function translateUrlByFormat(url,format){
	if(url.indexOf("{") == 0 && format != "swf"){ // loading in split file mode
		url = url.substring(1,url.lastIndexOf(","));
		url = url.replace("[*,0]","{page}")
	}
	return (url!=null && url.indexOf('{format}') > 0 ? url.replace("{format}", format):null);
}

/** 
 * 
 * FlexPaper embedding functionality. Based on FlashEmbed
 *
 */

(function() {

	var  IE = document.all,
		 URL = 'http://www.adobe.com/go/getflashplayer',
		 JQUERY = typeof jQuery == 'function', 
		 RE = /(\d+)[^\d]+(\d+)[^\d]*(\d*)/,
         MOBILE = (function(){try {return 'ontouchstart' in document.documentElement;} catch (e) {return false;} })(),
		 GLOBAL_OPTS = { 
			// very common opts
			width: '100%',
			height: '100%',		
			id: "_" + ("" + Math.random()).slice(9),
			
			// flashembed defaults
			allowfullscreen: true,
			allowscriptaccess: 'always',
			quality: 'high',
            allowFullScreenInteractive : true,
			
			// flashembed specific options
			version: [10, 0],
			onFail: null,
			expressInstall: null, 
			w3c: false,
			cachebusting: false  		 		 
	};

    window.isTouchScreen = MOBILE;

	if (window.attachEvent) {
		window.attachEvent("onbeforeunload", function() {
			__flash_unloadHandler = function() {};
			__flash_savedUnloadHandler = function() {};
		});
	}
	
	// simple extend
	function extend(to, from) {
		if (from) {
			for (var key in from) {
				if (from.hasOwnProperty(key)) {
					to[key] = from[key];
				}
			}
		} 
		return to;
	}

    // used by Flash to dispatch a event properly
    window.dispatchJQueryEvent = function (elementId,eventName,args){
        jQuery('#'+elementId).trigger(eventName,args);
    }

	// used by asString method	
	function map(arr, func) {
		var newArr = []; 
		for (var i in arr) {
			if (arr.hasOwnProperty(i)) {
				newArr[i] = func(arr[i]);
			}
		}
		return newArr;
	}

	window.flashembed = function(root, opts, conf) {
		// root must be found / loaded	
		if (typeof root == 'string') {
			root = document.getElementById(root.replace("#", ""));
		}
		
		// not found
		if (!root) { return; }
		
		root.onclick = function(){return false;}
		
		if (typeof opts == 'string') {
			opts = {src: opts};	
		}

		return new Flash(root, extend(extend({}, GLOBAL_OPTS), opts), conf); 
	};	
	
	// flashembed "static" API
	var f = extend(window.flashembed, {
		
		conf: GLOBAL_OPTS,
	
		getVersion: function()  {
			var fo, ver;
			
			try {
				ver = navigator.plugins["Shockwave Flash"].description.slice(16); 
			} catch(e) {
				
				try  {
					fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
					ver = fo && fo.GetVariable("$version");
					
				} catch(err) {
                try  {
                    fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");
                    ver = fo && fo.GetVariable("$version");  
                } catch(err2) { } 						
				} 
			}
			
			ver = RE.exec(ver);
			return ver ? [ver[1], ver[3]] : [0, 0];
		},
		
		asString: function(obj) { 

			if (obj === null || obj === undefined) { return null; }
			var type = typeof obj;
			if (type == 'object' && obj.push) { type = 'array'; }
			
			switch (type){  
				
				case 'string':
					obj = obj.replace(new RegExp('(["\\\\])', 'g'), '\\$1');
					
					// flash does not handle %- characters well. transforms "50%" to "50pct" (a dirty hack, I admit)
					obj = obj.replace(/^\s?(\d+\.?\d+)%/, "$1pct");
					return '"' +obj+ '"';
					
				case 'array':
					return '['+ map(obj, function(el) {
						return f.asString(el);
					}).join(',') +']'; 
					
				case 'function':
					return '"function()"';
					
				case 'object':
					var str = [];
					for (var prop in obj) {
						if (obj.hasOwnProperty(prop)) {
							str.push('"'+prop+'":'+ f.asString(obj[prop]));
						}
					}
					return '{'+str.join(',')+'}';
			}
			
			// replace ' --> "  and remove spaces
			return String(obj).replace(/\s/g, " ").replace(/\'/g, "\"");
		},
		
		getHTML: function(opts, conf) {

			opts = extend({}, opts);
			opts.id = opts.id + (" " + Math.random()).slice(9);
			
			/******* OBJECT tag and it's attributes *******/
			var html = '<object width="' + opts.width + 
				'" height="' + opts.height + 
				'" id="' + opts.id + 
				'" name="' + opts.id + '"';
			
			if (opts.cachebusting) {
				opts.src += ((opts.src.indexOf("?") != -1 ? "&" : "?") + Math.random());		
			}			
			
			if (opts.w3c || !IE) {
				html += ' data="' +opts.src+ '" type="application/x-shockwave-flash"';		
			} else {
				html += ' classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';	
			}
			
			html += '>'; 
			
			/******* nested PARAM tags *******/
			if (opts.w3c || IE) {
				html += '<param name="movie" value="' +opts.src+ '" />'; 	
			} 
			
			// not allowed params
			opts.width = opts.height = opts.id = opts.w3c = opts.src = null;
			opts.onFail = opts.version = opts.expressInstall = null;
			
			for (var key in opts) {
				if (opts[key]) {
					html += '<param name="'+ key +'" value="'+ opts[key] +'" />';
				}
			}	
		
			/******* FLASHVARS *******/
			var vars = "";
			
			if (conf) {
				for (var k in conf) {
                    if (conf[k] && k!='Toolbar') {
						var val = conf[k];
						vars += k +'='+ (/function|object/.test(typeof val) ? f.asString(val) : val) + '&';
					}
				}
				vars = vars.slice(0, -1);
				html += '<param name="flashvars" value=\'' + vars + '\' />';
			}
			
			html += "</object>";	
			
			return html;				
		},
		
		isSupported: function(ver) {
			return VERSION[0] > ver[0] || VERSION[0] == ver[0] && VERSION[1] >= ver[1];			
		}		
		
	});
	
	var VERSION = f.getVersion(); 
	
	function Flash(root, opts, conf) {
        var userAgent = navigator.userAgent.toLowerCase();
        var browser = {
            version: (userAgent.match(/.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/) || [])[1],
            safari: /webkit/.test(userAgent),
            opera: /opera/.test(userAgent),
            msie: /msie/.test(userAgent) && !/opera/.test(userAgent),
            mozilla: /mozilla/.test(userAgent) && !/(compatible|webkit)/.test(userAgent),
            chrome: /chrome/.test(userAgent)
        };

        var platform = {
            win:/win/.test(userAgent),
            mac:/mac/.test(userAgent),
            touchdevice : (function(){try {return 'ontouchstart' in document.documentElement;} catch (e) {return false;} })(),
            ios : ((userAgent.match(/iphone/i)) || (userAgent.match(/ipod/i)) || (userAgent.match(/ipad/i)))
        };

        var supportsHTML4   = (browser.mozilla && browser.version.split(".")[0] >= 3) ||
            (browser.chrome) ||
            (browser.msie && browser.version.split(".")[0] >= 8) ||
            (browser.safari) ||
            (browser.opera);

        // Default to a rendering mode if its not set
        if(!conf.RenderingOrder && conf.SwfFile !=  null){conf.RenderingOrder = "flash";}
        if(!conf.RenderingOrder && conf.JSONFile !=  null && conf.JSONFile){conf.RenderingOrder = "html";}
        if(!conf.RenderingOrder && conf.PdfFile !=  null){conf.RenderingOrder = "html5";}

        // version is ok
		if ((conf.RenderingOrder.indexOf('flash') == 0 || (conf.RenderingOrder.indexOf('flash')>0 &&!supportsHTML4)) && f.isSupported(opts.version)) {
            if(conf.Toolbar){
                var wrapper = jQuery(root).wrap("<div style='"+jQuery(root).attr('style')+"'></div>").parent();
                jQuery(root).css({
                    left : '0px',
                    top: '0px',
                    position : 'relative',
                    width : '100%',
                    height : '100%'
                }).addClass('flexpaper_viewer');

                wrapper.prepend(jQuery(conf.Toolbar));
            }
			window['ViewerMode'] = 'flash';
			root.innerHTML = f.getHTML(opts, conf);

            if(conf.Toolbar){
                // initialize event handlers for flash
                jQuery.getScript(conf.jsDirectory+'flexpaper_flashhandlers_htmlui.js', function() {
                    FLEXPAPER.bindFlashEventHandlers(root);
                });
            }
			
		// express install
		} else if ((conf.RenderingOrder.indexOf('flash') == 0) && opts.expressInstall && f.isSupported([6, 65])) {
			window['ViewerMode'] = 'flash';

            if(conf.Toolbar){
                var wrapper = jQuery(root).wrap("<div style='"+jQuery(root).attr('style')+"'></div>").parent();
                jQuery(root).css({
                    left : '0px',
                    top: '0px',
                    position : 'relative',
                    width : '100%',
                    height : '100%'
                }).addClass('flexpaper_viewer');

                wrapper.prepend(jQuery(conf.Toolbar));
            }

			root.innerHTML = f.getHTML(extend(opts, {src: opts.expressInstall}), {
				MMredirectURL: location.href,
				MMplayerType: 'PlugIn',
				MMdoctitle: document.title
			});

            if(conf.Toolbar){
                // initialize event handlers for flash
                jQuery.getScript(conf.jsDirectory+'flexpaper_flashhandlers_htmlui.js', function() {
                    FLEXPAPER.bindFlashEventHandlers(root);
                });
            }

		} else { //use html viewer or die
			window['ViewerMode'] = 'html';
			//jQuery.noConflict();
			if(true){
				jQuery(document).ready(function() {
					jQuery.getScript(conf.jsDirectory+'FlexPaperViewer.js', function() {
						var viewerId = jQuery(root).attr('id');
						var supportsPDFJS 	= 	(browser.mozilla && browser.version.split(".")[0] >= 4) ||
												(browser.chrome && browser.version.split(".") >= 535) ||
												(browser.msie && browser.version.split(".")[0] >= 9) ||
												(platform.ios) ||
												(browser.safari && browser.version.split(".")[0] >= 534);

                        if(!conf.RenderingOrder){
                            conf.RenderingOrder = "";
                            if(conf.PdfFile!=null){conf.RenderingOrder = "html5";}
                            if(conf.SwfFile!=null){conf.RenderingOrder += (conf.RenderingOrder.length>0?",":"")+"flash"}
                            if(conf.JSONFile!=null){conf.RenderingOrder += (conf.RenderingOrder.length>0?",":"")+"html"}
                        }


						var oRenderingList 	= conf.RenderingOrder.split(",");
						var pageRenderer 	= null;

						if(conf.PdfFile!=null && conf.PdfFile.length>0 && conf.RenderingOrder.split(",").length>=1 && supportsPDFJS && (oRenderingList[0] == 'html5' || (oRenderingList.length > 1 && oRenderingList[0] == 'flash' && oRenderingList[1] == 'html5')) && !(platform.touchdevice && oRenderingList.length > 1 && oRenderingList[1] == 'html')){
							pageRenderer = new CanvasPageRenderer(viewerId,conf.PdfFile,conf.jsDirectory);	
						}else{
							pageRenderer = new ImagePageRenderer(
							viewerId,
							{
				   			jsonfile : conf.JSONFile,
							pageImagePattern : conf.IMGFiles,
							compressedJSONFormat : !conf.useCustomJSONFormat,
							JSONPageDataFormat : conf.JSONPageDataFormat,
							JSONDataType : conf.JSONDataType
							},
                            conf.jsDirectory);
						}					

						var instance = "FlexPaperViewer_Instance"+((viewerId==="undefined")?"":viewerId);
						window[instance] = new FlexPaperViewer_HTML({
							rootid 		: viewerId,
                            Toolbar 	: ((conf.Toolbar!=null)?conf.Toolbar:null),
				            instanceid 	: instance,
				            document: {
				                SWFFile 				: conf.SwfFile,
				                IMGFiles 				: conf.IMGFiles,
				                JSONFile 				: conf.JSONFile,
				                PDFFile 				: conf.PdfFile,
								Scale 					: conf.Scale,
								FitPageOnLoad 			: conf.FitPageOnLoad,
								FitWidthOnLoad 			: conf.FitWidthOnLoad,
								MinZoomSize 			: conf.MinZoomSize,
								MaxZoomSize 			: conf.MaxZoomSize,
								SearchMatchAll 			: conf.SearchMatchAll,
								InitViewMode 			: conf.InitViewMode,
								StartAtPage 			: conf.StartAtPage,
								RenderingOrder 			: conf.RenderingOrder,
								useCustomJSONFormat 	: conf.useCustomJSONFormat,
								JSONPageDataFormat 		: conf.JSONPageDataFormat,
								JSONDataType 			: conf.JSONDataType,
								ZoomInterval 			: conf.ZoomInterval,
								ViewModeToolsVisible 	: conf.ViewModeToolsVisible,
								ZoomToolsVisible 		: conf.ZoomToolsVisible,
								NavToolsVisible 		: conf.NavToolsVisible,
								CursorToolsVisible 		: conf.CursorToolsVisible,
								SearchToolsVisible 		: conf.SearchToolsVisible,
								StickyTools 			: conf.StickyTools,
								PrintPaperAsBitmap 		: conf.PrintPaperAsBitmap,
								AutoAdjustPrintSize 	: conf.AutoAdjustPrintSize,
								EnableCornerDragging	: conf.EnableCornerDragging,
                                UIConfig                : conf.UIConfig,
                                BackgroundColor			: conf.BackgroundColor, // FlexPaper Zine parameter
                                PanelColor				: conf.PanelColor, // FlexPaper Zine parameter

								localeChain 			: conf.localeChain
				            }, 
							renderer 			: pageRenderer,
							key 				: conf.key,
							jsDirectory 		: conf.jsDirectory,
							localeDirectory 	: conf.localeDirectory,
							cssDirectory 		: conf.cssDirectory,
							docSizeQueryService : conf.DocSizeQueryService
				        });

						window[instance].initialize();
						window[instance].bindEvents();
						
						window[instance]['load'] = window[instance].loadFromUrl;
						window[instance]['loadDoc'] = window[instance].loadDoc;
						window[instance]['fitWidth'] = window[instance].fitwidth;
						window[instance]['fitHeight'] = window[instance].fitheight;
						window[instance]['gotoPage'] = window[instance].gotoPage;
						window[instance]['getCurrPage'] = window[instance].getCurrPage;
						window[instance]['getTotalPages'] = window[instance].getTotalPages;
						window[instance]['nextPage'] = window[instance].next;
						window[instance]['prevPage'] = window[instance].previous;
						window[instance]['setZoom'] = window[instance].Zoom;
						window[instance]['Zoom'] = window[instance].Zoom;
						window[instance]['openFullScreen'] = window[instance].openFullScreen;
						window[instance]['sliderChange'] = window[instance].sliderChange;
						window[instance]['searchText'] = window[instance].searchText;
                        window[instance]['resize'] = window[instance].resize;
						//window[instance]['nextSearchMatch'] = window[instance].nextSearchMatch; //TBD
						//window[instance]['prevSearchMatch'] = window[instance].nextSearchMatch; //TBD
						window[instance]['switchMode'] = window[instance].switchMode;
						window[instance]['printPaper'] = window[instance].printPaper;
						//window[instance]['highlight'] = window[instance].highlight; //TBD
						//window[instance]['postSnapshot'] = window[instance].postSnapshot; //TBD
						window[instance]['setCurrentCursor'] = window[instance].setCurrentCursor;

		   			    pageRenderer.initialize(function(){
		   			    	 //console.profile('FlexPaper init-postinit');
							  window[instance].document.numPages = pageRenderer.getNumPages();
							  window[instance].document.dimensions = pageRenderer.getDimensions();
							  window[instance].show();

                              jQuery(root).trigger('onDocumentLoaded',pageRenderer.getNumPages());
						});					
					});
				});
			}else{
				// fail #2.1 custom content inside container
				if (!root.innerHTML.replace(/\s/g, '')) {
					var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://");
					
					root.innerHTML = 
						"<h2>Your browser is not compatible with FlexPaper</h2>" + 
						"<h3>Upgrade to a newer browser or download Adobe Flash Player 10 or higher.</h3>" + 
						"<p>Click on the icon below to download the latest version of Adobe Flash" + 
						"<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
											+ pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>";
																							
					if (root.tagName == 'A') {	
						root.onclick = function() {
							location.href = URL;
						};
					}				
				}
				
				// onFail
				if (opts.onFail) {
					var ret = opts.onFail.call(this);
					if (typeof ret == 'string') { root.innerHTML = ret; }	
				}		
			}	
		}
		
		// http://flowplayer.org/forum/8/18186#post-18593
		if (IE) {
			window[opts.id] = document.getElementById(opts.id);
		} 
		
		// API methods for callback
		extend(this, {
				
			getRoot: function() {
				return root;	
			},
			
			getOptions: function() {
				return opts;	
			},

			
			getConf: function() {
				return conf;	
			}, 
			
			getApi: function() {
				return root.firstChild;	
			}
			
		}); 
	}

	// setup jquery support
	if (JQUERY) {
		jQuery.fn.flashembed = function(opts, conf) {
			return this.each(function() { 
				jQuery(this).data("flashembed", flashembed(this, opts, conf));
			});
		};

        jQuery.fn.FlexPaperViewer = function(args){
            var embed = new FlexPaperViewerEmbedding(this.attr('id'),args);
            this.element = jQuery('#'+embed.id);
            return this.element;
        };
	}else{
        throw new Error("jQuery missing!");
    }
})();