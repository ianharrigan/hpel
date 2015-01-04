package haxe.processing.hpel.flow;

import haxe.processing.hpel.Process;

class Scope extends Process {
	public function new() {
		super();
	}
	
	// Overridables
	private override function getDSLReturn():Process {
		return this;
	}
}	