﻿package com.creatida { 
	
	/**
	 * Статусы плеира 
	 **/ 
    public class PlayerState {
		
        public static var IDLE:String = "IDLE";            // в дефолтном положении    
        public static var BUFFERING:String = "BUFFERING";  // читаю в буфер 
        public static var PLAYING:String = "PLAYING";      // играть
        public static var PAUSED:String = "PAUSED";        // пауза
		public static var END:String = "END";              // конец видео + стоп
		public static var SEEK:String = "SEEK";            // перемотка
		public static var STOP:String = "STOP";            // стоп

    }
}