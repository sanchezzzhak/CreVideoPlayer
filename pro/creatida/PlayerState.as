﻿package pro.creatida { 
	
	/* Статусы плеира */ 
	
     public class PlayerState {
		
        public static var IDLE:String = "IDLE";            // сплю    
        public static var BUFFERING:String = "BUFFERING";  // буферизуюсь 
        public static var PLAYING:String = "PLAYING";      // играю
        public static var PAUSED:String = "PAUSED";        // жду

    }
}