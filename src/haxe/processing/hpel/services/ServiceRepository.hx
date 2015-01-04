package haxe.processing.hpel.services;

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
			}
			
			if (serviceId == null) {
				trace("WARNING: no service id found");
				continue;
			}
			if (serviceClass == null) {
				trace("WARNING: no service class found");
				continue;
			}
			
			var descriptor:ServiceDescriptor = new ServiceDescriptor(serviceId, serviceClass);
			for (paramNode in serviceNode.elementsNamed("param")) {
				var paramName:String = paramNode.get("name");
				var paramValue:String = paramNode.get("value");
				descriptor.addParam(paramName, paramValue);
			}
			addService(descriptor);
		}
	}
}