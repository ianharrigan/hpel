package haxe.processing.hpel.conditional;

import haxe.processing.hpel.Process;

class Otherwise extends Process {
	public function new() {
		super();
	}
	
	// Overridables
	private override function getDSLReturn():Process {
		return this;
	}
}