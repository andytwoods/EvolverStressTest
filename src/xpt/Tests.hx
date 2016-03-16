package xpt;

/**
 * ...
 * @author 
 */

import flash.system.System;
import utest.Runner;
import utest.ui.Report;
import utest.ui.common.HeaderDisplayMode;
import xpt.evolve.Test_HEvalulationManager;
import xpt.mockStudy.Test_MockEntireStudy;
import xpt.mockStudy.Test_Sceduler;

 
class Tests
{

	public function new(callBack:Void->Void) 
	{
		var tests = new Runner();
		
		
		tests.addCase(new Test_HEvalulationManager());
		tests.addCase(new Test_MockEntireStudy());
		tests.addCase(new Test_Sceduler());
		
		
		Report.create(tests, NeverShowSuccessResults, AlwaysShowHeader);
		
		tests.onComplete.add(function(h) { 
			System.exit(0);
			callBack();
		} );
		
		tests.run();
		
		
	
	}
	
}