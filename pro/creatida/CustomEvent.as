package pro.creatida  
{
	import flash.events.Event;
	
	
	/* Кастомные события + данные */
	public class CustomEvent extends Event
	{
		public static const RESULT_DATA:String = "EventResultData";
		
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