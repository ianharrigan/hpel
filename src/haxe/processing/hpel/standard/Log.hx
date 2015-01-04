package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Log extends Process {
	public var message(default, default):String;
	
	public function new(message:Dynamic = null) {
		super();
		this.message = message;
	}
	
	// Overridables
	private override function delegateExecute() {
		trace(evalString(message, false));
		success();
	}
	
	public override function clone():Process {
		var c:Log = new Log();
		copy(c);
		c.message = this.message;
		return c;
	}
}