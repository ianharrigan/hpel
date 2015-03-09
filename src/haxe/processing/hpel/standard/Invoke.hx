package haxe.processing.hpel.standard;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.services.Service;
import haxe.processing.hpel.services.ServiceRepository;

class Invoke extends Process {
	public var serviceId:Dynamic;
	public var operation:Dynamic;
	public var varName:String;
	
	public function new(serviceId:Dynamic = null, operation:Dynamic = null, varName:String = null) {
		super(["service", "operation", "var"]);
		this.serviceId = serviceId;
		this.operation = operation;
		this.varName = varName;
	}
	
	// Overridables
	private override function delegateExecute() {
		var serviceIdCopy = evalString(serviceId);
		var operationCopy = evalString(operation);
		var varNameCopy = varName;
		if (varNameCopy == null) {
			varNameCopy = "invokeResult";
		}
	
		var service:Service = ServiceRepository.instance.createServiceInstance(serviceIdCopy);
		
		var params:Process = findChild(Params);
		if (params != null) {
			var paramArray:Array<Process> = params.findChildren(Param);
			for (p in paramArray) {
				var param:Param = cast p;
				var name = evalString(param.name);
				var value = evalString(param.value);
				service.setServiceParam(name, value);
			}
		}
		
		service.call(operationCopy).handle(function(result) {
			setVar(varNameCopy, result.responseData);
			succeeded();
		});
	}
}