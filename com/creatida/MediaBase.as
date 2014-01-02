
package com.creatida {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	
	/* Базовая модель */
	public class MediaBase extends Sprite{
		
		public var name_provider:String;                 // Имя провайдера
		public var state:String;                         // Состояние плеира
		public var pos:Number = 0;                       // Начало позиции 
		public var _offest:Number = 0;
		
		public function MediaBase(provider:String):void
		{
			this.setState(PlayerState.IDLE);
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
		
		public function initProvider():void {

		}
		public function load(_url:String):void {
			this.setState(PlayerState.BUFFERING);
		}
		public function play():void {
			this.setState(PlayerState.PLAYING);
		}
		public function pause():void {
			this.setState(PlayerState.PAUSED);
		}
		public function stop():void{
			this.setState(PlayerState.IDLE);
		}
		public function setVolume(_arg1:Number):void{}
		public function seek(arg1:Number):void{
			this._offest = arg1;
		}
		public function mute(arg1:Boolean):void{}
		public function getPosition():Number{ return this.pos;} 

		
		
	}
}