package pro.creatida
{	
	import flash.media.Video;
	
	
	public dynamic class NetClient {

        private var callback:Object;

        public function NetClient(_arg1:Object):void{
            this.callback = _arg1;
        }
        private function forward(_arg1:Object, _arg2:String):void{
            var _local4:Object;
            _arg1["type"] = _arg2;
            var _local3:Object = new Object();
            for (_local4 in _arg1) {
                _local3[_local4] = _arg1[_local4];
            };
            this.callback.onClientData(_local3);
        }
        public function close(... _args):void{
            this.forward({close:true}, "complete");
        }
        public function onFCSubscribe(_arg1:Object):void{
            this.forward(_arg1, "fcsubscribe");
        }
		
		public function onBWDone(... _args):void{
			trace('onBWDone event');
        }
		
		public function onCuePoint(info:Object):void {
			trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		
        public function onMetaData(_arg1:Object, ... _args):void{
            if (((_args) && ((_args.length > 0)))){
                _args.splice(0, 0, _arg1);
                this.forward({arguments:_args}, "metadata");
            } else {
                this.forward(_arg1, "metadata");
            };
        }
		

		
		
        public function onPlayStatus(... _args):void{
            var _local2:Object;
            for each (_local2 in _args) {
                if (((_local2) && (_local2.hasOwnProperty("code")))){
                    if (_local2.code == "NetStream.Play.Complete"){
                        this.forward(_local2, "complete");
                    } else {
                        if (_local2.code == "NetStream.Play.TransitionComplete"){
                            this.forward(_local2, "transition");
                        };
                    };
                };
            };
        }
        public function onTextData(_arg1:Object):void{
            this.forward(_arg1, "textdata");
        }

    }
}