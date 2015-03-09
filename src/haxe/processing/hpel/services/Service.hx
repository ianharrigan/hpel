package haxe.processing.hpel.services;

import tink.core.Future;

class Service {
	private var _trigger:FutureTrigger<Service>;

	public var responseData(default, default):Dynamic;
	public var responseVars(default, default):Map<String, String>;
	
	private var _serviceParams:Map<String, Dynamic>;
	
	public function new() {
		_trigger = new FutureTrigger<Service>();
	}
	
	public function call(operation:String = null, params:Map<String, Dynamic> = null):Future<Service> {
		delegateCall();
		return _trigger.asFuture();
	}
	
	public function delegateCall(operation:String = null, params:Map<String, Dynamic> = null) {
		throw "Service::delegateCall not implemented";
	}
	
	private function success() {
		_trigger.trigger(this);
	}
	
	private function error(e:Dynamic) {
		//_trigger.trigger(this);
		throw e;
	}
	
	public function setServiceParam(name:String, value:Dynamic):Void {
		if (_serviceParams == null) {
			_serviceParams = new Map<String, Dynamic>();
		}
		_serviceParams.set(name, value);
	}
}