package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.motion.easing.Exponential;
	import fl.motion.easing.Sine;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	public class Marquesina extends MovieClip
	{
		private var _marquesina:MovieClip;
		private var _cajaTexto:TextField;
		private var _texto:String;
		private var _mascara:MovieClip;
		private var _cajaTextoAncho:Number;
		private var _cajaTextoAlto:Number;
		private var _formatoTexto:TextFormat;
		private var _tamano:Number;
		private var _color:uint;
		private var _timer1:Timer;
		private var _timer2:Timer;
		private var _tweenTextoX:Tween;


		public function get marquesinaText()
		{
			return _cajaTexto.htmlText;
		}

		public function set marquesinaText(cadena:String)
		{
			_texto = cadena;
			_cajaTexto.htmlText = unescape(_texto);
			formatearTexto();

		}

		/*
		Constructor
		*/
		public function Marquesina(cadena:String,tamano:Number,a:Number,l:Number,color:uint)
		{
			// inicialización
			_marquesina = this;
			_texto = cadena;
			_tamano = tamano;
			_cajaTextoAncho = a;
			_cajaTextoAlto = l;
			_color = color;

			_cajaTexto = new TextField();

			_marquesina.addChild(_cajaTexto);

			formatearTexto();

			_mascara = new MovieClip();
			_mascara.graphics.beginFill(0x000000,0);
			_mascara.graphics.drawRect(0,0,_cajaTextoAncho,_cajaTextoAlto);
			_marquesina.addChild(_mascara);

			_cajaTexto.mask = _mascara;

			_timer1 = new Timer(100);
			_timer2 = new Timer(10);

			if (_cajaTexto.width > _mascara.width)
			{
				// timers para animación del texto
				_timer1.addEventListener(TimerEvent.TIMER,onTimer1);
				_timer2.addEventListener(TimerEvent.TIMER,onTimer2);
			}
			
			_tweenTextoX = new Tween(_cajaTexto,"x",Exponential.easeOut,_mascara.x + _mascara.width,0,4,true);
			_tweenTextoX.addEventListener(TweenEvent.MOTION_FINISH,onTweenFin);

		}
		/*
		Timers y tweens  para la animación del texto
		*/
		private function onTimer1(e:TimerEvent):void
		{
			_timer1.stop();
			_timer2.start();
		}

		private function onTimer2(e:TimerEvent):void
		{
			var avance:Number = 1;
			if (_cajaTexto.x + _cajaTexto.width >= 0)
			{
				_cajaTexto.x -=  avance;
			}
			else
			{
				_timer2.stop();
				_tweenTextoX.start();
			}
		}

		private function onTweenFin(e:TweenEvent):void
		{
			_timer1.start();
		}
		
		private function formatearTexto():void
		{
			_formatoTexto = new TextFormat  ;
			_formatoTexto.font = "Arial";
			_formatoTexto.size = _tamano;
			_cajaTexto.htmlText = '<b>' + _texto + '</b>';
			_cajaTexto.setTextFormat(_formatoTexto);
			_cajaTexto.wordWrap = true;
			_cajaTexto.textColor = _color;
			_cajaTexto.autoSize = TextFieldAutoSize.LEFT;
			_cajaTexto.width = _texto.length * _tamano;
			_cajaTexto.selectable = false;
		}
	}
}