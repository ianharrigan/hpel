package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Delay extends Process {
	public var seconds(default, default):Dynamic = 0;
	
	public function new(seconds:Dynamic = 0) {
		super();
		this.seconds = seconds;
	}
	
	// Overridables
	private override function delegateExecute() {
		var s:Float = cast evalString(seconds);
		Sys.sleep(s);
		success();
	}
	
	public override function clone():Process {
		var c:Delay = new Delay();
		copy(c);
		c.seconds = this.seconds;
		return c;
	}
}