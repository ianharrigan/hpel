package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Delay extends Process {
	public var seconds(default, default):Dynamic = 0;
	
	public function new(seconds:Dynamic = 0) {
		super(["seconds"]);
		this.seconds = seconds;
	}
	
	// Overridables
	private override function delegateExecute() {
		var r = evalString(seconds);
		var s:Float;
		if (Std.is(r, Float) == false) {
			s = Std.parseFloat(r);
		} else {
			s = cast r;
		}
		Sys.sleep(s);
		succeeded();
	}
	
	public override function clone():Process {
		var c:Delay = new Delay();
		copy(c);
		c.seconds = this.seconds;
		return c;
	}
}