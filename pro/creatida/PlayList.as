package pro.creatida 
{
	import flash.utils.*;
	import pro.creatida.PlayListItem;

	public class PlayList
	{
		
		public static var play_auto_id:Number = 0;
		
		public var list:Array;
		public var index:Number;
	
		public function PlayList():void
		{
			this.list = [];
            this.index = 0;	
		}
		
		/* След трек от текущего */
		public function getNextItem():PlayListItem
		{
			return this.getItemAt(this.index+1);
		}
		
		/* Вернуть по номеру item из плейлиста */
		public function getItemAt(_arg1:Number):PlayListItem{
			try {
				return this.list[_arg1];
			}
			catch(e:Error){};
			
			return (null);
		}
		
		
		/* Добавить в PlayList */
		public function insert(_arg1:PlayListItem):void
		{
			_arg1.auto_id = PlayList.play_auto_id++;
			_arg1.index  = this.list.length;
			
			this.list.push(_arg1);
			trace(_arg1.auto_id);
		}
		
		public function currentPlayItem():PlayListItem
		{
			return this.list[this.index];
		}
		
	}
	
	
}