package haxe.processing.hpel.conditional;

import haxe.processing.hpel.Process;

class When extends Process {
	public var condition(default, default):Dynamic;
	
	public function new(condition:Dynamic = null) {
		super(["condition"]);
		this.condition = condition;
	}
	
	// Overridables
	private override function getDSLReturn():Process {
		return this;
	}
}