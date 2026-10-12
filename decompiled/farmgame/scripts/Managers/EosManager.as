package Managers
{
   import com.adobe.serialization.json.JSON;
   import com.hurlant.util.Base64;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   public class EosManager extends EventDispatcher
   {
      
      private static var m_initialized:Boolean = false;
      
      public static const NOT_IN_OPT:String = "holdout";
      
      public static const EVENT_SERVER_VARIANTS_LOADED:String = "server_eos_variants_loaded";
      
      private var m_eosData:Object = new Object();
      
      public function EosManager()
      {
         super();
      }
      
      public function get initialized() : Boolean
      {
         return m_initialized;
      }
      
      public function checkAndLoadEos() : void
      {
         var eosData:Object = null;
         if(!m_initialized && ExternalInterface.available)
         {
            m_initialized = true;
            eosData = ExternalInterface.call("getEos");
            this.loadEosData(eosData);
         }
      }
      
      public function loadEosData(eosData:Object) : void
      {
         this.m_eosData = eosData;
      }
      
      public function getEosAssignmentData(eosName:String) : Object
      {
         var result:Object = null;
         if(Boolean(this.m_eosData) && this.m_eosData.hasOwnProperty(eosName))
         {
            result = this.m_eosData[eosName];
         }
         else
         {
            GlobalEngine.log("EOS ",eosName + " not found on front-end");
         }
         return result;
      }
      
      public function getEventPayload(eosName:String) : String
      {
         var eventPayload:String = "";
         var data:Object = this.getEosAssignmentData(eosName);
         if(Boolean(data) && data.hasOwnProperty("eventPayload"))
         {
            eventPayload = data.eventPayload;
         }
         return eventPayload;
      }
      
      public function getEosVariables(eosName:String) : Object
      {
         var eosVariables:Object = null;
         var optimizationData:Array = this.getEosOptimization(eosName);
         if(optimizationData != null && Boolean(optimizationData[7]))
         {
            return optimizationData[7];
         }
         return null;
      }
      
      public function getEosOptimization(eosName:String) : Array
      {
         var encodedEventPayload:String = this.getEventPayload(eosName);
         var encodedEventPayloadArr:Array = encodedEventPayload.split(":");
         var eventPayload:String = Base64.decode(encodedEventPayloadArr[1]);
         return com.adobe.serialization.json.JSON.decode(eventPayload);
      }
      
      public function getParsedVariantAssignment(eosName:String) : Array
      {
         var result:Array = null;
         var data:Object = this.getEosAssignmentData(eosName);
         if(Boolean(data) && Boolean(data.hasOwnProperty("variant")) && data.variant != NOT_IN_OPT)
         {
            result = [];
            result.push(data.variant);
         }
         return result;
      }
      
      public function getEosVariant(eosName:String) : int
      {
         this.checkAndLoadEos();
         var result:int = 0;
         var expVariants:Array = this.getParsedVariantAssignment(eosName);
         if(expVariants == null || expVariants.length == 0)
         {
            GlobalEngine.log("Eos",eosName + " not found on front-end");
         }
         else
         {
            result = int(expVariants[0]);
         }
         return result;
      }
      
      public function isValid(eosName:String) : Boolean
      {
         return true;
      }
      
      public function inOptimization(eosName:String) : Boolean
      {
         var variant:Array = null;
         var result:Boolean = false;
         var data:Object = this.getEosAssignmentData(eosName);
         if(Boolean(data) && data.hasOwnProperty("variables"))
         {
            result = true;
         }
         else if(Boolean(data) && data.hasOwnProperty("variant"))
         {
            variant = this.getParsedVariantAssignment(eosName);
            if(variant)
            {
               result = true;
            }
         }
         return result;
      }
   }
}

