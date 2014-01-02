	import flash.display.*;
	import flash.events.*;
	
	
	private var play_btn_press:Sprite = new Sprite;
	private var play_btn_out  :Sprite = new Sprite;
	private var play_btn_over :Sprite = new Sprite;
	private var play_btn:SimpleButton = new SimpleButton;
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
	
	private var center_btn_play:MovieClip = new MovieClip;
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
					loader.x = 0;
					loader.y = 0;
				
				switch(this._loader_arr[index].name)
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
					//PLAY	
					case 'play_btn_out':
						this.play_btn_out.addChild(loader);
						break;
					case 'play_btn_press':
						this.play_btn_press.addChild(loader);
						break;
					case 'play_btn_over':
						this.play_btn_over.addChild(loader);
						break;
					// PAUSE	
					case 'pause_btn_out':
						this.pause_btn_out.addChild(loader);
						break;
					case 'pause_btn_press':
						this.pause_btn_press.addChild(loader);
						break;
					case 'pause_btn_over':
						this.pause_btn_over.addChild(loader);
						break;	
					// STOP
					case 'stop_btn_out':
						this.stop_btn_out.addChild(loader);
						break;
					case 'stop_btn_press':
						this.stop_btn_press.addChild(loader);
						break;
					case 'stop_btn_over':
						this.stop_btn_over.addChild(loader);
						break;	
						
					
				}
				//this._loader_arr.splice(index);
			}	
		};
	}
	

	
	
	public function xmlSkinParse(assets:XMLList, name_conteiner:String = '' ):void
	{
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
			
			if (name == 'center_btn')
			{
				pushLoader(name + '_play',  asset.@play);
				pushLoader(name + '_pause', asset.@pause);
				continue;
			}
			
			if (name == 'play_btn')
			{
				this.pushLoader(name + '_over',  asset.@over);
				this.pushLoader(name + '_press', asset.@press);
				this.pushLoader(name + '_out', asset.@out);
				
				this.play_btn.name = name;
				this.play_btn.downState    = this.play_btn_press;
				this.play_btn.overState    = this.play_btn_over;
				this.play_btn.upState      = this.play_btn_out;
				this.play_btn.hitTestState = this.play_btn_out;
				
				this.play_btn.addEventListener(MouseEvent.CLICK, this.onPlayBtn);
				
				if (_controls_params[name].hasOwnProperty('conteiner'))
				{
					addChild(this.play_btn);
					//this._conteiners[name].addChild(this.play_btn);
				}else
				{
					
				};
				continue;
			}
			
			if (name == 'pause_btn')
			{
				this.pushLoader(name + '_over',  asset.@over);
				this.pushLoader(name + '_press', asset.@press);
				this.pushLoader(name + '_out', asset.@out);
				
				this.pause_btn.name = name;
				this.pause_btn.downState    = this.pause_btn_press;
				this.pause_btn.overState    = this.pause_btn_over;
				this.pause_btn.upState      = this.pause_btn_out;
				this.pause_btn.hitTestState = this.pause_btn_out;
				
				this.pause_btn.addEventListener(MouseEvent.CLICK, this.onPauseBtn);
				
				if (_controls_params[name].hasOwnProperty('conteiner'))
				{
					addChild(this.pause_btn);
					//this._conteiners[name].addChild(this.play_btn);
				}else
				{
					
				};
				continue;
			}	
			
			
			if (name == 'stop_btn')
			{
				this.pushLoader(name + '_over',  asset.@over);
				this.pushLoader(name + '_press', asset.@press);
				this.pushLoader(name + '_out', asset.@out);
				
				this.stop_btn.name = name;
				this.stop_btn.downState    = this.stop_btn_press;
				this.stop_btn.overState    = this.stop_btn_over;
				this.stop_btn.upState      = this.stop_btn_out;
				this.stop_btn.hitTestState = this.stop_btn_out;
				
				this.stop_btn.addEventListener(MouseEvent.CLICK, this.onStopBtn);
				
				if (_controls_params[name].hasOwnProperty('conteiner'))
				{
					addChild(this.pause_btn);
					//this._conteiners[name].addChild(this.play_btn);
				}else
				{
					
				};
				continue;
			}
			
			
		}
		
	}
	
	