package haxe.processing.hpel.flow;

import haxe.processing.hpel.Process;

class Scope extends Process {
	public function new(paramNames:Array<String> = null) {
		super(paramNames);
	}
	
	// Overridables
	private override function getDSLReturn():Process {
		return this;
	}
}	