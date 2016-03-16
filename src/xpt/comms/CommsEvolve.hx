package xpt.comms;
import xpt.comms.CommsResult;
import xpt.comms.services.AbstractService;
import xpt.comms.services.REST_Service;

/**
 * ...
 * @author Andy Woods
 */
class EvolveComms
{

	public function new() 
	{
		var data:Map<String,String> = new Map<String,String>();
		data.set('bla', 'databla');
		
		var info:String = '';
		
		trace(data, serviceResult(''));
		var restService:AbstractService = new REST_Service(data, serviceResult('bla'));
		
	}
	
	
	
	
	private function serviceResult(info:String) {
		return function(success:CommsResult, message:String, data:Map<String,String>) {
			
			if (success == CommsResult.Success) {
			
			}
			else {
		
				
			}
			
			

				
		}
	}
	
}