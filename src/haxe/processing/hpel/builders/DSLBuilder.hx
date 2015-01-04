package haxe.processing.hpel.builders;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.ProcessBuilder;

class DSLBuilder extends ProcessBuilder {
	public function new() {
		super();
	}
	
	public override function build(data:Dynamic = null) {
		return new Process();
	}
}