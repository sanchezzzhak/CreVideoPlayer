package pro.creatida
{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;	
	
	import pro.creatida.MediaBase;
	import pro.creatida.PlayerState;
	import pro.creatida.NetClient;
	
	
	


	public class RTMPProvider extends MediaBase {
		
		
		private var _ns:NetStream;
		private var _nc:NetConnection;
		private var _snd:SoundTransform;
		private var _stream_id:String;
		private var client:Object = new Object();
		private var meta:Object   = null;
		
		public var vid:Video;
		
		
		
		public function RTMPProvider():void
		{
			super("rtmp");
			this.initProvider();
		}

		override public function initProvider():void
		{
			this.client = new NetClient(this);
			
			this._nc = new NetConnection();
			this._nc.client  = this.client;
			

            this._nc.addEventListener(NetStatusEvent.NET_STATUS, this.statusHandler);
            this._nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.errorHandler);
            this._nc.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
            this._nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.errorHandler);
            //this._connection.objectEncoding = ObjectEncoding.AMF0;

			this._snd = new SoundTransform();
			this.vid  = new Video();
		}
		
		

		
		
		override public function load(_arg1:String):void
		{
			    var _local2:Number = _arg1.indexOf("_definst_");
                var _local3:Number = Math.max(_arg1.indexOf("mp4:"), _arg1.indexOf("mp3:"), _arg1.indexOf("flv:"));
                var _local4:Number = _arg1.lastIndexOf("/");
			
                if (_local2 > 0){
                    //this._application = _arg1.substr(0, (_local2 + 10));
                    this._stream_id = _arg1.substr((_local2 + 10));
                } else {
                    if (_local3 > -1){
                        //this._application = _item.file.substr(0, _local3);
                        this._stream_id = _arg1.substr(_local3);
                    } else {
                        //this._application = _item.file.substr(0, (_local4 + 1));
                        this._stream_id = _arg1.substr((_local4 + 1));
                    };
                };
			this._nc.connect(_arg1);
		}
		
		public function setStream():void
		{
			this._ns = new NetStream(this._nc);
			this._ns.client = this.client;
			this.vid.attachNetStream(this._ns);
			this._ns.play(this._stream_id);
		}
		
		
		
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
                case "NetConnection.Connect.Closed":
                    //if (state == PlayerState.PAUSED){
                        this.stop();
                    //};
                    break;
            }
		}
	
		public function errorHandler(_arg1:ErrorEvent):void
		{
            trace(_arg1.text);
        }
		
	
		
		
		public function onClientData(_arg1:Object):void{
			trace(_arg1.type);
            switch (_arg1.type){
                case "metadata":
                   /* if (!this._metadata){
                        this._metadata = true;
                        if (_arg1.duration){
                            _item.duration = _arg1.duration;
                            if (_item.start){
                                this.seek(_item.start);
                            };
                        };
                        if (_arg1.width){
                            this._video.width = _arg1.width;
                            this._video.height = _arg1.height;
                            this.resize(_config.width, _config.height);
                        };
                        _arg1.provider = "rtmp";
                    };*/
                    break;
                case "fcsubscribe":
                    //this.setStream();
                    break;
                case "textdata":
                    _arg1.provider = "rtmp";
                    break;
                case "transition":
                    ///this._transition = false;
                    break;
                case "complete":
                   /* if (state != PlayerState.IDLE){
                        this.stop();
                    };
				   */
                    break;
            };
			trace(_arg1);
        }
		
		
		
		
	}
	
}