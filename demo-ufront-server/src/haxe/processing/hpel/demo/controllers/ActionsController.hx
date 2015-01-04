package haxe.processing.hpel.demo.controllers;

import ufront.web.Controller;
import ufront.web.result.JsonResult;

class ActionsController extends Controller {
	@:route("/hello/$name")
	public function hello(name:String = "stranger") {
		var result = {
			message: "Hello, " + name,
			name: name
		};
		return new JsonResult(result);
	}
}