package pro.creatida 
{
	import flash.display.*;
	import flash.utils.*;
	import flash.events.*;
	
	import pro.creatida.PlayList;
	
	/**
	* ТВ Режим для плеира
	*/
	public class TvMode extends EventDispatcher
	{
		public static const NextVideo:String   = "apiNextVideo";
		public static const CurrentPlay:String = "apiGetCurrentPlay";
		public static const GetPlayList:String = "apiGetPlayList";
		
		public static const TvModeCheck:String = "apiTvModeCheck";  // use
		
		
		
		private var _timer_tick:uint = 0; 
		private var _timer:Timer;            
		private var _datetime:Date;          // Серверное время
		
		public function TvMode():void
		{
			this._timer = new Timer(1000);
			this._datetime = new Date;	
			this._timer.addEventListener(TimerEvent.TIMER, this.onTick);	
		}
		
		/* Устанавливает время и запускает таймер */
		public function setDateTime(Year:Number, Month:Number, Day:Number, Hour:Number, Minute:Number, Second:Number):void
		{
			this._datetime.setFullYear(Year, Month, Day);
			this._datetime.setHours(Hour, Minute ,Second);
			this._timer.start();
		}
		
		/* переключится на след. видео если время норм */
		public function onTick(e:TimerEvent):void
		{
			this._datetime.time+=1000;
			if(this._timer_tick==3){
				dispatchEvent(new Event(TvMode.TvModeCheck));
				this._timer_tick = 0;
			}
			this._timer_tick++;
		}
		
		/* дата и время серверного времени */
		public function getServerDate():Date
		{
			return this._datetime;
		}

		
	}
	
	
	
}