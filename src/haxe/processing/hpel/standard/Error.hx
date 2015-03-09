package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Error extends Process {
	public var exception(default, default):Dynamic;
	
	public function new(exception:Dynamic) {
		super(["message"]);
		this.exception = exception;
	}
	
	// Overridables
	private override function delegateExecute() {
		throw exception;
	}
}