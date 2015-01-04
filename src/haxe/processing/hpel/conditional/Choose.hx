package haxe.processing.hpel.conditional;

import haxe.processing.hpel.Process;

class Choose extends Process {
	public function new() {
		super();
	}
	
	// Overridables
	private override function delegateExecute() {
		var otherwise:Otherwise = null;
		var processed:Bool = false;
		for (c in _children) {
			if (Std.is(c, When)) {
				var condition = cast(c, When).condition;
				var result:Bool = cast evalString(condition);
				if (result == true) {
					processed = true;
					c.delegateExecute();
				}
			} else if (Std.is(c, Otherwise)) {
				otherwise = cast c;
			}
		}
		
		if (processed == false && otherwise != null) {
			otherwise.delegateExecute();
		}
		
		success(); // need error strategy, what if one fails?
	}
	
	private override function getDSLReturn():Process {
		return this;
	}
}