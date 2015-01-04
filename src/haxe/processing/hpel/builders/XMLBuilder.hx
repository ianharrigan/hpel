package haxe.processing.hpel.builders;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.ProcessBuilder;

class XMLBuilder extends ProcessBuilder {
	private static var _classNames:Map<String, Class<Process>>;
	
	public function new() {
		super();
		_classNames = new Map<String, Class<Process>>();
		_classNames.set("choose", haxe.processing.hpel.conditional.Choose);
		_classNames.set("otherwise", haxe.processing.hpel.conditional.Otherwise);
		_classNames.set("when", haxe.processing.hpel.conditional.When);
		_classNames.set("loop", haxe.processing.hpel.flow.Loop);
		_classNames.set("parallel", haxe.processing.hpel.flow.Parallel);
		_classNames.set("scope", haxe.processing.hpel.flow.Scope);
		_classNames.set("sequence", haxe.processing.hpel.flow.Sequence);
		_classNames.set("delay", haxe.processing.hpel.standard.Delay);
		_classNames.set("log", haxe.processing.hpel.standard.Log);
		_classNames.set("set", haxe.processing.hpel.standard.Set);
	}
	
	public override function build(data:Dynamic = null):Process {
		var xml:Xml = null;
		if (Std.is(data, String)) {
			xml = Xml.parse(cast(data, String));
		} else if (Std.is(data, Xml)) {
			xml = cast data;
		}
		
		if (xml == null) {
			throw "No xml data";
		}
		
		return buildFromXml(xml);
	}
	
	private function buildFromXml(data:Xml):Process {
		var p:Process = new Process();
		var root:Xml = data.firstElement();
		if (root.nodeName == "process") {
			for (child in root.elements()) {
				buildFromNode(child, p);
			}
		}
		return p;
	}
	
	private function buildFromNode(node:Xml, p:Process):Void {
		var alias:String = node.nodeName;
		var cls:Class<Process> = getClassFromAlias(alias);
		if (cls == null) {
			return;
		}
		
		var params:Array<Dynamic> = [];
		for (attr in node.attributes()) {
			params.push(node.get(attr));
		}
		
		p = p.addChild(cls, params);
		
		for (child in node.elements()) {
			buildFromNode(child, p);
		}
	}
	
	private function getClassFromAlias(alias:String):Class<Process> { // TEMP
		return _classNames.get(alias);
	}
}