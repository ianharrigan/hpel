package haxe.processing.hpel.services;
import haxe.processing.hpel.services.ServiceDescriptor.ServiceOperationDescriptor;
import haxe.processing.hpel.util.Logger;

class ServiceRepository {
	public static var instance(get, null):ServiceRepository;
	
	private static var _instance:ServiceRepository;
	private static function get_instance():ServiceRepository {
		if (_instance == null) {
			_instance = new ServiceRepository();
		}
		return _instance;
	}
	
	/////////////////////////////////////////////////////////////////////////////
	private var _serviceDescriptors:Map<String, ServiceDescriptor>;
	
	public function new() {
		_serviceDescriptors = new Map<String, ServiceDescriptor>();
	}
	
	public function addService(descriptor:ServiceDescriptor):ServiceDescriptor {
		_serviceDescriptors.set(descriptor.serviceId, descriptor);
		return descriptor;
	}
	
	public function createServiceInstance(serviceId:String):Service {
		var descriptor:ServiceDescriptor = _serviceDescriptors.get(serviceId);
		if (descriptor == null) {
			throw "Service '" + serviceId + "' not found";
		}
		var service:Service = Type.createInstance(descriptor.serviceClass, []);
		if (descriptor.params != null) {
			for (key in descriptor.params.keys()) {
				service.setServiceParam(key, descriptor.params.get(key));
			}
		}
		service.descriptor = descriptor;
		return service;
	}
	
	public function addServicesFromXml(xml:Xml):Void {
		var root:Xml = xml.firstElement();
		for (serviceNode in root.elementsNamed("service")) {
			var serviceId:String = serviceNode.get("id");
			var type:String = serviceNode.get("type");
			var serviceClass:Class<Service> = null;
			switch (type) {
				case "http":
					serviceClass = ServiceDescriptor.HTTP;
				case "mysql":
					serviceClass = ServiceDescriptor.MYSQL;
			}
			
			if (serviceId == null) {
				Logger.warn("WARNING: no service id found");
				continue;
			}
			if (serviceClass == null) {
				Logger.warn("WARNING: no service class found");
				continue;
			}
			
			var descriptor:ServiceDescriptor = new ServiceDescriptor(serviceId, serviceClass);
			for (paramNode in serviceNode.elements()) {
				var nodeName:String = paramNode.nodeName;
				if (nodeName == "operations") {
					continue;
				}
				
				var paramName:String = null;
				var paramValue:String = null;
				if (nodeName == "param") {
					paramName = paramNode.get("name");
					paramValue = paramNode.get("value");
				} else {
					paramName = nodeName;
					paramValue = paramNode.firstChild().nodeValue;
				}
				
				if (paramName != null && paramValue != null) {
					descriptor.addParam(paramName, paramValue);
				}
			}
			
			var operationsNode:Xml = serviceNode.elementsNamed("operations").next();
			if (operationsNode != null) {
				for (operationNode in operationsNode.elementsNamed("operation")) {
					var operationId:String = operationNode.get("id");
					var operation:ServiceOperationDescriptor = descriptor.addOperation(operationId);
					
					for (paramNode in operationNode.elements()) {
						var nodeName:String = paramNode.nodeName;
						var paramName:String = null;
						var paramValue:String = null;
						if (nodeName == "param") {
							paramName = paramNode.get("name");
							paramValue = paramNode.get("value");
						} else {
							paramName = nodeName;
							paramValue = paramNode.firstChild().nodeValue;
						}
						
						if (paramName != null && paramValue != null) {
							operation.addParam(paramName, paramValue);
						}
					}
				}
			}
			
			addService(descriptor);
		}
	}
}