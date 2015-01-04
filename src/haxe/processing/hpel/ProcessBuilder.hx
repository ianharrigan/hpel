package haxe.processing.hpel;

import haxe.processing.hpel.builders.DSLBuilder;
import haxe.processing.hpel.builders.XMLBuilder;

class ProcessBuilder {
	public static inline var DSL:String = "dsl";
	public static inline var XML:String = "xml";
	
	public static inline var DEFAULT:String = DSL;
	
	public function new() {
		
	}
	
	public static function create(type:String = null, data:Dynamic = null):Process {
		if (type == null) {
			type = DEFAULT;
		}
		
		var b:ProcessBuilder = null;
		
		if (type == DSL) {
			b = new DSLBuilder();
		} else if (type == XML) {
			b = new XMLBuilder();
		}
		
		if (b == null) {
			throw "Builder type not recognised";
		}
		
		return b.build(data);
	}
	
	public function build(data:Dynamic = null):Process {
		throw "ProcessBuilder::build not implemented";
		return null;
	}
}