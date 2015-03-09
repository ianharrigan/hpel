package haxe.processing.hpel.util;

import hscript.Interp;

class ScriptInterp extends Interp {
	public function new() {
		super();
	}
	
	override function get( o : Dynamic, f : String ) : Dynamic {
		if( o == null ) throw error(EInvalidAccess(f));
		return Reflect.getProperty(o,f);
    }

    override function set( o : Dynamic, f : String, v : Dynamic ) : Dynamic {
		if( o == null ) throw error(EInvalidAccess(f));
		Reflect.setProperty(o,f,v);
		return v;
    }
}
