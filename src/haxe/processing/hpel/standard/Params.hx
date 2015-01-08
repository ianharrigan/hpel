package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Params extends Process {
	public function new() {
		super();
	}

	// Overridables
	private override function getDSLReturn():Process {
		return this;
	}
}