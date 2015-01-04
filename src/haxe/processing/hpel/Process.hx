package haxe.processing.hpel;

import haxe.processing.hpel.flow.Scope;
import haxe.processing.hpel.hscript.ScriptInterp;
import tink.core.Future;

class Process {
	public var parent(default, default):Process;

	private var complete(default, null):Bool = false;
	
	private var _trigger:FutureTrigger<ProcessResult>;
	private var _children:Array<Process>;

	private var _vars:Map<String, Dynamic>;
	
	public function new() {
		_trigger = new FutureTrigger<ProcessResult>();
		_vars = new Map<String, Dynamic>();
	}
	
	public function addChild(cls:Class<Process>, params:Array<Dynamic> = null):Process {
		if (_children == null) {
			_children = new Array<Process>();
		}
		if (params == null) {
			params = [];
		}
		var c:Process = Type.createInstance(cls, params);
		c.parent = this;
		_children.push(c);
		return c.getDSLReturn();
	}
	
	public function execute():Future<ProcessResult> {
		delegateExecute();
		return _trigger.asFuture();
	}
	
	public function setVar(varName:String, varValue:Dynamic) {
		var p = this;
		var firstScope = null;
		var found:Bool = false;
		while (p != null) {
			if (Std.is(p, Scope)) {
				if (firstScope == null) {
					firstScope = p;
				}
				if (p._vars.exists(varName)) {
					p._vars.set(varName, varValue);
					found = true;
					break;
				}
			}
			p = p.parent;
		}
		
		if (found == false && firstScope != null) {
			firstScope._vars.set(varName, varValue);
		}
	}
	
	public function getVar(varName:String) {
		var varValue = _vars.get(varName);
		if (varValue == null && parent != null) {
			varValue = parent.getVar(varName);
		}
		return varValue;
	}
	
	public function getVars():Map<String, Dynamic> {
		var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
		var p = this;
		while (p != null) {
			for (k in p._vars.keys()) {
				vars.set(k, p._vars.get(k));
			}
			p = p.parent;
		}
		return vars;
	}
	
	// Overridables
	private function delegateExecute() {
		if (_children != null && _children.length > 0) {
			for (c in _children) {
				c.execute().handle(function(r) {
					checkComplete();
				});
			}
		} else {
			success();
		}
	}
	
	public function clone():Process {
		throw "clone not implemented";
	}
	
	private function checkComplete():Void {
		// TODO: need an error and aggregation strategy here
		var childrenComplete = true;
		for (c in _children) {
			if (c.complete == false) {
				childrenComplete = false;
				break;
			}
		}
		
		if (childrenComplete == true) {
			success();
		}
	}

	private function success() {
		complete = true;
		_trigger.trigger(new ProcessResult());
	}
	
	private function error() {
		complete = true;
		_trigger.trigger(new ProcessResult());
	}
	
	private function getDSLReturn():Process {
		return this.parent; // assume that most steps are simple ones with no children
	}
	
	// Helpers
	public function dump(indent:String = null):Void {
		var cls:String = Type.getClassName(Type.getClass(this));
		if (indent == null) {
			indent = "";
		}
		trace(indent + cls);
		if (_children != null) {
			for (c in _children) {
				c.dump(indent + "  ");
			}
		}
	}
	
	private function evalString(s:Dynamic, evaluateResult:Bool = true) {
		if (Std.is(s, String) == false) {
			return s;
		}
		
		var copy:String = s;
		var n1:Int = copy.indexOf("${");
		while (n1 != -1) {
			var n2:Int = copy.indexOf("}", n1);
			
			var before:String = copy.substr(0, n1);
			var after:String = copy.substr(n2 + 1, copy.length);
			var script:String = copy.substr(n1 + 2, n2 - n1 - 2);
			
			var result = eval(script);
			
			copy = before + result + after;
			n1 = copy.indexOf("${");
		}
		if (evaluateResult == true) {
			return eval(copy);
		}
		return copy;
	}
	
	private function eval(script:Dynamic) {
		if (Std.is(script, String) == false) {
			return script;
		}
		
		var vars:Map<String, Dynamic> = getVars();
		var parser = new hscript.Parser();
		var program = parser.parseString(script);
		var interp = new ScriptInterp();
		for (v in vars.keys()) {
			interp.variables.set(v, vars.get(v));
		}
		var result = null;
		try {
			result = interp.expr(program);
		} catch (e:Dynamic) {
			trace("WARNING: " + e);
		}
		return result;
	}
	
	public function copy(c:Process) {
		c.parent = this.parent;
		c.complete = this.complete;
		if (this._children != null) {
			for (child in this._children) {
				var copy = child.clone();
				copy.parent = c;
				c._children.push(copy);
			}
		}
		
		for (key in this._vars) {
			c._vars.set(key, this._vars.get(key));
		}
	}	
	
	public function findParent(type:Class<Process>) {
		var p = this;
		var r = null;
		while (p != null) {
			if (Std.is(p, type)) {
				r = p;
				break;
			}
			p = p.parent;
		}
		return r;
	}
	
	// Util methods, should be built by macros eventually, broke my brain trying to figure it out
	// Scoped methods, have their own vars, etc, returns themselves for DSL
	public function beginSequence():Process {
		return addChild(haxe.processing.hpel.flow.Sequence);
	}
	
	public function endSequence():Process {
		return parent;
	}

	public function beginParallel():Process {
		return addChild(haxe.processing.hpel.flow.Parallel);
	}
	
	public function endParallel():Process {
		return parent;
	}
	
	public function beginLoop(items:Dynamic, varName:String = null):Process {
		return addChild(haxe.processing.hpel.flow.Loop, [items, varName]);
	}
	
	public function endLoop():Process {
		return parent;
	}

	// Conditionals are special
	public function beginChoose():Process {
		return addChild(haxe.processing.hpel.conditional.Choose);
	}
	
	public function endChoose():Process {
		return parent;
	}
	
	public function when(condition:Dynamic):Process {
		var p = findParent(haxe.processing.hpel.conditional.Choose);
		if (p == null) {
			throw "No parent choose";
		}
		return p.addChild(haxe.processing.hpel.conditional.When, [condition]);
	}

	public function otherwise():Process {
		var p = findParent(haxe.processing.hpel.conditional.Choose);
		if (p == null) {
			throw "No parent choose";
		}
		return p.addChild(haxe.processing.hpel.conditional.Otherwise);
	}
	
	// Simple steps, execute and thats it, returns thier parent for DSL
	public function log(message:Dynamic = null):Process {
		return addChild(haxe.processing.hpel.standard.Log, [message]);
	}
	
	public function delay(seconds:Dynamic = null):Process {
		return addChild(haxe.processing.hpel.standard.Delay, [seconds]);
	}
	
	public function set(name:String, value:Dynamic):Process {
		return addChild(haxe.processing.hpel.standard.Set, [name, value]);
	}
}