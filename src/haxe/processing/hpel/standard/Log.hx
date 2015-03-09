package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.util.Logger;

class Log extends Process {
	public var message(default, default):String;
	
	public function new(message:Dynamic = null) {
		super(["message"]);
		this.message = message;
	}
	
	// Overridables
	private override function delegateExecute() {
		Logger.info(evalString(message, false));
		succeeded();
	}
	
	public override function clone():Process {
		var c:Log = new Log();
		copy(c);
		c.message = this.message;
		return c;
	}
}