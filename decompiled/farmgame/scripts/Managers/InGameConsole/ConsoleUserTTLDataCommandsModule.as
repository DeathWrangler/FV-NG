package Managers.InGameConsole
{
   public class ConsoleUserTTLDataCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleUserTTLDataCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "userTTLData";
      }
      
      public function getAllTTLData() : String
      {
         sendTransaction("getAllTTLData",{},this.onGetAllTTLDataResult);
         return "Retrieving all the cached ttl data...";
      }
      
      private function onGetAllTTLDataResult(result:Object) : void
      {
         var ttlDataObject:Object = null;
         var key:String = null;
         if(result.hasOwnProperty("allTTLData"))
         {
            ttlDataObject = result.allTTLData;
            for(key in ttlDataObject)
            {
               InGameConsoleManager.writeToHistory("Key: " + key + " Value: " + ttlDataObject[key]["value"] + " Expires: " + ttlDataObject[key]["expireTime"]);
            }
         }
      }
      
      public function setTTLData(key:String, value:String, ttl:int) : String
      {
         sendTransaction("setTTLData",{
            "key":key,
            "dataValue":value,
            "ttl":ttl
         });
         return "Setting ttl data";
      }
      
      public function resetAllTTLData() : String
      {
         sendTransaction("resetAllTTLData",{});
         return "All User TTL Data reset.";
      }
      
      public function resetTTLData(key:String) : String
      {
         sendTransaction("resetTTLData",{"key":key});
         return "User TTL Data for key: " + key + " reset.";
      }
      
      public function checkNamedPrereq(name:String) : String
      {
         sendTransaction("checkNamedPrereqs",{"prereqName":name},this.onCheckNamePrereqResult);
         return "Checking named prereq!";
      }
      
      private function onCheckNamePrereqResult(result:Object) : void
      {
         if(result.hasOwnProperty("prereqResult") && result.hasOwnProperty("name"))
         {
            InGameConsoleManager.writeToHistory("Prereq " + result.name + " executed with the value: " + result.prereqResult.toString());
         }
      }
   }
}

