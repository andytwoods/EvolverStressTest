package;

import openfl.display.Sprite;
import openfl.Lib;
import xpt.comms.CommsEvolve.EvolveComms;
import xpt.comms.services.AbstractService;
import xpt.Tests;


/**
 * ...
 * @author Andy Woods
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		AbstractService.setup('', 5);
		
		
		
		var tests:xpt.Tests = new xpt.Tests(start);
		
		
	}

	public static function start() {
		
		var e:EvolveComms = new EvolveComms();
		
	}
}
