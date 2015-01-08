package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;

class Param extends Process {
	public var name(default, default):Dynamic;
	public var value(default, default):Dynamic;
	
	public function new(name:Dynamic = null, value:Dynamic = null) {
		super(["name", "value"]);
		this.name = name;
		this.value = value;
	}
}