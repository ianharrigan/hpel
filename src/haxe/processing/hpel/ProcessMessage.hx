package haxe.processing.hpel;

class ProcessMessage {
	public var payload(default, default):Dynamic;
	
	public function new(payload:Dynamic = null) {
		this.payload = payload;
	}
}