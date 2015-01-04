package haxe.processing.hpel.demo.companyc;

import ufront.web.Controller;
import ufront.web.result.JsonResult;

// company c emulates a service that works fine, but is just slow (Sys.sleep)
class CompanyCController extends Controller {
	@:route("/getProducts")
	public function getProducts() {
		var result = {
			found: 12,
			items: [
				{
					name: "Product B 1",
					price: 2.11,
					availability: 21
				},
				{
					name: "Product B 2",
					price: 2.22,
					availability: 22
				},
				{
					name: "Product B 3",
					price: 2.33,
					availability: 23
				},
				{
					name: "Product B 4",
					price: 2.44,
					availability: 24
				},
				{
					name: "Product B 5",
					price: 2.55,
					availability: 25
				},
				{
					name: "Product B 6",
					price: 2.66,
					availability: 26
				},
			]
		};
		//Sys.sleep(5); // heres the fake botteneck
		return new JsonResult(result);
	}
}