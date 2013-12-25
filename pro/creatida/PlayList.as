package pro.creatida 
{
	import flash.utils.*;
	import pro.creatida.PlaylistItem;
	
	public class PlayList
	{
		public var list:Array;
		public var index:Number;
	
		public function PlayList():void
		{
			this.list = [];
            this.index = 0;	
		}
		
		/* След трек от текущего */
		public function getNextItem():PlaylistItem
		{
			return this.getItemAt(this.index+1);
		}
		
		/* Вернуть по номеру item из плейлиста */
		public function getItemAt(_arg1:Number):PlaylistItem{
			try {
				return this.list[_arg1];
			}
			catch(e:Error){};
			
			return (null);
		}
		
		
		/* Добавить в PlayList */
		public function insert(_arg1:PlaylistItem):void
		{
			_arg1.index  = this.list.length;
			this.list.push(_arg1);
		}
		
		public function currentPlayItem():PlaylistItem
		{
			return this.list[this.index];
		}
		
	}
	
	
}