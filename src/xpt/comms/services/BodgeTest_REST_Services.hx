package xpt.comms.services;
import xpt.comms.CommsResult;
import haxe.ds.StringMap;

/**
 * ...
 * @author 
 */
class BodgeTest_REST_Service
{

	public static function test() {
	
		var results:Map<String,String> = new Map<String,String>();
		results.set("bla", "bla");
		
		REST_Service.__url = "http://127.0.0.1:8000/api/sj_data";
		REST_Service.__wait_til_error == 5;
		
		
		var data:StringMap<String> = ["bla" => "bla"];

		var resultRest:REST_Service = new REST_Service(data, function(info:CommsResult, message:String) {
			trace(info == Fail, message == "!expt_id");
		});
		
		var data:StringMap<String> = ["expt_id" => "bla"];

		var resultRest:REST_Service = new REST_Service(data, function(info:CommsResult, message:String) {
			trace(info == Fail, message =="unknown expt_id");
		});
		
	}
	
}