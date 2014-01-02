package com.creatida  
{
	import flash.events.Event;
	
	/**
	 * Кастомные события c посылкой данных 
	 * @example 
	 *    // send
	 *    var result_data:Object = { Message: "I'm saying this!", user_id:1 };
	 *    dispatchEvent(new CustomEvent(CustomEvent.RESULT_DATA, result_data));
	 * 
	 * 	  
	 **/
	public class CustomEvent extends Event
	{
		public static const RESULT_DATA:String = "EVENT_RESULT_DATA";
		
		public var data:Object;	
		
		public function CustomEvent(type:String, data: Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public override function clone():Event
		{
			return new CustomEvent(type, data, bubbles, cancelable);
		}
	}

}