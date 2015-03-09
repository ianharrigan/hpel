package haxe.processing.hpel.services;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.util.Logger;

class HpelService extends Service {
	public var process(default, default):Process;
	
	public function new() {
		super();
	}

	public override function setServiceParam(name:String, value:Dynamic):Void {
		switch (name) {
			case "process": 
				process = value;
			default:
				super.setServiceParam(name, value);
		}
	}
	
	public override function delegateCall(operation:String = null, params:Map<String, Dynamic> = null) {
		if (process == null) {
			throw "No process set";
		}
		
		process.execute().handle(function(r) {
			Logger.debug("Process result: " + r);
			responseData = r.payload;
			success();
		});
		
	}
}