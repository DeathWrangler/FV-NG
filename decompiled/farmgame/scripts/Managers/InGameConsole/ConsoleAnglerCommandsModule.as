package Managers.InGameConsole
{
   import Managers.FishingDerbyManager;
   
   public class ConsoleAnglerCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleAnglerCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "Angler";
      }
      
      public function getFish(fishName:String, collectionName:String, amount:String) : String
      {
         var output:String = "Trying to catch " + fishName;
         FishingDerbyManager.awardNumberMasteryForCollectible(collectionName,fishName,int(amount));
         var params:Object = {
            "adminController":"CPanelAnglerController",
            "adminCommand":"getFish",
            "fishName":fishName,
            "collection":collectionName,
            "amount":amount
         };
         sendTransaction("adminCall",params);
         return output;
      }
   }
}

