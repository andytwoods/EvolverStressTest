package xpt.comms.services;

import comms.CommsResult;
import flash.events.TimerEvent;
import utest.Assert;
import xpt.comms.CommsResult;

class Test_AbstractService
{

	public function new() 
	{	
	}
	
	public function test1() {
	
		var done = Assert.createAsync(20);
		var a:AbstractService = null;
		
		AbstractService.__wait_til_error = 1;
		
		var data:Map<String,String> = new Map<String,String>();
		data.set('a', 'aa');
		
		
		function callback(success:xpt.comms.CommsResult, message:String, d:Map<String,String>):Void {
			Assert.isTrue(success == xpt.comms.CommsResult.Fail);
			Assert.isTrue(message == AbstractService.TIMED_OUT);
			Assert.isTrue(d.get('a') == data.get('a'));
			Assert.isTrue(a.delay.running == false);
			Assert.isTrue(a.delay.hasEventListener(TimerEvent.TIMER) == false);
			done();

		}
		
		a = new AbstractService(data, callback);
	}
	
	public function test2() {
	
		var done1 = Assert.createAsync(20);
		var done2 = Assert.createAsync(20);
		
		AbstractService.__wait_til_error = 500;
		
		var data:Map<String,String> = new Map<String,String>();
		data.set('a', 'aa');
		
		
		function callback(success:xpt.comms.CommsResult, message:String, d:Map<String,String>):Void {
			Assert.isTrue(success == xpt.comms.CommsResult.Fail);
			Assert.isTrue(message == 'bla');
			Assert.isTrue(d != null);
			done1();
		}
		
		var a:AbstractService = new AbstractService(data, callback);
		a.err_f('bla');
		
		a.__callBack = function (success:xpt.comms.CommsResult, message:String, d:Map<String,String>):Void {
			Assert.isTrue(success == Success);
			Assert.isTrue(message == 'from cloud');
			Assert.isTrue(d == null);
			done2();
		}
		
		a.fromCloud_f('from cloud');
	}
	
}