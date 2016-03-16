package xpt.comms.services;
import thx.Maps;

/**
 * ...
 * @author 
 */
class UrlParams_service
{

	public static var params:Map<String,String>;
	public static var url:String;
	
	
	public static function init() {
		#if html5
			url = StringTools.urlDecode(js.Browser.document.referrer);
			if (url.length == 0) url = js.Browser.window.location.href;
			
			var query:String = StringTools.urlDecode(js.Browser.window.location.search.substring(1));
			
			var paramsList = query.split("&");
			params = new Map<String,String>();
			
			
			var arr:Array<String>;
			var nam:String;
			var val:String;

			for (item in paramsList) {
				
				arr = item.split("=");
				var nam = arr[0];
				var val = arr[1];
				if(val!=null && val.length>0)	params.set(nam, val);

			}

			#if debug
				trace(params);
			#end
			
	    #end

	}
	
	public static function is_devel_server():Bool {
		#if flash
			return true;
		#end 
		if (url == null ) return false;
		return url.indexOf('127.0.0.1') !=-1 || url.indexOf('localhost') !=-1;
		
	}
	
	public static function get(what:String):String {
		#if html5
			if (params == null) init();
			if (params.exists(what)) return params.get(what);
		#end
		return '';
	}
		
	
	
}