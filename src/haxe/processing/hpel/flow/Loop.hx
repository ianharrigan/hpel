package haxe.processing.hpel.flow;
import haxe.processing.hpel.util.Logger;

class Loop extends Scope {
	public var items:Dynamic;
	public var varName:String;
	
	public function new(items:Dynamic = null, varName:String = null) {
		super(["items", "var"]);
		this.items = items;
		this.varName = varName;
	}

	/* TODO: Need to come back to this, doesnt work on cpp correctly
	private override function delegateExecute() {
		if (complete == true) {
			succeeded();
			return;
		}
		
		var arr:Array<Dynamic> = cast evalString(items);
		if (Std.is(items, Array)) {
			arr = cast items;
		}
		
		if (Std.is(arr, Array) == false) {
			Logger.warn("'" + items + "' doesnt result in an array");
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

		succeeded();  // need error strategy, what if one fails?
		
		if (Std.is(parent, Parallel)) {
			parent.delegateExecute();
		}
	}
	*/
}