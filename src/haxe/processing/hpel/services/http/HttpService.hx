package haxe.processing.hpel.services.http;

import haxe.format.JsonParser;
import haxe.Http;
import haxe.processing.hpel.services.Service;
import haxe.processing.hpel.util.IdUtils;
import haxe.processing.hpel.util.Logger;

#if neko
import neko.vm.Thread;
#elseif cpp
import neko.vm.Thread;
#end

class HttpResponseType {
	public static inline var RAW:String = "raw";
	public static inline var JSON:String = "json";
}

class HttpService extends Service {
	public var url(default, default):String;
	public var type(default, default):String = HttpResponseType.RAW;
	
	public var errorMessage:String = null;
	public var status:Int = -1;
	
	public function new() {
		super();
	}
	
	public override function setServiceParam(name:String, value:Dynamic):Void {
		switch (name) {
			case "url": 
				url = value;
			case "type":
				type = value;
			default:
				super.setServiceParam(name, value);
		}
	}
	
	public override function delegateCall(operation:String = null, params:Map<String, Dynamic> = null) {
		errorMessage = null;
		status = -1;

		var callThread:Thread = Thread.create(callThread);
		callThread.sendMessage(this);
		callThread.sendMessage(operation);
		callThread.sendMessage(Thread.current());
		
		Thread.readMessage(true);
		if (errorMessage == null) {
			success();
		} else {
			error(errorMessage);
		}
	}
	
	private function processResponse(http:Http):Void {
		responseVars = new Map<String, String>();
		if (http.responseHeaders != null) {
			for (key in http.responseHeaders.keys()) {
				responseVars.set(key, http.responseHeaders.get(key));
			}
		}
		
		switch (type) {
			case HttpResponseType.JSON:
				responseData = JsonParser.parse(http.responseData);
			default:
				responseData = http.responseData;
		}
	}
	
	private function callThread() {
		var p:HttpService = Thread.readMessage(true);
		var operation:String = Thread.readMessage(true);
		var m:Thread = Thread.readMessage(true);
		var u:String = p.url;
		u = StringTools.replace(u, "%OPERATION%", operation);
		Logger.debug("http call: " + u);
		if (p._serviceParams != null) {
			Logger.debug("http params: " + p._serviceParams);
		}
		var http:Http = new Http(u);
		if (p._serviceParams != null) {
			for (param in p._serviceParams.keys()) {
				var value = p._serviceParams.get(param);
				http.setParameter(param, value);
			}
		}
		//http.cnxTimeout = 10000;
		//http.setParameter("test", IdUtils.guid());
		http.onData = function onData(data:String) {
			Logger.debug(data);
			p.processResponse(http);
			m.sendMessage("complete");
		}
		http.onStatus = function onStatus(status:Int) {
			Logger.debug("HttpService::onStatus - " + status);
			p.status = status;
		}
		http.onError = function onError(msg:String) {
			Logger.debug("HttpService::onError - " + msg);
			p.errorMessage = msg;
			m.sendMessage("errored");
		}
		http.request();
	}
}