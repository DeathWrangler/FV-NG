package Classes.util
{
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   
   public class ExternalUtil
   {
      
      public static const SUB_CALL_ID:String = "callId";
      
      public static const LOG_SECTION:String = "ExternalUtil";
      
      private static var s_instance:ExternalUtil = new ExternalUtil();
      
      private var m_calls:Dictionary;
      
      public function ExternalUtil()
      {
         super();
         if(s_instance)
         {
            throw new Error("Cannot instantiate a singleton instance");
         }
         this.m_calls = new Dictionary();
         this.addCallback("doRegisteredCallback",this.onCallback);
      }
      
      public static function get instance() : ExternalUtil
      {
         return s_instance;
      }
      
      public function call(method:String, ... params) : *
      {
         if(ExternalInterface.available)
         {
            GlobalEngine.info(LOG_SECTION,"Calling: " + method + "(\'" + params.join("\',\'") + "\')");
            params.unshift(method);
            return ExternalInterface.call.apply(null,params);
         }
         GlobalEngine.error(LOG_SECTION,"ExternalInterface unavailable, cannot call " + method);
      }
      
      public function addCallback(name:String, callback:Function) : void
      {
         if(ExternalInterface.available)
         {
            GlobalEngine.info(LOG_SECTION,"Adding callback [name=" + name + "]");
            ExternalInterface.addCallback(name,callback);
         }
         else
         {
            GlobalEngine.error(LOG_SECTION,"ExternalInterface unavailable, cannot add callback " + name);
         }
      }
      
      public function templateCall(template:String, subs:Object, callback:Function = null) : *
      {
         if(callback !== null && !subs.hasOwnProperty(SUB_CALL_ID))
         {
            GlobalEngine.info(LOG_SECTION,"Auto-registering callback");
            subs[SUB_CALL_ID] = this.registerCallback(callback);
         }
         return this.call(this.fillTemplate(template,subs));
      }
      
      private function fillTemplate(template:String, parameters:Object) : *
      {
         var regex:RegExp = null;
         var prop:String = null;
         for(prop in parameters)
         {
            regex = new RegExp("\\$\\{" + prop + "\\}","g");
            GlobalEngine.info(LOG_SECTION,"fillTemplate replacing \'" + prop + "\' with \'" + parameters[prop] + "\'");
            template = template.replace(regex,parameters[prop]);
         }
         return template;
      }
      
      public function registerCallback(callback:Function) : String
      {
         var callId:String = null;
         while(callId == null || this.m_calls.hasOwnProperty(callId))
         {
            callId = "call." + GlobalEngine.currentTime + "." + int(Math.random() * 10000);
         }
         this.m_calls[callId] = callback;
         GlobalEngine.info(LOG_SECTION,"Registered callback: [callId=" + callId + "]");
         return callId;
      }
      
      private function onCallback(callId:String, ... values) : void
      {
         var callback:Function = null;
         GlobalEngine.info(LOG_SECTION,"Received callback: [callId=" + callId + "]");
         if(Boolean(callId) && Boolean(this.m_calls[callId]))
         {
            callback = this.m_calls[callId];
            if(callback !== null)
            {
               GlobalEngine.info(LOG_SECTION,"Found callback for callId=" + callId);
               callback.apply(null,values);
            }
         }
         else
         {
            GlobalEngine.warning(LOG_SECTION,"Received callback for unknown callId: " + callId);
         }
      }
      
      public function navigate(url:String, useWindow:Boolean = false) : void
      {
         if(useWindow)
         {
            this.call("window.open",url);
         }
         else
         {
            navigateToURL(new URLRequest(url),"_top");
         }
      }
   }
}

