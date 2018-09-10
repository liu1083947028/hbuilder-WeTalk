const UTIL={
	getTopOffset:function(){
	    "use strict";
	    var topoffset=45;
	    if(plus.navigator.isImmersedStatusbar()){
	        topoffset=Math.round(plus.navigator.getStatusbarHeight())+45;
	    }
	    return topoffset
	},
	getRequest:function(){   
	   var url = location.search; //获取url中"?"符后的字串   
	   var theRequest = new Object();   
	   if (url.indexOf("?") != -1) {   
	      var str = url.substr(1);   
	      strs = str.split("&");   
	      for(var i = 0; i < strs.length; i ++) {   
	         theRequest[strs[i].split("=")[0]]=unescape(strs[i].split("=")[1]);   
	      }   
	   }   
	   return theRequest;   
	},
	isIphoneX:function(){
	    if(navigator){
	        return /iphone/gi.test(navigator.userAgent) && (screen.height == 812 && screen.width == 375)
	    } else {
	        return false
	    }
	},
	validatePwd:function(value){
		let PASSWORD_VALIDATION = /^[a-zA-Z0-9\_]{6,18}$/;
		if(!PASSWORD_VALIDATION.test(value)){
			return false
		}else{
			return true
		}
	},
	removeAllAccount:function(removePush = '0', callback=()=>{}){
        this.polylinkSip("removeAllAccount", [removePush], callback);
    },
    getSDKLogs:function(callback=()=>{}){
        this.polylinkSip("getSDKLogs", [], callback);
    },
	polylinkSip:function(method, params = [], callback=()=>{}){
        if(!mui.os.ios) return callback('not ios');
        plus.bridge.exec('polylink', method, [
            plus.bridge.callbackId((result)=>callback(null, result),(err)=>callback(err)),
            ...params
        ]);
    }
}
