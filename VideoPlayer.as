package
{
	import flash.system.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.xml.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.sampler.Sample;
	
	import flash.geom.Rectangle;
	import com.greensock.*;
	import pro.creatida.*;

	/* Код плеира */
	public class VideoPlayer extends Sprite
	{

		private var _mediaLayer:Sprite;
		private var _provider:Object; 
		
		private var meta = null;
		private var time:Timer;
		private var slideTimer:Timer;
		private var nameTimer:Timer;
		
		private var autoPlay:Number = 0;
		private var tvMode:TvMode;
		private var playList:PlayList;
		
		
		
		public function VideoPlayer()
		{
			Security.allowDomain('*');
			this.playList = new PlayList;
			
			
			
			var url:String = './videos.xml';
			if(stage.loaderInfo.parameters.hasOwnProperty('file'))
			{
				url = root.loaderInfo.parameters.file;
				if(root.loaderInfo.parameters.hasOwnProperty('autoplay'))
				{
					this.autoPlay = parseInt(root.loaderInfo.parameters.autoplay);
				}
			}
			var playItem:PlaylistItem = new PlaylistItem;
			var extension:String = url.substring(url.lastIndexOf(".")+1, url.length);
			switch(extension)
			{
				case 'xml':
						var xmlLoader:URLLoader=new URLLoader(new URLRequest(url));
						xmlLoader.addEventListener(Event.COMPLETE, this.xmlLoadPlayList);
					break;
				case 'flv':
				case 'mp4':
						playItem.file  = url;
						this.playList.insert(playItem);
					break;
			};
			panelMc.playBtn.visible=true;
			panelMc.pauseBtn.visible=false;
			
		}
				
		/* Загрузка PlayList */
		public function xmlLoadPlayList(e:Event):void
		{

			var xml:XML=XML(e.target.data);
		
			var videos:XMLList = xml.videos.children();
			for each (var item in videos) 
			{ 
				var playItem:PlaylistItem = new PlaylistItem;
				playItem.file  = item.@url;
				playItem.title = item.@name;
				// для тв режима...
				if(item.@time.length() > 0)
				{
					playItem.time = item.@time;
					playItem.date = item.@date;	
				}
				this.playList.insert( playItem);
			} 
			// TV Режим..
			if(xml.hasOwnProperty('server'))
			{
				this.tvMode = new TvMode;
				this.tvMode.setDateTime(
					xml.server.datetime.@year,(parseInt(xml.server.datetime.@month) -1),xml.server.datetime.@day,
					xml.server.datetime.@hour,xml.server.datetime.@minute , xml.server.datetime.@second
				);
				this.tvMode.addEventListener( TvMode.TvModeCheck, tvModeCheck);
				dispatchEvent(new Event(TvMode.TvModeCheck));
				
			}
			init();
		}

		public function tvModeCheck(e:Event):void
		{
			
			var serDate:Date = this.tvMode.getServerDate();
			
			var endDate:Date  = new Date;
			var nextDate:Date  = new Date;
			
			var playItem:PlaylistItem;
			var nextItem:PlaylistItem;
			
			var arrDate:Array;
			var arrTime:Array;
			
			for each (var item:PlaylistItem in this.playList.list)
			{
				arrDate = item.date.split('-');
				arrTime = item.time.split(':');
				endDate.setFullYear(arrDate[0], parseInt(arrDate[1])-1, arrDate[2]);
				endDate.setHours(arrTime[0],arrTime[1],0);
				
				nextItem = this.playList.getItemAt( item.index+1 );
				if(nextItem!=null)
				{
					arrDate = nextItem.date.split('-');
					arrTime = nextItem.time.split(':');
					nextDate.setFullYear(arrDate[0], parseInt(arrDate[1])-1, arrDate[2]);
					nextDate.setHours(arrTime[0],arrTime[1],0);	
					if(serDate.getTime() >= endDate.getTime() && serDate.getTime() < nextDate.getTime())
					{
						playItem = item;	
					}
				}
				else if(serDate.getTime() >= endDate.getTime())
				{
					playItem = item;
				}
				
			}
			
			if(playItem.index != this.playList.index)
			{
				/* проверяем разницу по времени на сколько опоздал */
				arrDate = playItem.date.split('-');
				arrTime = playItem.time.split(':');
				endDate.setFullYear(arrDate[0], parseInt(arrDate[1])-1, arrDate[2]);
				endDate.setHours(arrTime[0],arrTime[1],0);
				var offset:uint = (( serDate.getTime() - endDate.getTime() ) /1000) /60;
				if(offset >0)
				{
					this.playList.list[playItem.index].start = offset;
				}

				this.playList.index = playItem.index;
				this.stopVideo();
				this.playVideo();
			} 
		}
		
		
		/* Получить текущий итем, который проигрывается */
		public function currentPlayItem():PlaylistItem
		{
			arguments;
			return this.playList.currentPlayItem();
		}
		
		/* Получить плайлист */
		public function getPlayList():PlayList
		{
			return this.playList;
		}
		
		private function init():void
		{
			this._mediaLayer = new Sprite()
			
			this._mediaLayer.x = 0;
			this._mediaLayer.y = 0;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align =  StageAlign.TOP_LEFT;
			
			addChildAt(this._mediaLayer, 0);
			time=new Timer(40);
			time.addEventListener(TimerEvent.TIMER, onTimer);
			
			slideTimer=new Timer(1000,1);
			slideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			
			nameTimer=new Timer(3000,1);
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
			

			panelMc.volSlider.visible=false;
			panelMc.volMc.sndOff.visible=false;
			
			
			createVideoBtns();
			hidePlaylist();
			playVideo();
		}

		/* Уничтожитель слоев для провайдеров */
		public function destroyChildMediaLayer():void
		{
			while (this._mediaLayer.numChildren > 0) {
				this._mediaLayer.removeChildAt(0);
			};
		}
		
		
		private function onOver(e:MouseEvent):void
		{
			if(panelMc.y==495)
			{
				TweenLite.to(panelMc, 0.5, {y:465});
				TweenLite.to(panelMc.nameTxt, 0.5, {y:-455});
				TweenLite.to(panelMc.playlistMc, 0.5, {y:-225});
			}
		}
		
		
		private function onOut(e:Event):void
		{
			if(panelMc.y==465)
			{
				TweenLite.to(panelMc, 0.5, {y:495});
				TweenLite.to(panelMc.nameTxt, 0.5, {y:-485});
				TweenLite.to(panelMc.playlistMc, 0.5, {y:-255});
			}
		}
		
		/* Создаем playlist виджет */
		private function createVideoBtns():void
		{
			var btn:MovieClip;
			for(var i:uint=0, u:uint=this.playList.list.length; i<u ;i++)
			{
				btn=new PlaylistVideo();
				btn.nameTxt.text= this.playList.list[i].title;
				btn.y=i*34;
				btn.id=i;
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
			var newY:Number=panelMc.playlistMc.scrollerMc.mouseY;
			var newPos:Number=newY;
			
			if(newPos<-67.5)
				newPos=-67.5;
			if(newPos>67.5)
				newPos=67.5;
			
			panelMc.playlistMc.scrollerMc.scroller.y=newPos;
			panelMc.playlistMc.videoContainer.y=-87+((newPos+67.5)/(-135)*(panelMc.playlistMc.videoContainer.height-170));
		}
		
		private function stopScroll(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveScroller);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
		}
		
		/* Клик по списку в playlist */
		private function onClickVideo(e:MouseEvent):void
		{
			var mc:MovieClip=MovieClip(e.currentTarget.parent);
			this.playList.index=mc.id;
			stopVideo();
			playVideo();
			hidePlaylist();
		}
		
		
		private function showPlaylist(e:MouseEvent=null):void
		{
			panelMc.playlistMc.visible=true;
		}
		
		
		private function hidePlaylist(e:MouseEvent=null):void
		{
			panelMc.playlistMc.visible=false;
		}
		
		
		private function onClick(e:MouseEvent):void
		{
			switch(e.currentTarget.name)
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
			if(stage.displayState==StageDisplayState.FULL_SCREEN)
			{
				stage.displayState=StageDisplayState.NORMAL;
			}else
			{
				stage.displayState=StageDisplayState.FULL_SCREEN;
			}
		}
		
		private function showSlider(e:MouseEvent):void
		{
			slideTimer.stop();
			slideTimer.reset();
			if(!panelMc.volSlider.visible)
			{
				panelMc.volSlider.alpha=0;
				panelMc.volSlider.visible=true;
				TweenLite.to(panelMc.volSlider,0.5,{alpha:1});
				
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
			
			if(!panelMc.volSlider.hitTestPoint(mouseX,mouseY,true))
			{
				slideTimer.reset();
				slideTimer.start();
				
				panelMc.volSlider.addEventListener(MouseEvent.ROLL_OVER, showSlider);
				
			}
		}
		
		private function volHandler(e:MouseEvent):void
		{
			var newY:Number=panelMc.volSlider.mouseY;
			var newVol:Number;
			
			if(newY>=-30)
			{
				if(newY<=30)
				{
					panelMc.volSlider.slider.y=newY;
					newVol=(newY-30)/(-60);
				}else
				{
					panelMc.volSlider.slider.y=30;
					newVol=0;
				}
			}else
			{
				panelMc.volSlider.slider.y=-30;
				newVol=1;
			}
			if(newVol>0)
			{
				panelMc.volMc.sndOff.visible=false;
			}else
			{
				panelMc.volMc.sndOff.visible=true;
			}
			
			this._provider.setVolume(newVol);	
		}
		
		
		private function changeVol(mute:Boolean=false):void
		{
			if(this._provider.getSoundVolume()>0)
			{
				panelMc.volSlider.slider.y=30;
				this._provider.mute(true)
				panelMc.volMc.sndOff.visible=true;
			}else
			{
				panelMc.volSlider.slider.y=-30;
				this._provider.mute(false)
				panelMc.volMc.sndOff.visible=false;
			}
			//ns.soundTransform=snd;
		}
		
		
		private function onTimer(e:TimerEvent):void
		{
			switch(e.currentTarget)
			{
				case time:
					onChangeTime();
					break;
				case slideTimer:
					TweenLite.to(panelMc.volSlider, 0.5,{alpha:0, onComplete:function(){
						panelMc.volSlider.visible=false;
					}});
					
					panelMc.volSlider.slider.removeEventListener(MouseEvent.CLICK, slideDown);
					break;
				case nameTimer:
					panelMc.nameTxt.text='';
					break;
			}
		}
		
		private function pauseVideo():void
		{
			if(this._provider!=null)
			{
				this._provider.pause();
				
			}
			time.stop();
			panelMc.playBtn.visible=true;
			panelMc.pauseBtn.visible=false;
		}
		
		/* стоп видос */
		private function stopVideo():void
		{
			if(this._provider!=null)
			{
				this._provider.stop();
				this._provider = null;
			}	
			
			this.destroyChildMediaLayer();
			
			time.stop();
			time.reset();
			nameTimer.reset();
			nameTimer.stop();
			
			panelMc.playBtn.visible=true;
			panelMc.pauseBtn.visible=false;
			
			panelMc.progressMc.timeMc.width=0;
			panelMc.progressMc.loadMask.width=0;
			panelMc.progressMc.invMc.width=0;
		}
		
		/* Ролик назад */
		private function prevVideo():void
		{
			arguments; // add hak fix
			if(this.playList.index >0)
			{
				this.playList.index--;
			}else
			{
				this.playList.index = playList.list.length-1;
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
			if( this.playList.list.length -1)
			{
				this.playList.index++;
			}else
			{
				this.playList.index=0;
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
			var reg_http:RegExp   = /(?P<protocol>[a-zA-Z]+) : \/\/  (?P<host>[^:\/]*) (:(?P<port>\d+))?  ((?P<path>[^?]*))? ((?P<parameters>.*))? /x;
			var result_http:Array = reg_http.exec(_arg1);

			var extension:String = result_http.path.length > 0  ? result_http.path.substring(result_http.path.lastIndexOf(".")+1, result_http.path.length) : '';
			result_http['extension'] = extension.toLowerCase();
			return result_http;
		}
		

		
		public function getInitProvider(url):void
		{
			var _name:String;
			var reg_domain:RegExp = /(www\.)?(?P<domain>.*)\./x
			var url_data:Array = this.parseUrl(url);
			
			if(url_data.protocol == 'rtmp')
			{
				_name = 'rtmp';
			}
			else if(url_data.protocol == 'http')
			{
				var domain:String = reg_domain.exec(url_data.host).domain;
				if(domain == 'youtube')
				{
					_name = 'youtube'	
				}
				else
				{
					_name = 'video';
				}
			}
			// is instance to stop...
			if(this._provider!=null)
			{
				this._provider.stop();
			}
			
			switch(_name)
			{
				case 'rtmp':
					if( (this._provider is RTMPProvider) == false)
					{
						this.destroyChildMediaLayer();
						this._provider = new RTMPProvider;
						this._mediaLayer.addChildAt(this._provider.display(),0);
					}
					break;
				
				case 'youtube':
					if( (this._provider is MediaYouTubeProvider) == false  )
					{	
						this.destroyChildMediaLayer();
						this._provider = new MediaYouTubeProvider;
						this._mediaLayer.addChildAt(this._provider.display(),0);
					}
					break;
				case 'video':
					if( (this._provider is VideoProvider) == false)
					{	
						this.destroyChildMediaLayer();
						this._provider = new VideoProvider;
						this._mediaLayer.addChildAt(this._provider.display(),0);
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
			var item:PlaylistItem = this.playList.getItemAt( this.playList.index );
			this.getInitProvider(item.file);
			
			time.start();
			
			var pos:Number = this._provider.getPosition();
			if(pos==0)
				{
					this._provider.load(item.file);
					
					panelMc.nameTxt.text = item.title;
					addEventListener(Event.ENTER_FRAME, videoOnLoad);
					panelMc.progressMc.invMc.addEventListener(MouseEvent.CLICK, changePos);
				}else
				{
					this._provider.play();
				}
			
			// кнопки
			panelMc.playBtn.visible=false;
			panelMc.pauseBtn.visible=true;
			nameTimer.start();
				
			//if(item.start > 0 )
			//{
			//this._provider.seek(item.start);
			//}	
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		/* callback на ресайз */
		public function resizeHandler(_arg1:Event)
		{
			this._mediaLayer.x = 0;
			this._mediaLayer.width = stage.stageWidth;
			this._mediaLayer.height = stage.stageHeight;
			this._provider.resize(stage.stageWidth, stage.stageHeight);
		}
		

		
		
		
		
	}
}
