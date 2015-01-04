package haxe.processing.hpel.demo.companya;

import ufront.web.Controller;
import ufront.web.result.JsonResult;

class CompanyAController extends Controller {
	@:route("/getProducts")
	public function getProducts() {
		var result = {
			found: 3,
			items: [
				{
					name: "Product A 1",
					price: 1.11,
					availability: 11
				},
				{
					name: "Product A 2",
					price: 1.22,
					availability: 12
				},
				{
					name: "Product A 3",
					price: 1.33,
					availability: 13
				},
			]
		};
		return new JsonResult(result);
	}
}