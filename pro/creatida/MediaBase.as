
package pro.creatida {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	import pro.creatida.PlaylistItem;
	
	/* Базовая модель */
	public class MediaBase extends Sprite{
		
		public var name_provider:String;                 // Имя провайдера
		public var state:String;                         // Состояние плеира
		public var pos:Number = 0;                       // Начало позиции 
		
		public function MediaBase(provider:String):void
		{
			this.name_provider = provider;
			this.initProvider();
		}
		
		public function setState(_arg1:String):void
		{
			this.state = _arg1;
		}
		

		public function get provider():String
		{
			return (this.name_provider);
		}
		
		public function set provider(_arg1:String):void
		{
			this.name_provider = _arg1;
		}
		
		public function initProvider():void{}
		public function load(_url:String):void{}
		public function play():void{}
		public function pause():void{}
		public function stop():void{}
		public function setVolume(_arg1:Number):void{}
		public function seek(arg1:Number):void{}
		public function mute(arg1:Boolean):void{}
		public function getPosition():Number{ return this.pos;} 
		

	}
}