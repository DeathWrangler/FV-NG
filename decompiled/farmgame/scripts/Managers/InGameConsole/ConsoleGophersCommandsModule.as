package Managers.InGameConsole
{
   import Classes.util.FarmGameUtil;
   import Managers.CaptureFeatureManager;
   import com.adobe.serialization.json.JSON;
   
   public class ConsoleGophersCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleGophersCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "gophers";
      }
      
      public function resetGopherAvailableTime() : String
      {
         var time:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         CaptureFeatureManager.instance.setAvailableTime(CaptureFeatureManager.GOPHER_FEATURE_NAME,time);
         sendTransaction("adminCall",{
            "adminController":"CPanelGophersController",
            "adminCommand":"setAvailableTime",
            "time":time.toString()
         });
         return "Gopher Available Time Reset To: " + time.toString();
      }
      
      public function resetFeature() : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelGophersController",
            "adminCommand":"resetFeature"
         });
         CaptureFeatureManager.instance.resetFeatureData(CaptureFeatureManager.GOPHER_FEATURE_NAME);
         return "Gopher Feature Successfully Reset!";
      }
      
      public function setNextGopherId(gopherId:String) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelGophersController",
            "adminCommand":"setNextGopherId",
            "gopherId":gopherId
         });
         CaptureFeatureManager.instance.setAvailableGopher(CaptureFeatureManager.GOPHER_FEATURE_NAME,gopherId);
         return "Gopher Available Set To: " + gopherId;
      }
      
      public function incrementGopherTreats(count:int) : String
      {
         sendTransaction("adminCall",{
            "adminController":"CPanelGophersController",
            "adminCommand":"addTreats",
            "treatCount":count
         });
         CaptureFeatureManager.instance.incrementTreatCount(CaptureFeatureManager.GOPHER_FEATURE_NAME,count);
         return "Gopher Treats incremented by: " + count;
      }
      
      public function viewFeatureData() : String
      {
         return com.adobe.serialization.json.JSON.encode(CaptureFeatureManager.instance.getFeatureData(CaptureFeatureManager.GOPHER_FEATURE_NAME));
      }
   }
}

