package haxe.processing.hpel.demo;

import neko.Lib;
import ufront.app.UfrontApplication;
import ufront.web.UfrontConfiguration;
import haxe.processing.hpel.demo.controllers.IndexController;

class Main {
	public static function main() {
		// enable caching if using mod_neko or mod_tora
		//#if (neko && !debug) neko.Web.cacheModule(run); #end
		
		run();
	}
	
	private static function run():Void {
		var config:UfrontConfiguration = {
			indexController: IndexController,
		}
		var app:UfrontApplication = new UfrontApplication(config);
		app.executeRequest();
	}
	private static function init():Void {
		
	}
}