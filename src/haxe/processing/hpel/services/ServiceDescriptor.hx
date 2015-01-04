package haxe.processing.hpel.services;

class ServiceDescriptor {
	public static inline var HTTP:Class<Service> = haxe.processing.hpel.services.http.HttpService;
	
	public var serviceId(default, default):String;
	public var serviceClass(default, default):Class<Service>;
	public var params(default, default):Map<String, Dynamic>;
	
	public function new(serviceId:String, serviceClass:Class<Service>, params:Map<String, Dynamic> = null) {
		this.serviceId = serviceId;
		this.serviceClass = serviceClass;
		this.params = params;
	}
	
	public function addParam(name:String, value:Dynamic):Void {
		if (params == null) {
			params = new Map<String, Dynamic>();
		}
		params.set(name, value);
	}
}