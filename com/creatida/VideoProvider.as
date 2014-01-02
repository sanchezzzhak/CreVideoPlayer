package com.creatida
{

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;	
	import com.creatida.MediaBase;
	
	/* Обычное видео */
	public class VideoProvider extends MediaBase 
	{
		
		public var client:Object  = new Object();
		public var meta:Object    = null;
		
		public var nc:NetConnection;           // Конект
		public var ns:NetStream;               // Стрим
		
		public var vid:Video;				   // Видео
		public var snd:SoundTransform;         // Звук
		
		
		public function VideoProvider():void
		{
			super("video");
			this.initProvider();
		}
		
		override public function initProvider():void
		{
			this.client.onMetaData = this.onMetaData;
			this.snd = new SoundTransform();
			this.nc  = new NetConnection();
			this.nc.connect(null);
			
			this.ns=new NetStream(this.nc);
			this.ns.client= this.client;
			
			this.vid = new Video(320,240);
			this.vid.attachNetStream(this.ns);
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * 
		 * @return
		 */
		public function display():DisplayObject
		{
			return this.vid;
		}
		
		/* Мут */
		override public function mute(_arg1:Boolean):void
		{
			(_arg1 == true)?(this.snd.volume = 0) : (this.snd.volume = 1);
			this.ns.soundTransform = this.snd;
		}
		

		
		/* Стоп */
		override public function stop():void
		{
			if (this.ns.bytesLoaded < this.ns.bytesTotal){
                this.ns.close();
            } else {
                this.ns.pause();
                this.ns.seek(0);
            };
			
			this.pos=0;	
			super.stop();
			
		}
		
		/* Плей */
		override public function play():void
		{
			this.ns.togglePause();
			super.play();
			
		}
		
		/* Пауза */
		override public function pause():void
		{
			this.pos=ns.time;
			this.ns.pause();
			super.pause();
		}
		
		/* позиция в кадре */
		override public function getPosition():Number{
			return this.pos;
		} 
		
		override public function load(url:String):void
		{
			this.meta=null;
			this.ns.play(url);
			this.vid.visible=true;
		}
		
		/**
		 * 
		 * @param	obj
		 */
		public function onMetaData(obj:Object):void
		{
			this.meta=obj;
			 if (this.meta.width){
                this.resize(this.meta.width, this.meta.height);
				
				if (((obj.duration) && ((obj.duration < 1)))){
					trace('ААА ');
					trace(obj.duration);
					//this.pos = obj.duration;
				}
			}
			
		}
		
		/**
		 * Установить звук  +/- 
		 * @param	_arg1
		 **/
		override public function setVolume(_arg1:Number):void
		{
			this.snd.volume=  Math.min(Math.max(0, _arg1), 100);
			this.ns.soundTransform = this.snd;
		}
		
		/**
		 * 
		 * @return
		 **/
		public function getSoundVolume():Number
		{
			return this.snd.volume;
		}
		
		/* ресайз видео */
		public function resize(_arg1:Number, _arg2:Number):void
		{
			this.vid.width  = _arg1;
			this.vid.height = _arg2;
			
		}
		
	}
	
}