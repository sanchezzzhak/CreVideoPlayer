/*
* Пекедж система плагинов 
*
*/
package pro.creatida 
{
	
	import flash.events.*;
	import flash.display.*;
    import flash.utils.*;
	
	import pro.creatida.utils.*;
	
	
	
	public class PluginLoader extends EventDispatcher 
	{
		
		
		public  var plugins:Object;                 // Список плагинов
        private var loaders:Dictionary,             
        private var errorState:Boolean = false;      
		
		/**/
		public function PluginLoader():void
		{
			this.loaders = new Dictionary();
			this.plugins = {};   
		}
		
		/* 
			Загрузчик плагинов 
			@var _arg1  список плагинов через разделитель запятую, которые нужно загрузить 
		*/
		public function loadPlugins(_arg1:String):void
		{
			var _arr_plugins:Array;
            if (_arg1)
			{
                _arr_plugins = _arg1.replace(/\s*/g, "").split(",");
				var plugin_name:String;
                for each (plugin_name in _arr_plugins)
				{
                    if (plugin_name)
					{
                        this.loadPlugin(plugin_name);
                    };
                };
            }
			else 
			{
                dispatchEvent(new Event(Event.COMPLETE));
            };
		}
		
		/* Загрузка swf плагина и иницилизация */
		private function loadPlugin(_arg1:String):void
		{
			var _asset:AssetLoader;
			if ((((_arg1.indexOf("/") >= 0)) || (_arg1.indexOf(".swf"))))
			{
				_asset = new AssetLoader();
				_asset.addEventListener(Event.COMPLETE, this.loadSuccess);
                _asset.addEventListener(ErrorEvent.ERROR, this.pluginLoadFailed);
                this.loaders[ _asset ] = _arg1;
                _asset.load(_arg1);
			}
		}

		private function pluginLoadFailed(_arg1:ErrorEvent):void{
            this.errorState = true;
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Error loading plugin: Plugin file not found"));
        }
		
		
		private function loadSuccess(_arg1:Event):void{
            var _asset:AssetLoader = (_arg1.target as AssetLoader);
            var plugin_path:String = (this.loaders[_asset] as String);
            var plugin_name:String = plugin_path.substr((plugin_path.lastIndexOf("/") + 1)).replace(/(.*)\.swf$/i, "$1").split("-")[0];
            this.plugins[plugin_name] = (_asset.loadedObject as DisplayObject);
            _asset.removeEventListener(Event.COMPLETE, this.loadSuccess);
            delete this.loaders[_asset];
            this.checkComplete();
        }
		
        private function checkComplete():void{
            var plugin_name:String;
            if (this.errorState){
                return;
            };
            var _is_complete:Boolean;
            for each (plugin_name in this.loaders) {
                _is_complete = true;
            };
            if (!_is_complete){
                dispatchEvent(new Event(Event.COMPLETE));
            };
        }
		
		
	}
	
}