package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Call extends Process {
	public var fn(default, default):Void->Void;
	
	public function new(fn:Void->Void) {
		super();
		this.fn = fn;
	}
	
	// Overridables
	private override function delegateExecute() {
		var f = fn;
		if (f != null) {
			f();
		}
		succeeded();
	}
}