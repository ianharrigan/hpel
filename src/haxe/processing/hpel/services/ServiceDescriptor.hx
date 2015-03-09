package haxe.processing.hpel.services;

class ServiceDescriptor {
	public static inline var HTTP:Class<Service> = haxe.processing.hpel.services.http.HttpService;
	public static inline var MYSQL:Class<Service> = haxe.processing.hpel.services.mysql.MySqlService;
	public static inline var HPEL:Class<Service> = haxe.processing.hpel.services.HpelService;
	
	public var serviceId(default, default):String;
	public var serviceClass(default, default):Class<Service>;
	public var params(default, default):Map<String, Dynamic>;
	
	private var _operations:Map<String, ServiceOperationDescriptor>;
	
	public function new(serviceId:String, serviceClass:Class<Service>, params:Map<String, Dynamic> = null) {
		this.serviceId = serviceId;
		this.serviceClass = serviceClass;
		this.params = params;
	}
	
	public function addParam(name:String, value:Dynamic):ServiceDescriptor {
		if (params == null) {
			params = new Map<String, Dynamic>();
		}
		params.set(name, value);
		return this;
	}
	
	public function addOperation(operationId:String, params:Map<String, Dynamic> = null):ServiceOperationDescriptor {
		var op:ServiceOperationDescriptor = new ServiceOperationDescriptor(operationId, params);
		if (_operations == null) {
			_operations = new Map<String, ServiceOperationDescriptor>();
		}
		_operations.set(operationId, op);
		return op;
	}
	
	public function getOperation(operationId:String):ServiceOperationDescriptor {
		if (_operations == null) {
			return null;
		}
		return _operations.get(operationId);
	}
}

class ServiceOperationDescriptor {
	public var operationId(default, default):String;
	public var params(default, default):Map<String, Dynamic>;
	
	public function new(operationId:String, params:Map<String, Dynamic> = null) {
		this.operationId = operationId;
		this.params = params;
	}
	
	public function addParam(name:String, value:Dynamic):ServiceOperationDescriptor {
		if (params == null) {
			params = new Map<String, Dynamic>();
		}
		params.set(name, value);
		return this;
	}
}
