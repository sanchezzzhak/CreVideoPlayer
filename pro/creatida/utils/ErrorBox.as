package pro.creatida.utils 
{
	import flash.display.Sprite;
	import flash.text.*;
	
	/**
	 * Вывод ошибок
	 */
	public class ErrorBox extends Sprite  
	{
		
		public var field:TextField;
		public var bg_color:uint = 0x000000;
		public var text_color:uint = 0xFFFFFF;
		
		public function ErrorBox():void 
		{
			this.visible = false;
			this.name = 'error_box';
			this.field = new TextField;
			this.field.wordWrap = true;
			this.addChild(this.field);
			this.draw();

		}
			
		public function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(this.bg_color,1);
			this.graphics.drawRoundRect(0, 0, 320, 120 , 4,4);
			this.graphics.endFill();
			
			this.field.x = this.field.y = 10;
			this.field.textColor = this.text_color;
		}
		
		/**
		 * Ресайз вывода ошибок
		 * @param	_width
		 * @param	_height
		 */
		public function resize(_width:Number , _height:Number ):void 
		{
			var ratio:Number = this.width / this.height;
			this.x = ((_width / 2) - (this.width / 2));
			this.y = ((_height / 2) - (this.height / 2));
			
			this.draw();
		}
		
		/**
		 * Показать ошибку 
		 * @param	error_text
		 */
		public function error(error_text:String):void 
		{
			this.field.text = error_text;
			this.visible = true;
		}
		
		
	}
	
	
	
	
	
}