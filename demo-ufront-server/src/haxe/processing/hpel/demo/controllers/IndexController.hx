package haxe.processing.hpel.demo.controllers;

import haxe.processing.hpel.demo.companya.CompanyAController;
import haxe.processing.hpel.demo.companyb.CompanyBController;
import haxe.processing.hpel.demo.companyc.CompanyCController;
import ufront.web.Controller;

class IndexController extends Controller {
	@post public function init() {
		context.session.init();
	}
	
	@:route("/actions/*") var actions:ActionsController;
	@:route("/companya/*") var companya:CompanyAController;
	@:route("/companyb/*") var companyb:CompanyBController;
	@:route("/companyc/*") var companyc:CompanyCController;
}