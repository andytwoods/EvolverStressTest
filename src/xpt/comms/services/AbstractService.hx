package xpt.comms.services;
import xpt.comms.CommsResult;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import restclient.RestClient;


class AbstractService
{

	public static var __url:String;
	public static var __wait_til_error:Int;
	public static var TIMED_OUT:String = "timed out";
	
	public var success:CommsResult; 
	
	public var delay:Timer;
	
	public var __callBack:CommsResult -> String -> Map<String,String> -> Void;
	private var data:Map<String,String>;
	
	public static function setup(url:String, wait:Int) {
		__url = url;
		__wait_til_error = wait;
	}
	
	
	public function new(_data:Map<String,String>, callBackF:CommsResult -> String -> Map<String,String> -> Void) 
	{
		__callBack = callBackF;
		data = _data;
		delay = new Timer(__wait_til_error);
		delay.addEventListener(TimerEvent.TIMER, timerL);		
		delay.start();
	}
	
	
	private function do_callBack(result:CommsResult, message:String) {
		delay.stop();
		if(delay.hasEventListener(TimerEvent.TIMER)) delay.removeEventListener(TimerEvent.TIMER, timerL);
		success = result;
		if (result == Success) data = null;
		if (__callBack !=null)	__callBack(success, message, data);
		__callBack = null;
	}
	
	private function timerL(e:TimerEvent) {
		do_callBack(Fail,TIMED_OUT);
	}

	public function fromCloud_f(message:String) {	
		
		if (check_cloudMessageSuccess(message)) do_callBack(Success, message);
		else do_callBack(Fail, message);
	}
	
	//override this
	public function check_cloudMessageSuccess(message:String) 
	{
		return true;
	}
	
	public function err_f(message:String) {
		do_callBack(Fail,message);
	}
	
}