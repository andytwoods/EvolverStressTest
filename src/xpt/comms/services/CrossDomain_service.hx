package xpt.comms.services;
import haxe.Json;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import xpt.comms.CommsResult;


#if html5
	import js.Lib;
	import js.Browser;
#end

class CrossDomain_service
{
#if html5
	public static var instance:CrossDomain_service;
	public var parent:Dynamic;
	public var targetDomain:String;
	public var __wait_til_error:Int;
	private var counter:Int = 0;
	private var callback_list:Map<Int, CommsResult -> String -> Void> = new Map<Int, CommsResult -> String -> Void>();
	public var linked:Bool = true;
	
#end
	
	public function new() { }

	public static function setup(wait_til_error:String):Bool
	{		
		#if html5
		
			if (instance != null) throw "singleton err: should be instantiated once only";
			
			instance = new CrossDomain_service();
			instance.parent = Browser.window.parent;
			instance.__wait_til_error = Std.parseInt(wait_til_error);

			instance.targetDomain = (Browser.window.location != Browser.window.parent.location)? Browser.document.referrer : Std.string(Browser.document.location);
			
			
			var delay = new Timer(instance.__wait_til_error);
			
			function delayL(e:TimerEvent) {
				delay.removeEventListener(TimerEvent.TIMER, delayL);	
				instance = null;
			}
			delay.addEventListener(TimerEvent.TIMER, delayL);
			

			
			Browser.window.addEventListener('message', function(e) {
				if (e.data == 'linked') {
					delay.stop();
					delay.removeEventListener(TimerEvent.TIMER,  delayL);
				}
				else instance.receivedMessage(e.data, e);
			}, false);
			return true;
			
		#end
		
		return false;
	}
	


	
	public function receivedMessage(data, more) {	
		var message = data;
		trace(message,more);
	}
	
	private function send_parent(message:String, id:String) {
		#if html5
			parent.postMessage(message, targetDomain,[id]);
		#end
		
	}
	
	public function send(message:String, callBackF:CommsResult -> String -> Void) {
		#if html5
			callback_list.set( counter, callBackF);
			send_parent(message, Std.string(counter));
			counter++;
		#end
	}
	
	public function sendResults(message:Map<String,String>, callBackF:CommsResult -> String -> Void) {
		#if html5
			send(Json.stringify(message), callBackF);
		#end
	}
	
}