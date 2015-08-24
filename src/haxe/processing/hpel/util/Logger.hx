package haxe.processing.hpel.util;

class Logger {
	public static function info(message:String) {
		trace("INFO: " + message);
	}
	
	public static function warn(message:String) {
		trace("WARNING: " + message);
	}
	
	public static function debug(message:String) {
		//trace("DEBUG: " + message);
	}
}