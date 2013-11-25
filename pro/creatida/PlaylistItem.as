package pro.creatida 
{
	/* Динамический класс реализует item для PlayList класса */
	public dynamic class PlaylistItem  
	{
		public var desc:String   = "";       // Описание
		public var poster:String = "";       // Картинка для пред. показа
		public var file:String   = "";       // URL на файл
		public var type:String   = "";       
		public var title:String  = "";       // Заголовок
		
		public var date:String  = "";      
		public var time:String  = "";  
		
		public var index:Number = 0;
		public var duration:Number = 0;      // Длит в секундах
		public var start:Number = 0; 
		
	}

	
} 