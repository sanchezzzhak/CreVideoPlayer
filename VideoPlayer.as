package
{
	
	

	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.events.ContextMenuEvent;
	
	
	import flash.system.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.xml.*;
	
	import flash.text.TextField;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.sampler.Sample;
	
	import flash.geom.Rectangle;
	import com.greensock.*;
	import pro.creatida.*;
	import pro.creatida.utils.ErrorBox;
	
	public class VideoPlayer extends Sprite
	{
		
		private var _plugins:Object; // Плагины
		private var _playlist:PlayList; // Плейлист
		
		private var _imageLayer:Sprite; // Для картинок
		private var _mediaLayer:Sprite; // Видео
		private var _controlLayer:Sprite; // Для контроллеров
		private var _adriverLayer:Sprite; // Реклама adSenseGoogle
		
		private var _preloader:MovieClip; // Прелойдер
		
		private var _error_box: ErrorBox;
		
		
		
		private var _provider:Object; // Видео провайдер 
		private var _tvMode:TvMode; // ТВ Режим
		
		private var _isTvMode:Boolean = true; // Включен ли тв режим
		private var _autoPlay:Boolean = true; // Автоплей
		
		private var meta = null;
		private var time:Timer;
		
		private var slideTimer:Timer;
		private var nameTimer:Timer;
		
		/* Base init */
		public function VideoPlayer()
		{
			this.initLayers();
			this._playlist = new PlayList;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			Security.allowDomain('*');
			
			var url:String = './videos.xml';
			
			if (stage.loaderInfo.parameters.hasOwnProperty('file'))
			{
				url = root.loaderInfo.parameters.file;
				if (root.loaderInfo.parameters.hasOwnProperty('autoplay'))
				{
					this._autoPlay = root.loaderInfo.parameters.autoplay == 'true' ? true : false;
				}
			}
			if (stage.loaderInfo.parameters.hasOwnProperty('tvmode'))
			{
				this._isTvMode = root.loaderInfo.parameters.tvmode == 'true' ? true : false;
			}
			
			// скин
			var skin_url:String = './skin.xml';
			var skinLoader:URLLoader;
			if (stage.loaderInfo.parameters.hasOwnProperty('skin'))
			{
				skin_url = root.loaderInfo.parameters.skin;
				skinLoader = new URLLoader(new URLRequest(skin_url));
				skinLoader.addEventListener(Event.COMPLETE, this.xmlLoadSkin);
			}
			else
			{
				skinLoader = new URLLoader(new URLRequest(skin_url));
				skinLoader.addEventListener(Event.COMPLETE, this.xmlLoadSkin);
			}
			
			var extension:String = url.substring(url.lastIndexOf(".") + 1, url.length);
			switch (extension)
			{
				case 'mov': 
				case 'flv': 
				case 'mp4': 
					var playItem:PlaylistItem = new PlaylistItem;
					playItem.file = url;
					this._playlist.insert(playItem);
					break;
				case 'xml': 
				default: 
					//url+= '?r=' +new Date().getTime();
					var xmlLoader:URLLoader = new URLLoader(new URLRequest(url));
					xmlLoader.addEventListener(Event.COMPLETE, this.xmlLoadPlayList);
					break;
			
			}
			;
			panelMc.playBtn.visible = true;
			panelMc.pauseBtn.visible = false;
		
		}
		
		/**
		 * init Layers and Controlls VideoPlayer
		 */
		public function initLayers():void
		{
			
			this._controlLayer = new Sprite;
			this._controlLayer.name = 'control_layer';
			
			this._mediaLayer = new Sprite();
			this._mediaLayer.name = 'media_layer';
			this._mediaLayer.x = 0;
			this._mediaLayer.y = 0;
			
			/*
			this._pluginLayer = new Sprite;
			this._pluginLayer.name = 'plugin_layer';
			this._pluginLayer.visible = false;
			*/
			
			this._adriverLayer = new Sprite;
			this._adriverLayer.name = 'adriver_layer';
			this._adriverLayer.visible = false;
			
			this._error_box = new ErrorBox;
			addChildAt(this._mediaLayer,0);    // 0
			addChildAt(this._controlLayer,1);  // 1
			//addChild(this._pluginLayer); 
			addChildAt(this._adriverLayer,2); 
			
			addChildAt(this._error_box, 3);
			
		}
		
		
		
		/**
		 * Callback load preloader
		 * @param	_arg1
		 */
		private function preloaderLoaded(_arg1:Event):void
		{
			this._preloader = new MovieClip();
			this._preloader.addChild(_arg1.target.loader);
			this._preloader.x = ((stage.width / 2) - (this._preloader.width / 2));
			this._preloader.y = ((stage.height / 2) - (this._preloader.height / 2));
			addChildAt(this._preloader, 2);
		}
		
		/**
		 * set swf preloader loading
		 * @param	_arg1
		 */
		private function loadPreloader(_arg1:String):void
		{
			var _loader:Loader;
			_loader = new Loader();
			_loader.load(new URLRequest(_arg1));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.preloaderLoaded);
			// _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,  this.ioErrorHandler2);
		}
		
		/**
		 * Callback Load Skin
		 * @param	e
		 */
		public function xmlLoadSkin(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			
			if (xml.preloader.@src != undefined)
			{
				this.loadPreloader(xml.preloader.@src);
			}
		
		}
		
		private function initMenu()
		{
			var menu:ContextMenu = new ContextMenu;
			menu.hideBuiltInItems();
			/*
			   function (e:ContextMenuEvent){
			   navigateToURL(new URLRequest("http://creatida.kz/crea-video-player")
			 };*/
			//  new ContextMenuItem("© CreaVideo Player").addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,fun1)
			//menu.customItems.push();
			contextMenu = menu;
		}
		
		public function error(text_error:String):void {
			this._error_box.error(text_error);
			this.stopVideo();
		}
		
		
		/**
		 * Callback загрузка PlayList
		 * @param	e
		 */
		private function xmlLoadPlayList(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			var videos:XMLList = xml.videos.children();
			for each (var item in videos)
			{
				var playItem:PlaylistItem = new PlaylistItem;
				playItem.file = item.@url;
				playItem.title = item.@name;
				// для тв режима...
				if (item.@time.length() > 0)
				{
					playItem.time = item.@time;
					playItem.date = item.@date;
				}
				
				var childs:XMLList = item.children();
				for each (var child in childs)
				{
					/* tv рекламнные ролики */
					if (child.name().toString() == 'reclame')
					{
						var reclame_item:PlaylistItem = new PlaylistItem;
						reclame_item.file = child.@url;
						reclame_item.title = child.@name;
						playItem.reclame_list.insert(reclame_item);
					}
				}
				
				this._playlist.insert(playItem);
			}
			
			if (xml.hasOwnProperty('server'))
			{
				this._tvMode = new TvMode;
				this._tvMode.setDateTime(xml.server.datetime.@year, (parseInt(xml.server.datetime.@month) - 1), xml.server.datetime.@day, xml.server.datetime.@hour, xml.server.datetime.@minute, xml.server.datetime.@second);
				this._tvMode.addEventListener(TvMode.TvModeCheck, tvModeCheck);
			}
			init();
		}
		
		/**
		 * Парсит дату в виде строк и возращяет Date
		 * @param date string  Дата формат Y-m-d
		 * @param time string  Дата формат H:i:s
		 * @return Date
		 */
		private function parseDateStringToDate(date:String, time:String):Date
		{
			var _date:Date = new Date;
			var arrDate:Array = date.split('-');
			var arrTime:Array = time.split(':');
			_date.setFullYear(arrDate[0], parseInt(arrDate[1]) - 1, arrDate[2]);
			_date.setHours(arrTime[0], arrTime[1], 0);
			return _date;
		}
		
		/**
		 * Переключение видео в TV Режиме
		 * @param e DispachEvent
		 */
		public function tvModeCheck(e:Event):void
		{
			if (this._isTvMode == true)
			{
				
				var serDate:Date = this._tvMode.getServerDate(); // Серверное время
				
				var endDate:Date = new Date;
				var nextDate:Date = new Date;
				
				var playItem:PlaylistItem;
				var nextItem:PlaylistItem;
				
				for each (var item:PlaylistItem in this._playlist.list)
				{
					
					endDate = this.parseDateStringToDate(item.date, item.time);
					
					nextItem = this._playlist.getItemAt(item.index + 1);
					// Есть ли в плей листе след. ролик
					if (nextItem != null)
					{
						// След дата показа...
						nextDate = this.parseDateStringToDate(nextItem.date, nextItem.time);
						
						if (serDate.getTime() >= endDate.getTime() && serDate.getTime() < nextDate.getTime())
						{
							playItem = item;
						}
					}
					// Если серверное время привышает показываем...
					else if (serDate.getTime() >= endDate.getTime())
					{
						playItem = item;
					}
					
				}
				
				if (playItem != null && playItem.index != this._playlist.index)
				{
					// проверяем разницу по времени на сколько промотать сеанс 
					endDate = this.parseDateStringToDate(playItem.date, playItem.time);
					var offset:Number = Math.round((serDate.getTime() / 1000) - (endDate.getTime() / 1000));
					if (offset > 0)
					{
						this._playlist.getItemAt(playItem.index).start = offset;
					}
					this._playlist.index = playItem.index;
					this.stopVideo();
					this.playVideo();
				}
				
			}
		}
		
		/* Получить текущий итем, который проигрывается */
		public function currentPlayItem():PlaylistItem
		{
			arguments;
			return this._playlist.currentPlayItem();
		}
		
		/* Получить плайлист */
		public function getPlayList():PlayList
		{
			return this._playlist;
		}
		
		/**/
		private function init():void
		{
			this.initMenu();

			time = new Timer(40);
			time.addEventListener(TimerEvent.TIMER, onTimer);
			
			slideTimer = new Timer(1000, 1);
			slideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			
			nameTimer = new Timer(3000, 1);
			nameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			
			panelMc.prevBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.playBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.pauseBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.stopBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.nextBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.fullBtn.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.volMc.addEventListener(MouseEvent.CLICK, onClick);
			panelMc.videosBtn.addEventListener(MouseEvent.CLICK, showPlaylist);
			panelMc.playlistMc.closeBtn.addEventListener(MouseEvent.CLICK, hidePlaylist);
			
			panelMc.volMc.addEventListener(MouseEvent.ROLL_OVER, showSlider);
			panelMc.volMc.addEventListener(MouseEvent.ROLL_OUT, hideSlider);
			panelMc.volSlider.addEventListener(MouseEvent.ROLL_OUT, hideSlider);
			
			stage.addEventListener(Event.MOUSE_LEAVE, onOut);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onOver);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			
			panelMc.volSlider.visible = false;
			panelMc.volMc.sndOff.visible = false;
			
			createVideoBtns();
			hidePlaylist();
			
			if (this._autoPlay == true)
				playVideo();
		}
		
		/* Уничтожитель слоев для провайдеров */
		public function destroyChildMediaLayer():void
		{
			while (this._mediaLayer.numChildren > 0)
			{
				this._mediaLayer.removeChildAt(0);
			}
			;
		}
		
		private function onOver(e:MouseEvent):void
		{
			if (panelMc.y == 495)
			{
				TweenLite.to(panelMc, 0.5, {y: 465});
				TweenLite.to(panelMc.nameTxt, 0.5, {y: -455});
				TweenLite.to(panelMc.playlistMc, 0.5, {y: -225});
			}
		}
		
		private function onOut(e:Event):void
		{
			if (panelMc.y == 465)
			{
				TweenLite.to(panelMc, 0.5, {y: 495});
				TweenLite.to(panelMc.nameTxt, 0.5, {y: -485});
				TweenLite.to(panelMc.playlistMc, 0.5, {y: -255});
			}
		}
		
		/* Создаем playlist виджет */
		private function createVideoBtns():void
		{
			var btn:MovieClip;
			for (var i:uint = 0, u:uint = this._playlist.list.length; i < u; i++)
			{
				btn = new PlaylistVideo();
				btn.nameTxt.text = this._playlist.list[i].title;
				btn.y = i * 34;
				btn.id = i;
				btn.invBtn.addEventListener(MouseEvent.CLICK, onClickVideo);
				panelMc.playlistMc.videoContainer.addChild(btn);
			}
			
			panelMc.playlistMc.scrollerMc.scroller.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
		}
		
		private function startScroll(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveScroller);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
		}
		
		private function moveScroller(e:MouseEvent):void
		{
			var newY:Number = panelMc.playlistMc.scrollerMc.mouseY;
			var newPos:Number = newY;
			
			if (newPos < -67.5)
				newPos = -67.5;
			if (newPos > 67.5)
				newPos = 67.5;
			
			panelMc.playlistMc.scrollerMc.scroller.y = newPos;
			panelMc.playlistMc.videoContainer.y = -87 + ((newPos + 67.5) / (-135) * (panelMc.playlistMc.videoContainer.height - 170));
		}
		
		private function stopScroll(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroller);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
		}
		
		/* Клик по списку в playlist */
		private function onClickVideo(e:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(e.currentTarget.parent);
			this._playlist.index = mc.id;
			stopVideo();
			playVideo();
			hidePlaylist();
		}
		
		private function showPlaylist(e:MouseEvent = null):void
		{
			panelMc.playlistMc.visible = true;
		}
		
		private function hidePlaylist(e:MouseEvent = null):void
		{
			panelMc.playlistMc.visible = false;
		}
		
		private function onClick(e:MouseEvent):void
		{
			switch (e.currentTarget.name)
			{
				case 'prevBtn': 
					prevVideo();
					break;
				case 'playBtn': 
					playVideo();
					break;
				case 'pauseBtn': 
					pauseVideo();
					break;
				case 'stopBtn': 
					stopVideo();
					break;
				case 'nextBtn': 
					nextVideo();
					break;
				case 'fullBtn': 
					fullHandler();
					break;
				case 'volMc': 
					changeVol();
					break;
			}
		}
		
		private function fullHandler():void
		{
			trace(stage.scaleMode)
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function showSlider(e:MouseEvent):void
		{
			slideTimer.stop();
			slideTimer.reset();
			if (!panelMc.volSlider.visible)
			{
				panelMc.volSlider.alpha = 0;
				panelMc.volSlider.visible = true;
				TweenLite.to(panelMc.volSlider, 0.5, {alpha: 1});
				
				panelMc.volSlider.slider.addEventListener(MouseEvent.MOUSE_DOWN, slideDown);
				panelMc.volSlider.removeEventListener(MouseEvent.ROLL_OVER, showSlider);
			}
		}
		
		private function hideSlider(e:MouseEvent):void
		{
			slideTimer.reset();
			slideTimer.start();
			panelMc.volSlider.addEventListener(MouseEvent.ROLL_OVER, showSlider);
		}
		
		private function slideDown(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, slideUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, volHandler);
			panelMc.volSlider.removeEventListener(MouseEvent.ROLL_OUT, hideSlider);
		}
		
		private function slideUp(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, slideUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, volHandler);
			panelMc.volSlider.removeEventListener(MouseEvent.ROLL_OUT, hideSlider);
			
			if (!panelMc.volSlider.hitTestPoint(mouseX, mouseY, true))
			{
				slideTimer.reset();
				slideTimer.start();
				
				panelMc.volSlider.addEventListener(MouseEvent.ROLL_OVER, showSlider);
				
			}
		}
		
		private function volHandler(e:MouseEvent):void
		{
			var newY:Number = panelMc.volSlider.mouseY;
			var newVol:Number;
			
			if (newY >= -30)
			{
				if (newY <= 30)
				{
					panelMc.volSlider.slider.y = newY;
					newVol = (newY - 30) / (-60);
				}
				else
				{
					panelMc.volSlider.slider.y = 30;
					newVol = 0;
				}
			}
			else
			{
				panelMc.volSlider.slider.y = -30;
				newVol = 1;
			}
			if (newVol > 0)
			{
				panelMc.volMc.sndOff.visible = false;
			}
			else
			{
				panelMc.volMc.sndOff.visible = true;
			}
			
			this._provider.setVolume(newVol);
		}
		
		private function changeVol(mute:Boolean = false):void
		{
			if (this._provider.getSoundVolume() > 0)
			{
				panelMc.volSlider.slider.y = 30;
				this._provider.mute(true)
				panelMc.volMc.sndOff.visible = true;
			}
			else
			{
				panelMc.volSlider.slider.y = -30;
				this._provider.mute(false)
				panelMc.volMc.sndOff.visible = false;
			}
			//ns.soundTransform=snd;
		}
		
		private function onTimer(e:TimerEvent):void
		{
			switch (e.currentTarget)
			{
				case time: 
					onChangeTime();
					break;
				case slideTimer: 
					TweenLite.to(panelMc.volSlider, 0.5, {alpha: 0, onComplete: function()
						{
							panelMc.volSlider.visible = false;
						}});
					
					panelMc.volSlider.slider.removeEventListener(MouseEvent.CLICK, slideDown);
					break;
				case nameTimer: 
					panelMc.nameTxt.text = '';
					break;
			}
		}
		
		private function pauseVideo():void
		{
			if (this._provider != null)
			{
				this._provider.pause();
				
			}
			time.stop();
			panelMc.playBtn.visible = true;
			panelMc.pauseBtn.visible = false;
		}
		
		/* стоп видос */
		private function stopVideo():void
		{
			if (this._provider != null)
			{
				this._provider.stop();
				this._provider = null;
			}
			
			this.destroyChildMediaLayer();
			
			time.stop();
			time.reset();
			nameTimer.reset();
			nameTimer.stop();
			
			panelMc.playBtn.visible = true;
			panelMc.pauseBtn.visible = false;
			
			panelMc.progressMc.timeMc.width = 0;
			panelMc.progressMc.loadMask.width = 0;
			panelMc.progressMc.invMc.width = 0;
		}
		
		/* Ролик назад */
		private function prevVideo():void
		{
			arguments; // add hak fix
			if (this._playlist.index > 0)
			{
				this._playlist.index--;
			}
			else
			{
				this._playlist.index = _playlist.list.length - 1;
			}
			nameTimer.reset();
			nameTimer.stop();
			
			stopVideo();
			playVideo();
		}
		
		/* Ролик вперед */
		private function nextVideo():void
		{
			arguments; // add hak fix
			if (this._playlist.list.length - 1)
			{
				this._playlist.index++;
			}
			else
			{
				this._playlist.index = 0;
			}
			nameTimer.reset();
			nameTimer.stop();
			
			stopVideo();
			playVideo();
		}
		
		private function onChangeTime():void
		{
		/*
		
		   if(meta!=null)
		   {
		   var curTime:String;
		   var allTime:String;
		   var allmin:uint=meta.duration/60;
		   var allsec:uint=meta.duration-allmin*60;
		   var alls:uint=meta.duration;
		
		   var min:uint=ns.time/60;
		   var sec:uint=ns.time-min*60;
		   var s:uint=ns.time;
		
		   if(sec<10)
		   {
		   curTime=min+':0'+sec;
		   }else
		   {
		   curTime=min+':'+sec;
		   }
		
		   if(allsec<10)
		   {
		   allTime=allmin+':0'+allsec;
		   }else
		   {
		   allTime=allmin+':'+allsec;
		   }
		
		   panelMc.timeTxt.text=curTime+' / '+allTime;
		   panelMc.progressMc.timeMc.width=s/alls*200;
		 }*/
		}
		
		private function changePos(e:MouseEvent):void
		{
		
		/*
		   var percents:Number=ns.bytesLoaded/ns.bytesTotal;
		   var newPos=e.currentTarget.mouseX/200*(meta.duration*percents);
		
		   if(panelMc.playBtn.visible)
		   {
		   playVideo();
		   ns.seek(newPos);
		   }else
		   {
		   ns.seek(newPos);
		 }*/
		}
		
		private function videoOnLoad(e:Event):void
		{
		
		/*
		   var percents:Number=ns.bytesLoaded/ns.bytesTotal;
		   panelMc.progressMc.loadMask.width=percents*200;
		 panelMc.progressMc.invMc.width=percents*200;*/
		}
		
		/*
		 * Парсит URL возращяет массив
		 *	@var protocol
		 *	@var host
		 *	@var port
		 *	@var path
		 *	@var parameters
		 *   @var extension   расширение файла...
		 */
		private function parseUrl(_arg1:String):Array
		{
			var reg_http:RegExp = /(?P<protocol>[a-zA-Z]+) : \/\/  (?P<host>[^:\/]*) (:(?P<port>\d+))?  ((?P<path>[^?]*))? ((?P<parameters>.*))? /x;
			var result_http:Array = reg_http.exec(_arg1);
			
			var extension:String = result_http.path.length > 0 ? result_http.path.substring(result_http.path.lastIndexOf(".") + 1, result_http.path.length) : '';
			result_http['extension'] = extension.toLowerCase();
			return result_http;
		}
		
		public function getInitProvider(url):void
		{
			var _name:String;
			var reg_domain:RegExp = /(www\.)?(?P<domain>.*)\./x
			var url_data:Array = this.parseUrl(url);
			
			if (url_data.protocol == 'rtmp')
			{
				_name = 'rtmp';
			}
			else if (url_data.protocol == 'http')
			{
				var domain:String = reg_domain.exec(url_data.host).domain;
				if (domain == 'youtube')
				{
					_name = 'youtube'
				}
				else
				{
					_name = 'video';
				}
			}
			// is instance to stop...
			if (this._provider != null)
			{
				this._provider.stop();
			}
			
			switch (_name)
			{
				case 'rtmp': 
					if ((this._provider is RTMPProvider) == false)
					{
						this.destroyChildMediaLayer();
						this._provider = new RTMPProvider;
						this._mediaLayer.addChildAt(this._provider.display(), 0);
					}
					break;
				
				case 'youtube': 
					if ((this._provider is MediaYouTubeProvider) == false)
					{
						this.destroyChildMediaLayer();
						this._provider = new MediaYouTubeProvider;
						this._mediaLayer.addChildAt(this._provider.display(), 0);
					}
					break;
				case 'video': 
					if ((this._provider is VideoProvider) == false)
					{
						this.destroyChildMediaLayer();
						this._provider = new VideoProvider;
						this._mediaLayer.addChildAt(this._provider.display(), 0);
					}
					break;
				
				case 'vkontakte': 
					break;
			}
		
		}
		
		private function playVideo():void
		{
			
			panelMc.progressMc.invMc.removeEventListener(MouseEvent.CLICK, changePos);
			removeEventListener(Event.ENTER_FRAME, videoOnLoad);
			var item:PlaylistItem = this._playlist.getItemAt(this._playlist.index);
			time.start();
			this.getInitProvider(item.file);
			var pos:Number = this._provider.getPosition();
			
			this._provider.removeEventListener(Event.RESIZE, this.resizeHandler);
			this._provider.addEventListener(Event.RESIZE, this.resizeHandler);
			
			if (this._isTvMode == true && item.start > 0)
			{
				
				trace(item.file, item.start);
				this._provider.load(item.file);
				this._provider.play();
				this._provider.seek(item.start);
				
			}
			else if (pos == 0 && item.start == 0)
			{
				trace(item.file);
				this._provider.load(item.file);
				
				panelMc.nameTxt.text = item.title;
				addEventListener(Event.ENTER_FRAME, videoOnLoad);
				panelMc.progressMc.invMc.addEventListener(MouseEvent.CLICK, changePos);
			}
			else
			{
				trace('Play event ');
				this._provider.play()
			}
			
			// кнопки
			panelMc.playBtn.visible = false;
			panelMc.pauseBtn.visible = true;
			nameTimer.start();
		
		}
		
		/* callback на ресайз */
		public function resizeHandler(_arg1:Event)
		{
			var center_x:Number = stage.stageWidth / 2;
			var center_y:Number = stage.stageHeight / 2;
			var ratio:Number = stage.stageWidth / stage.stageWidth;

			this._error_box.resize(stage.stageWidth, stage.stageHeight);
			this._provider.resize(stage.stageWidth, stage.stageHeight);
		}
	
	}
}
