package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Set extends Process {
	public var name(default, default):String;
	public var value(default, default):Dynamic;
	
	public function new(name:String, value:Dynamic) {
		super(["name", "value"]);
		this.name = name;
		this.value = value;
	}
	
	// Overridables
	private override function delegateExecute() {
		setVar(name, evalString(value));
		succeeded();
	}
}