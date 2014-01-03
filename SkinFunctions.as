	import flash.display.*;
	import flash.events.*;
	
	private var play_btn_press:Sprite = new Sprite;
	private var play_btn_out  :Sprite = new Sprite;
	private var play_btn_over :Sprite = new Sprite;
	private var play_btn:SimpleButton = new SimpleButton;
	
	private var logo:MovieClip = new MovieClip;
	
	
	/**
	 * 
	 * @param	e
	 */
	private function onPlayBtn(e:Event):void 
	{
		switch(e.type)
		{
			case MouseEvent.CLICK:
				break
			case MouseEvent.MOUSE_OUT:
				break
			case MouseEvent.MOUSE_OVER:
				break
		}
	}
	
	private var center_btn_play:MovieClip  = new MovieClip;
	private var center_btn_pause:MovieClip = new MovieClip;
	/**
	 * 
	 * @param	e
	 */
	private function onCenterPlay(e:Event):void
	{
		trace('onCenterPlay event')
		switch(e.type)
		{
			case MouseEvent.CLICK:
				break
			case MouseEvent.MOUSE_OUT:
				break
			case MouseEvent.MOUSE_OVER:
				break
		}
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onCenterPause(e:Event):void
	{
		switch(e.type)
		{
			case MouseEvent.CLICK:
				break
			case MouseEvent.MOUSE_OUT:
				break
			case MouseEvent.MOUSE_OVER:
				break
		}
	}
	
	private var pause_btn_press:Sprite = new Sprite;
	private var pause_btn_out:Sprite   = new Sprite;
	private var pause_btn_over:Sprite  = new Sprite;
	private var pause_btn:SimpleButton = new SimpleButton;
	/**
	 * 
	 * @param	e
	 */
	private function onPauseBtn(e:Event):void
	{
		switch(e.type)
		{
			case MouseEvent.CLICK:
				break
			case MouseEvent.MOUSE_OUT:
				break
			case MouseEvent.MOUSE_OVER:
				break
		}
	}
	
	private var stop_btn_press:Sprite = new Sprite;
	private var stop_btn_out:Sprite   = new Sprite;
	private var stop_btn_over:Sprite  = new Sprite;
	private var stop_btn:SimpleButton = new SimpleButton;
	/**
	 * 
	 * @param	e
	 */
	private function onStopBtn(e:Event):void
	{
		switch(e.type)
		{
			case MouseEvent.CLICK:
				break
			case MouseEvent.MOUSE_OUT:
				break
			case MouseEvent.MOUSE_OVER:
				break
		}
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function skinLoaderComplite(e:Event):void 
	{
		for (var index = 0, loader_length = this._loader_arr.length;  index < loader_length; index++)
		{
			if (this._loader_arr[index].name == e.target.loader.name)
			{
				trace('asset loader ', this._loader_arr[index].name );
				this._loader_arr[index].is_load = true;
				
				var loader:Loader = e.target.loader as Loader; 	
				var name:String = this._loader_arr[index].name;
				switch(name)
				{
					case 'center_btn_play':
						loader.width  = this._controls_params.center_btn.width;
						loader.height = this._controls_params.center_btn.height;
						this.center_btn_play.addChild(loader);
						
						this._controlLayer.addChild(this.center_btn_play);
						this.center_btn_play.addEventListener(
							MouseEvent.CLICK, 
							this.onCenterPlay
						);
						this.center_btn_play.addEventListener(
							MouseEvent.MOUSE_OVER,
							this.onCenterPlay
						);
						this.center_btn_play.addEventListener(
							MouseEvent.MOUSE_OUT,
							this.onCenterPlay
						);	
						break;
						
					case 'center_btn_pause':
						loader.width  = this._controls_params.center_btn.width;
						loader.height = this._controls_params.center_btn.height;
						this.center_btn_pause.addChild(loader);
						this._controlLayer.addChild(this.center_btn_pause);
						this.center_btn_pause.visible = false;
						this.center_btn_pause.addEventListener(
							MouseEvent.CLICK, 
							this.onCenterPause
						);
						this.center_btn_pause.addEventListener(
							MouseEvent.MOUSE_OVER,
							this.onCenterPause
						);
						this.center_btn_pause.addEventListener(
							MouseEvent.MOUSE_OUT,
							this.onCenterPause
						);
						break;
						
					// PLAY	
					case 'play_btn_out':
					case 'play_btn_press':
					case 'play_btn_over':
						
					// PAUSE	
					case 'pause_btn_out':
					case 'pause_btn_press':
					case 'pause_btn_over':

					// STOP
					case 'stop_btn_out':
					case 'stop_btn_press':
					case 'stop_btn_over':
						this.prop(name).addChild(loader);
					break;
						
					case 'logo':
						this.prop(name).addChild(loader);
					break;
						
					
				}
				//this._loader_arr.splice(index);
			}	
		};
	}
	
	public function xmlSkinParse(assets:XMLList, name_conteiner:String = '' ):void
	{
		var default_btn:Array = new Array('play_btn','pause_btn','stop_btn');

		for each (var asset in assets)
		{
			var name:String = asset.name().toString();
			var attr_arr:Array = new Array;	
			for each (var attr : XML in asset.attributes())
			{
				attr_arr[ attr.name().toString() ] =  attr.valueOf();
			}
			if ( name_conteiner.length  > 0 )
			{
				attr_arr['conteiner'] = name_conteiner;
			}
			
			this._controls_params[name] = attr_arr;
			
			// Прелойдер
			if (name == 'preloader')
			{
				this.loadPreloader(asset.@src);
				continue;
			}
			
			if (name == 'conteiner')
			{
				var mc_conteiner:MovieClip = new MovieClip;
					mc_conteiner.name = asset.@name;
					this._conteiners[name] = mc_conteiner;
					
				var asset_childrs:XMLList = asset.children();
					if ( asset_childrs.length() > 0 )
					{
						this.xmlSkinParse( asset_childrs , asset.@name);
					}
				continue;
			}
			
			// кнопка по центру 
			if (name == 'center_btn')
			{
				pushLoader(name + '_play',  asset.@play);
				pushLoader(name + '_pause', asset.@pause);
				
				continue;
			}
			
			// Кнопки 
			if (this.in_array(name, default_btn) && this.has(name) )
			{
				this.pushLoader(name + '_over',  asset.@over);
				this.pushLoader(name + '_press', asset.@press);
				this.pushLoader(name + '_out', asset.@out);

				this.prop(name).name = name;
				this.prop(name).downState    = this.prop(name + '_press');
				this.prop(name).overState    = this.prop(name + '_over');
				this.prop(name).upState      = this.prop(name + '_out');
				this.prop(name).hitTestState = this.prop(name + '_out');
				
				this.setSkinParams( this.prop(name) ,this._controls_params[name]);
				//this.prop(name).addEventListener(MouseEvent.CLICK, this.onPlayBtn);
				if (this._controls_params[name].hasOwnProperty('conteiner'))
				{
					addChild( this.prop(name) );
					//this._conteiners[name].addChild(this.play_btn);
				}else
				{
					//this._controlerLayer.addChild( this.prop(name) );
					
				};
				continue;
			}
			
		}
		
	}
	
	/**
	 * 
	 * @param	obj
	 * @param	attr
	 */
	public function setSkinParams(obj, attr:Array):void
	{
		if (attr.hasOwnProperty('width')) {  
			obj.width = attr.width; 
		}
		if (attr.hasOwnProperty('height')) { 
			obj.height = attr.height;
		}
		if (attr.hasOwnProperty('x')) {
			obj.x = attr.x;
		}
		if (attr.hasOwnProperty('y')) {
			obj.y = attr.y;
		}
	}
	
	/**
	 * Проверка если свойство или функция 
	 * @param	prop
	 */
	public function has(prop:String):Boolean { 
		try 
		{ 
			this[prop] 
			return true; 
		} catch (e:Error){};
		
		return false; 
	} 
	
	/**
	 * Возрашяет свойство или функцию
	 * @param	name
	 */
	public function prop(name:String) { 
		return this[name];
	} 
	
	/**
	 * 
	 * @param	needle
	 * @param	haystack
	 * @return
	 */
	public function in_array( needle:*, haystack:Array ):Boolean {
		return ( haystack.indexOf(needle) != -1) ? true : false;
	} 
	
	