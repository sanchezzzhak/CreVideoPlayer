package pro.creatida  
{
	import flash.events.Event;
	
	/* Кастомные события */
	public class CustomEvent extends Event
	{
		public var data: Object;	
		
		
		
		public function CustomEvent(type:String, data: Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		
		
		
	}
	
	
	
}