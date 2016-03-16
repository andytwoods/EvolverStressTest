package xpt.tools;





class XRandom
{
	

	
//Fisher-yates Shuffle, adapted from JS from here:http://bost.ocks.org/mike/shuffle/		
	
	public static function shuffle <T>(arr:Array<T>):Array<T>{ 
		
		var m:Int = arr.length, t:Dynamic, i:Int;
		var randomList:Array<Float> = [];
		for (i in 0...m) {	
			
			randomList[i] = Math.random();
		}
		

		
		// While there remain elements to shuffle…
		while(m>0){
			// Pick a remaining element…
			i=Math.floor(randomList[m-1] * m--);
			// And swap it with the current element.
			t=arr[m];
			arr[m]=arr[i];
			arr[i]=t;
		}
		
		
		return arr;
	}
	

}