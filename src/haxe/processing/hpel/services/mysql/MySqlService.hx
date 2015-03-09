package haxe.processing.hpel.services.mysql;

import haxe.processing.hpel.services.Service;
import haxe.processing.hpel.services.ServiceDescriptor.ServiceOperationDescriptor;
import haxe.processing.hpel.util.Logger;

#if neko
import sys.db.Connection;
import sys.db.Mysql;
import sys.db.ResultSet;
#elseif cpp
import sys.db.Connection;
import sys.db.Mysql;
import sys.db.ResultSet;
#end

class MySqlResponseType {
	public static inline var JSON:String = "json";
}

class MySqlService extends Service {
	public var host(default, default):String;
	public var port(default, default):Int;
	public var user(default, default):String;
	public var pass(default, default):String;
	public var database(default, default):String;
	public var type(default, default):String = MySqlResponseType.JSON;
	
	private static var _connection:Connection;
	
	public function new() {
		super();
	}
	
	public override function setServiceParam(name:String, value:Dynamic):Void {
		switch (name) {
			case "host": 
				host = value;
			case "port": 
				port = Std.parseInt(value);
			case "user": 
				user = value;
			case "pass": 
				pass = value;
			case "type":
				type = value;
			case "database":
				database = value;
			default:
				super.setServiceParam(name, value);
		}
	}
	
	public override function delegateCall(operation:String = null, params:Map<String, Dynamic> = null) {
		if (pass == null) {
			pass = "";
		}
		
		try {
			if (_connection == null) {
				_connection = Mysql.connect({
					host : host,
					port : port,
					user : user,
					pass : pass,
					database: database
				});
			}
			
			var operationDescriptor:ServiceOperationDescriptor = descriptor.getOperation(operation);
			if (operationDescriptor == null) {
				throw "Cant find operation descriptor for '" + operation + "'";
			}
			
			var sql:String = operationDescriptor.params.get("sql");
			if (params != null) {
				for (key in params.keys()) {
					var v = params.get(key);
					key = key.toLowerCase();
					sql = StringTools.replace(sql, "%" + key + "%", v);
					key = key.toUpperCase();
					sql = StringTools.replace(sql, "%" + key + "%", v);
				}
			}
			Logger.debug("sql: " + sql);
			var rs:ResultSet = _connection.request(sql);
			if (rs != null) {
				try {
					trace(rs.getFieldsNames());
					var arr:Array<Dynamic> = [];
					while (rs.hasNext()) {
						arr.push(rs.next());
					}
					responseData = arr;
				} catch (e:Dynamic) {
					if (sql.indexOf("INSERT") != -1 || sql.indexOf("insert") != -1) {
						responseData = _connection.request("SELECT LAST_INSERT_ID() as last").next().last;
					} else {
						responseData = rs.length;
					}
				}
			}
			Logger.debug("response: " + responseData);
			
			//_connection.close();
			//_connection = null;
			
			success();
		} catch (e:Dynamic) {
			if (_connection != null) {
				_connection.close();
			}
			error(e);
		}
	}
}