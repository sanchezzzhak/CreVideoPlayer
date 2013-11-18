
package pro.creatida {
	
	import flash.external.*;
	public class JsAPI {
		
		
		public function JsAPI():void
		{
		}
		
		public static function console(_arg1):void
		{
			if((ExternalInterface.available))
				ExternalInterface.call("console.log",_arg1);
		}

		
	}
}