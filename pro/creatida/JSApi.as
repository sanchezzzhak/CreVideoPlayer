
package pro.creatida {
	
	import flash.external.*;
	public class JsAPI 
	{
		
		/**
		 * 
		 */
		public function JsAPI():void
		{
			
		}
		
		/**
		 * Google DevTools console
		 * @param	_arg1
		 */
		public static function console(_arg1):void
		{
			if ((ExternalInterface.available))
			{
				ExternalInterface.call("console.log",_arg1);
			}	
		}
	}
}