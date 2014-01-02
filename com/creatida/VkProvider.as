package com.creatida 
{
	import flash.display.Sprite;
	import flash.net.*;
	import flash.events.*;
	/**
	 * ...
	 * @author Tutik Alexsadr
	 */
	public class VkProvider extends VideoProvider
	{
		
		private var _ready:Boolean = false;
		private var _url:String;
		
		/**
		 * 
		 */
		public function VkProvider() :void
		{
			this.name = 'vk';
			this.initProvider();
		}
		
		/**
		 * 
		 * @param	url
		 */
		override public function load(url:String):void
		{
			this.meta = null;
			this.getVideoUrl(url);
			this.vid.visible = true;
			while (true)
			{
				if (this._ready == true)
				{
					this.ns.play(this._url);
					break;
				}
				
			}
			
		}
		
		/**
		 * 
		 * @param	_url
		 */
		public function getVideoUrl(url:String):void
		{
			var loader:URLLoader  = new URLLoader;
				loader.addEventListener(Event.COMPLETE, this.getVideoUrlComplite);
				loader.load(new URLRequest(url));	
		}
		
		/**
		 * 
		 * @param	e
		 */
		private function getVideoUrlComplite(e:Event):void 
		{
			var page =  e.target.data;
			var finder:RegExp  = /name=\"flashvars\"\s+value=\"(?P<flashvars>.*)\"/gi
			var result:Array = finder.exec(page);

			var flashvars:String = (result.flashvars || "").replace(/\&amp\;/gi, '&');
			var varUrl:URLVariables = new URLVariables(flashvars);
			VideoPlayer.dump(varUrl);
			
			this._url = varUrl.url360;
						// url240
						// url360
						// url480 
						// url720
			
			this._ready = true;
			
		}
	
	}
	
}