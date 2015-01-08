package haxe.processing.hpel.flow;

import haxe.processing.hpel.Process;
import haxe.processing.hpel.util.Logger;

#if neko
import neko.vm.Thread;
#elseif cpp
import neko.vm.Thread;
#end

class Parallel extends Scope {
	public function new() {
		super();
	}
	
	#if (neko || cpp) // only use real threads if available, for things like flash Parallel will behave like Sequence
	private override function delegateExecute() {
		var completeThread:Thread = Thread.create(completeThread);
		completeThread.sendMessage(this);
		completeThread.sendMessage(Thread.current());
		
		for (c in _children) {
			var thread:Thread = Thread.create(childThread);
			thread.sendMessage(c);
			thread.sendMessage(this);
			thread.sendMessage(completeThread);
		}
		
		Thread.readMessage(true);
		success(); // need error strategy, what if one fails?
	}
	#end
	
	private function completeThread() {
		var t:Parallel = Thread.readMessage(true);
		var m:Thread = Thread.readMessage(true);
		while (t.complete == false) {
			Thread.readMessage(true);
			t.checkComplete();
		}
		m.sendMessage("");
	}
	
	private function childThread() {
		var c:Process = Thread.readMessage(true);
		var t:Parallel = Thread.readMessage(true);
		var m:Thread = Thread.readMessage(true);
		Logger.debug("starting " + c.id + " thread");
		c.execute().handle(function(r) {
			m.sendMessage(r);
		});
	}
}