package haxe.processing.hpel.flow;

class Loop extends Scope {
	public var items:Dynamic;
	public var varName:String;
	
	public function new(items:Dynamic = null, varName:String = null) {
		super();
		this.items = items;
		this.varName = varName;
	}
	
	private override function delegateExecute() {
		if (complete == true) {
			success();
			return;
		}
		
		var arr:Array<Dynamic> = cast evalString(items);
		if (Std.is(items, Array)) {
			arr = cast items;
		}
		
		var n:Int = 1;
		var index:Int = parent._children.indexOf(this);
		for (v in arr) {
			var seq:Sequence = new Sequence();
			seq._children = new Array<Process>();
			seq.parent = parent;
			if (varName != null) {
				seq.setVar(varName, v);
			}
			
			for (c in _children) {
				var copy = c.clone();
				copy.parent = seq;
				seq._children.push(copy);
			}
			parent._children.insert(index + n, seq);
			n++;
		}

		success();  // need error strategy, what if one fails?
		
		if (Std.is(parent, Parallel)) {
			parent.delegateExecute();
		}
	}
}