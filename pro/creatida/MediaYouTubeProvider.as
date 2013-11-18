package pro.creatida { 

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	
	import pro.creatida.MediaBase;
	import pro.creatida.PlayerState;
	

	
	
	/* Ютубище */
	public class MediaYouTubeProvider extends MediaBase{
	
		private var _ytApiUrl:String = "http://www.youtube.com/apiplayer?version=3&modestbranding=1";
		private var _videoId:String = "";
		private var _ready:Boolean = false;
		
		private var bytesLodaed:Number;
		private var bytesTotal:Number;
		private var bytesOffset:Number;
		
		
		public var pos:Number   = 0;                   // Видео позиция 
		public var meta:Object  = null;
		
        public var _ytAPI:Object;
		public var _loader:Loader;
		
		
		public function MediaYouTubeProvider():void
		{
			super("youtube");
			this.initProvider();
		}

		override public function initProvider():void
		{
			
			this._loader = new Loader();
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.apiLoaded);
            this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.loadErrorHandler);
			this._loader.load(new URLRequest(this._ytApiUrl));
		}
		
		private function loadErrorHandler(_arg1:ErrorEvent):void{
            trace(_arg1.text);
        }

		/* Загрузка API */
		private function apiLoaded(_arg1:Event):void{
			this._ytAPI = this._loader.content;
			this._ytAPI.addEventListener("onReady", this.apiReady);
			
			//this._ytAPI.addEventListener("onError", this.onPlayerError);
			//this._ytAPI.addEventListener("onStateChange", this.onStateChange);
			//this._ytAPI.addEventListener("onPlaybackQualityChange", this.onPlaybackQualityChange);
		}
		
		/* Видео готово к просмотру  */
		private function apiReady(_arg1:Event):void{
			this._ready = true;
		}
		
		override public function load(_url:String):void{
			this._videoId = this.getID(_url);
			//this._ytAPI.cueVideoById(this._videoId, 0, "default");
			this._ytAPI.loadVideoById(this._videoId, 0, "default");
			
		}
		
		/* Плей */
		override public function play():void{
            if (this._ready){
                this._ytAPI.playVideo();
            };
        }
		
		/* Пауза */
		override public function pause():void
		{
			//if ((((state == PlayerState.PLAYING)) || ((state == PlayerState.BUFFERING)))){
                if (this._ready){
                    this._ytAPI.pauseVideo();
                };
                super.pause();
            //};
		}
		
		/* Ресайз видео 
		* @var _arg1 ширина 
		* @var _arg2 высота 	
		*/
		public function resize(_arg1:Number, _arg2:Number):void{
            if (this._ready){
                this._ytAPI.setSize(_arg1, _arg2);
            };
        }
		
		
		/* позиция в кадре */
		override public function getPosition():Number{
			return 0;
		} 
		
		override public function seek(_arg1:Number):void{
            if (this._ready){
                this._ytAPI.seekTo(_arg1, true);
                this.pos = _arg1;
                super.seek(_arg1);
                this.play();
            };
        }
        override public function stop():void{
            if (this._ready){
                if (this._ytAPI.getPlayerState() > 0){
                    this._ytAPI.stopVideo();
                };
            };
            //this._statusTimer.stop();
            this.pos = 0;
            super.stop();
        }
		
        override public function setVolume(_arg1:Number):void{
            if (this._ready){
                this._ytAPI.setVolume(Math.min(Math.max(0, _arg1), 100));
            };
            super.setVolume(_arg1);
        }
		
		
		public function onMeta(obj:Object):void
		{
			this.meta=obj;
		}
		
		/* YouTubeAPI GET video ID by URL */
		public function getID(_arg1:String):String {
            var _local4:String;
            var _local2:Array = _arg1.split(/\?|\#\!/);
            var _local3 = "";
            for (_local4 in _local2) {
                if (_local2[_local4].substr(0, 2) == "v="){
                    _local3 = _local2[_local4].substr(2);
                };
            };
            if (_local3 == ""){
                if (_arg1.indexOf("/v/") >= 0){
                    _local3 = _arg1.substr((_arg1.indexOf("/v/") + 3));
                } else {
                    if (_arg1.indexOf("youtu.be") >= 0){
                        _local3 = _arg1.substr((_arg1.indexOf("youtu.be/") + 9));
                    } else {
                        _local3 = _arg1;
                    };
                };
            };
            if (_local3.indexOf("?") > -1){
                _local3 = _local3.substr(0, _local3.indexOf("?"));
            };
            if (_local3.indexOf("&") > -1){
                _local3 = _local3.substr(0, _local3.indexOf("&"));
            };
            return (_local3);
        }
		
		
		
		

	}
}