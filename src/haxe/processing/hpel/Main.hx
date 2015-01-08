package haxe.processing.hpel;

import haxe.processing.hpel.flow.Sequence;
import haxe.processing.hpel.services.ServiceDescriptor;
import haxe.processing.hpel.services.ServiceRepository;
import haxe.processing.hpel.standard.Log;
import haxe.processing.hpel.util.Logger;
import haxe.Resource;
import neko.Lib;

class Main  {
	public static function main() {
		var p:Process = null;

		ServiceRepository.instance.addServicesFromXml(Xml.parse(Resource.getString("services.xml")));
		
		/*
		var sd:ServiceDescriptor = ServiceRepository.instance.addService(new ServiceDescriptor("company_a", ServiceDescriptor.HTTP));
		sd.addParam("url", "http://localhost:2000/companya/getProducts");
		sd.addParam("type", "json");
		*/
		
		/*
		var s = ServiceRepository.instance.createServiceInstance("company_a");
		Logger.debug(Type.getClassName(Type.getClass(s)));
		
		ServiceRepository
			.instance
				.createServiceInstance("company_a")
					.call("getQuote").handle(function(r) {
						Logger.info("items found = " + r.responseData.found);
					});
		*/
		
		/*
		var xmlString:String = Resource.getString("test1.xml");
		p = ProcessBuilder.create(ProcessBuilder.XML, xmlString);
		p.dump();
		p.execute().handle(function(r) {
			Logger.info("Process result: " + r);
		});
		return;
		*/
		
		p = ProcessBuilder.create()
		
				.beginSequence()
					.set("testVar", 0)
					.beginChoose()
						.when("${testVar >= 1}")
							.log("1 or greater! (value=${testVar})")
						.when("${testVar < 0}")
							.log("less than 0! (value=${testVar})")
						.otherwise()
							.log("Guess it must be zero! (value=${testVar})")
					.endChoose()
				.endSequence()
				
				.beginParallel()
					.beginSequence()
						.invoke("company_a", "getQuote", "result")
						.log("results found = ${result.found}")
					.endSequence()
					
					.beginSequence()
						.invoke("company_a", "getQuote", "result")
						.log("results found = ${result.found}")
					.endSequence()
					
					.beginSequence()
						.log("")
						.log("")
						.invoke("company_b", "getQuote", "result")
							.beginParams()
								.param("param1", "value1")
								.param("param2", "value2")
								.param("param3", "value3")
							.endParams()
						.log("results found = ${result.found}")

						.call(function() {
							Logger.info("bob");
						})
						
						.invoke("company_c", "getQuote", "result")
							.beginParams()
								.param("param1", "value1")
								.param("param2", "value2")
								.param("param3", "value3")
							.endParams()	
						.log("results found = ${result.found}")
					.endSequence()

					.beginSequence()
						.log("")
						.log("")
						
						.invoke("company_b", "getQuote", "result")
							.beginParams()
								.param("param1", "value1")
								.param("param2", "value2")
								.param("param3", "value3")
							.endParams()
						.log("results found = ${result.found}")
						
						.call(function() {
							Logger.info("bob");
						})
						
						.invoke("company_c", "getQuote", "result")
							.beginParams()
								.param("param1", "value1")
								.param("param2", "value2")
								.param("param3", "value3")
							.endParams()	
						.log("results found = ${result.found}")
					.endSequence()
					
					.beginSequence()
						.invoke("company_c", "getQuote", "result")
						.log("results found = ${result.found}")
					.endSequence()
				.endParallel()
				
				.beginSequence()
					.set("var1", 100)
					.beginSequence()
						.set("scopedVar", 200)
						.set("result", "${var1 + scopedVar}")
						.log("result = ${result}")
					.endSequence()
					.beginSequence()
						.set("scopedVar", 300)
						.set("result", "${var1 + scopedVar}")
						.log("result = ${result}")
					.endSequence()
				.endSequence()
		
				.beginParallel()
					.beginSequence()
						.log("start thread 1")
						.delay(15)
						.log("end thread 1")
					.endSequence()
					
					.beginSequence()
						.log("start thread 2")
						.delay(10)
						.log("end thread 2")
					.endSequence()
					
					.beginSequence()
						.log("start thread 3")
						.delay(5)
						.log("end thread 3")
					.endSequence()
				.endParallel()
				
				.beginSequence()
						.beginLoop([15, 10, 5], "delay")
							.log("delaying for ${delay} seconds")
							.delay("${delay}")
							.log("${delay} second delay complete")
						.endLoop()
				.endSequence()
				
				.beginSequence()
					.set("var_global", "something")
					.beginSequence()
						.set("var1", "bob")
						.log(1)
						.delay(.5)
						.log("2 ${var1 + 'tim'}")
						.delay(".5")
					.endSequence()
					.beginSequence()
						.log("3")
						.delay(.5)
						.log("4")
						.log("${var_global}, ${var1}")
						.delay(.5)
					.endSequence()
				.endSequence()
			;
		p.dump();
		
		p.execute().handle(function(r) {
			Logger.info("Process result: " + r);
		});
	}
}