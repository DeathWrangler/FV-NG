package Managers.InGameConsole
{
   import Managers.AOEBuffsManager;
   
   public class ConsoleAOECommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleAOECommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "aoe";
      }
      
      public function getActiveBuffForSource(sourceId:String) : String
      {
         var result:String = "";
         var buffCode:String = AOEBuffsManager.getInstance().getActiveBuffForSourceID(sourceId);
         if(buffCode != null)
         {
            result = buffCode;
         }
         return result;
      }
      
      public function setActiveBuffForSource(buffCode:String, sourceID:String) : void
      {
         AOEBuffsManager.getInstance().setActiveBuffForSourceID(buffCode,sourceID);
      }
   }
}

