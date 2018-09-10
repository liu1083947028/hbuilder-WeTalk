const NET_ERROR={ res:-1 , msg:"LOAD_ERROR" ,errorCode:"LOAD_ERROR" }
let _Api = {
	ajax:function(api,data,_method='POST',callback){
	    let token=plus.storage.getItem("authToken")
	    let site=plus.storage.getItem("apiSite")
	    console.log('------'+token)
	    console.log('------'+`${site}${api}`)
	    let setting={
		    	dataType:'json',//服务器返回json格式数据
		    	type:_method,
		    	timeout:10000,
		    	headers: {
	            'Accept': 'application/json',
	            'Content-Type': 'application/json',
	            "x-access-token": token,
	        },
	        success:(data)=>callback(null,data),
	        error:(xhr,type,errorThrown)=>callback(type)
	    }
	    if(_method=='POST'&&data){
	    		setting.data=data
	    }
	    mui.ajax(`${site}${api}`,setting);
	},
	get:function(url,callback) {
		_Api.ajax(url,null,'GET',callback)
	},
	post:function(url,data,callback){
		_Api.ajax(url,data,'POST',callback)
	},
	addImgMessage:function(rid,imgBase64Str,uuid,callback){
        _Api.post(`/api/chat/addImgMessage`, {rid,imgBase64Str,uuid},callback);
    },
    addAudioMessage:function(data,callback){
        _Api.post(`/api/chat/addAudioMessage`, data ,callback);
    },
    uploadLocalAudio:function(fileDomain,data,callback){
      	_Api.post(`${fileDomain}/uploadLocalAudio`, data ,callback);
    },
    getMessages:function(rid,before,callback){
      	_Api.get(`/api/getMessages/${rid}/${before}`,callback);
    },
}
