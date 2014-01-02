package com.creatida
{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;	
	
	import com.creatida.MediaBase;
	import com.creatida.PlayerState;
	import com.creatida.NetClient;
	

	public class RTMPProvider extends MediaBase {
		
		
		private var _ns:NetStream;
		private var _nc:NetConnection;
		private var _snd:SoundTransform;
		
		private var _stream_id:String;
		private var _host:String;
		
		private var client:Object = new Object();
		private var meta:Object   = null;
		
		private var _transition:Boolean;    // трансляция? 
		private var _metadata:Boolean;      // проиницилизирована ли мета?
		private var _interval:Number;
		
		public var vid:Video;
		
		public function RTMPProvider():void
		{
			super("rtmp");
			this.initProvider();
		}

		public function display():DisplayObject
		{
			return this.vid;
		}
		
		
		
		override public function initProvider():void
		{
			this.client = new NetClient(this);
			
			this._nc = new NetConnection();
			this._nc.client  = this.client;
			this._nc.client.bufferTime = 2;
            this._nc.addEventListener(NetStatusEvent.NET_STATUS, this.statusHandler);
            this._nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.errorHandler);
            this._nc.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
            this._nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.errorHandler);
            //this._connection.objectEncoding = ObjectEncoding.AMF0;

			this._snd = new SoundTransform();
			this.vid  = new Video(480, 320); 
			//this.vid.smoothing = true;
			
		}
		
		/* загрузим по URL  поток */
		override public function load(_arg1:String):void
		{
			    var _local2:Number = _arg1.indexOf("_definst_");
                var _local3:Number = Math.max(_arg1.indexOf("mp4:"), _arg1.indexOf("mp3:"), _arg1.indexOf("flv:"));
                var _local4:Number = _arg1.lastIndexOf("/");
			
                if (_local2 > 0){
                    this._host = _arg1.substr(0, (_local2 + 10));
                    this._stream_id = _arg1.substr((_local2 + 10));
                } else {
                    if (_local3 > -1){
                        this._host = _arg1.substr(0, _local3);
                        this._stream_id = _arg1.substr(_local3);
                    } else {
                        this._host = _arg1.substr(0, (_local4 + 1));
                        this._stream_id = _arg1.substr((_local4 + 1));
                    };
                };
			this._nc.connect(this._host);
		}
		
		
		public function setStream():void
		{
			this._ns = new NetStream(this._nc);
			this._ns.addEventListener(NetStatusEvent.NET_STATUS, this.statusHandler);
            this._ns.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
            this._ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.errorHandler);
			this._ns.bufferTime = 2;
			
			this._ns.client = this.client;
			this.vid.attachNetStream(this._ns);
			this._ns.play(this._stream_id);
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/* */
		private function statusHandler(_arg1:NetStatusEvent):void
		{
			 trace("net status handler: " + _arg1.info.code);
			 switch (_arg1.info.code){
				 
                case "NetConnection.Connect.Success":
					this.setStream();
                    break;
                case "NetConnection.Connect.Rejected":
                case "NetConnection.Connect.Failed":
                   
                    break;
                case "NetStream.Seek.Failed":
                case "NetStream.Failed":
                case "NetStream.Play.StreamNotFound":
                    trace("Error loading stream: ID not found on server");
                    break;
                case "NetStream.Play.UnpublishNotify":
                    this.stop();
                    break;
				case "NetStream.Buffer.Full":
					
					break;
                case "NetConnection.Connect.Closed":
                    if (this.state == PlayerState.PAUSED){
                        this.stop();
                    };
                    break;
            } 
		}
	
		override public function seek(_arg1:Number):void{
            if (this.meta.duration > 0){
                if (this.state != PlayerState.PLAYING){
                    this.play();
                };
                this.setState(PlayerState.BUFFERING);
                this._ns.seek(_arg1);
                this._transition = false;
                clearInterval(this._interval);
                this._interval = setInterval(this.onInterval, 100);
            };
        }
		

		public function onInterval():void 
		{

		}
		
		
		override public function play():void
		{
			if (this._metadata)
			{
                if (this.meta.duration > 0)
				{
                    this._ns.resume();
                } 
				else
				{
                    this._ns.play(this._stream_id);
                    setState(PlayerState.BUFFERING);
                };
            }
			else 
			{
                this._ns.play(this._stream_id);
            };
			clearInterval(this._interval);
            this._interval = setInterval(this.onInterval, 100);
			
		}
		

		/** Пауза **/
		override public function pause():void {
			if (this._ns){
                if (this.meta.duration > 0){
                    this._ns.pause();
                } else {
                    this._ns.close();
                };
            };
            clearInterval(this._interval);
			this.setState(PlayerState.PAUSED);
		}
		
		override public function stop():void {
			if ((this._ns.client)){
                this._ns.close();
            };
			this._metadata = false;
			this._nc.close();
			super.stop();
		} 
		
		
		public function getSoundVolume():Number
		{
			return this._snd.volume;
		}
		
		override public function setVolume(_arg1:Number):void{
			trace(_arg1);
			this._snd.volume = _arg1;
            if (this._ns){
                this._ns.soundTransform = this._snd;
            };
            super.setVolume(_arg1);
        }
		
		/* мут */
		override public function mute(_arg1:Boolean):void
		{
			(_arg1==true) ? this.setVolume(0) : this.setVolume(1);
			super.mute(_arg1);
		}
		
		public function errorHandler(_arg1:ErrorEvent):void
		{
            trace(_arg1.text);
        }
		
		public function onClientData(_arg1:Object):void{
            switch (_arg1.type){
                case "metadata":
                    if (!this._metadata){
                        this._metadata = true;
                        if (_arg1.duration){
							trace('duration' , _arg1.duration);
                            this.meta.duration = _arg1.duration;
                            if (this.pos){
                                this.seek(this.pos);
                            }
							
                        };
                        if (_arg1.width){
						
                            this.resize(_arg1.width, _arg1.height);
                        };
                        //_arg1.provider = "rtmp";
                    };
                    break;
                case "fcsubscribe":
                    this.setStream();
                    break;
                case "textdata":
                   // _arg1.provider = "rtmp";
                   
                    break;
                case "transition":
                    this._transition = false;
                    break;
                case "complete":
					/*
                    if (this.state != PlayerState.IDLE){
                        this.stop();
                    };
					*/
                    break;
            };
        }

		
		/* ресайз размера видео */
		public function resize(_arg1:Number, _arg2:Number):void{
			this.vid.width  = _arg1;
            this.vid.height = _arg2;
		}
		
		
	}
	
}