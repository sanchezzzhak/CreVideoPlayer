package pro.creatida 
{
	import pro.creatida.PlayList;
	
	/* Динамический класс реализует item для PlayList класса */
	public dynamic class PlayListItem  
	{
		public var auto_id:Number = 0;
		public var poster:String = "";                   // Картинка для пред. показа
		public var desc:String   = "";                   // Описание
		
		public var file:String   = "";                   // URL на файл
		public var type:String   = "";       
		public var title:String  = "";                   // Заголовок
		
 	
		
		public var index:Number    = 0;
		public var duration:Number = 0;                 // Длит в секундах
		public var start:Number    = 0; 
		
		public var quality_levels :Array;                    // Массив качества 
		public var reclame_list   :PlayList = new PlayList;  // tv Список роликов рекламы
		public var date:String   = "";                   // tv Дата показа
		public var time:String   = "";  				 // tv время показа 
		
	}

	
} 