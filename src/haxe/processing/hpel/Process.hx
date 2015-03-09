package haxe.processing.hpel;

import haxe.processing.hpel.flow.ErrorHandler;
import haxe.processing.hpel.flow.Scope;
import haxe.processing.hpel.hscript.ScriptInterp;
import haxe.processing.hpel.util.CallStackHelper;
import haxe.processing.hpel.util.IdUtils;
import haxe.processing.hpel.util.Logger;
import tink.core.Future;

class Process {
	public var id(default, default):String;
	public var parent(default, default):Process;

	private var complete(default, null):Bool = false;
	private var errorObject(default, null):Dynamic = null;
	
	private var _trigger:FutureTrigger<ProcessMessage>;
	private var _children:Array<Process>;

	private var _vars:Map<String, Dynamic>;
	
	public var paramNames(default, null):Array<String>; // used in xml to get correct order of constructor params
	
	public function new(paramNames:Array<String> = null) {
		this.paramNames = paramNames;
		id = IdUtils.createObjectId(this);
		_trigger = new FutureTrigger<ProcessMessage>();
		_vars = new Map<String, Dynamic>();
	}
	
	private var output(get, null):ProcessMessage;
	private function get_output():ProcessMessage {
		return output;
	}

	private var root(get, null):Process;
	private function get_root():Process {
		var p = this;
		while (p.parent != null) {
			p = p.parent;
		}
		return p;
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
	
	public function execute():Future<ProcessMessage> {
		try {
			delegateExecute();
		} catch (e:Dynamic) {
			var errorHandler = findChild(haxe.processing.hpel.flow.ErrorHandler);
			if (errorHandler != null) {
				errorHandler.execute().handle(function(r) {
					succeeded();
					_trigger.asFuture();
				});
			} else {
				CallStackHelper.traceCallStack();
				errored(e);
				throw e;
			}
		}
		return _trigger.asFuture();
	}
	
	private function setVar(varName:String, varValue:Dynamic) {
		if (varName == "output") {
			root.output = new ProcessMessage(varValue);
		}
		
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
	
	private function getVar(varName:String) {
		var varValue = _vars.get(varName);
		if (varValue == null && parent != null) {
			varValue = parent.getVar(varName);
		}
		return varValue;
	}
	
	private function getVars():Map<String, Dynamic> {
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
				if (Std.is(c, haxe.processing.hpel.flow.ErrorHandler) == true) {
					continue;
				}
				
				c.execute().handle(function(r) {
					checkComplete();
				});
			}
		} else {
			succeeded();
		}
	}
	
	public function clone():Process {
		throw "clone not implemented";
	}
	
	private function checkComplete():Void {
		// TODO: need an error and aggregation strategy here
		var childrenComplete = true;
		var e:Dynamic = null;
		for (c in _children) {
			if (Std.is(c, haxe.processing.hpel.flow.ErrorHandler) == true) {
				continue;
			}
			
			if (c.complete == false) {
				childrenComplete = false;
				break;
			}
			
			if (c.errorObject != null) {
				e = c.errorObject;
			}
		}
		
		if (childrenComplete == true) {
			succeeded();
		}
	}

	private function succeeded() {
		complete = true;
		_trigger.trigger(root.output);
	}
	
	private function errored(e:Dynamic) {
		complete = true;
		errorObject = e;
		setVar("error", e);
		root.output = new ProcessMessage(e);
		_trigger.trigger(root.output);
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
		Logger.debug(indent + cls);
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
		if (n1 == -1) {
			return s;
		}
		while (n1 != -1) {
			var n2:Int = copy.indexOf("}", n1);
			
			var before:String = copy.substr(0, n1);
			var after:String = copy.substr(n2 + 1, copy.length);
			var script:String = copy.substr(n1 + 2, n2 - n1 - 2);

			var result = eval(script);
			var resultType = Type.getClassName(Type.getClass(result));
			if (before.length != 0 || after.length != 0) {
				copy = before + result + after;
			} else {
				copy = result;
			}
			if (Std.is(copy, String)) {
				n1 = copy.indexOf("${");
			} else {
				n1 = -1;
			}
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
		var interp = new haxe.processing.hpel.util.ScriptInterp();
		for (v in vars.keys()) {
			interp.variables.set(v, vars.get(v));
		}
		var result = null;
		try {
			result = interp.expr(program);
		} catch (e:Dynamic) {
			Logger.warn("WARNING: " + e);
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
			var className:String = Type.getClassName(Type.getClass(p));
			if (Std.is(p, type)) {
				r = p;
				break;
			}
			p = p.parent;
		}
		return r;
	}
	
	public function findChild(type:Class<Process>, from:Int = 0) {
		var p = null;
		var r = null;
		if (_children != null) {
			var index:Int = 0;
			for (c in _children) {
				if (Std.is(c, type) && index >= from) {
					r = c;
					break;
				}
				index++;
			}
		}
		return r;
	}
	
	public function findChildren(type:Class<Process>):Array<Process> {
		var arr:Array<Process> = new Array<Process>();
		if (_children != null) {
			for (c in _children) {
				if (Std.is(c, type)) {
					arr.push(c);
				}
			}
		}
		return arr;
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

	public function beginErrorHandler():Process {
		return addChild(haxe.processing.hpel.flow.ErrorHandler);
	}
	
	public function endErrorHandler():Process {
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
	
	public function error(exception:Dynamic = null):Process {
		return addChild(haxe.processing.hpel.standard.Error, [exception]);
	}
	
	public function invoke(serviceId:Dynamic, operation:Dynamic = null, varName:String = null):Process {
		return addChild(haxe.processing.hpel.standard.Invoke, [serviceId, operation, varName]);
	}
	
	public function beginParams():Process {
		var p = findChild(haxe.processing.hpel.standard.Invoke,  _children.length - 1);
		if (p == null) {
			throw "No matching invoke";
		}
		trace(p);
		return p.addChild(haxe.processing.hpel.standard.Params);
	}
	
	public function endParams():Process {
		return parent.parent;
	}
	
	public function param(name:Dynamic, value:Dynamic):Process {
		return addChild(haxe.processing.hpel.standard.Param, [name, value]);
		var p = findParent(haxe.processing.hpel.standard.Params);
		if (p == null) {
			throw "No parent params";
		}
		return p.addChild(haxe.processing.hpel.standard.Param, [name, value]);
	}
	
	public function call(fn:Void->Void):Process {
		return addChild(haxe.processing.hpel.standard.Call, [fn]);
	}
	
	// temp helpers
	private var className(get, null):String;
	private function get_className():String {
		return Type.getClassName(Type.getClass(this));
	}
}