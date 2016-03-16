package xpt.evolve;
import flash.events.TimerEvent;
import flash.utils.Timer;

@:allow(xpt.evolve.Test_HEvalulationManager)
class Rating{
	public var rating_num:Int;
	var params:Map<String,Int> ;
	public var rating:Int;
	public var rater:String;
	var timer:Timer;
	var fail_callback: Void->Void;

    public function new(rating_num:Int, params:Map<String,Int>){
        this.rating_num = rating_num;
        this.params = params;
	}

    public function start(rater, fail_callback){
        this.rater = rater;

        this.fail_callback = fail_callback;
        this.timer = new Timer(this.params.get('time_out'));
		this.timer.addEventListener(TimerEvent.TIMER, do_callback);
		this.timer.start();
	}

    public function do_callback(e:TimerEvent){
		stop_timeout();
        this.fail_callback();
	}

    public function rated(rating){
        stop_timeout();
        this.rating = rating;
	}

    function stop_timeout(){
        this.timer.stop();
		this.timer.removeEventListener(TimerEvent.TIMER, do_callback);
	}
}
