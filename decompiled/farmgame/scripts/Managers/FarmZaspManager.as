package Managers
{
   import Engine.Managers.LoadingManager;
   import Engine.Managers.ZaspManager;
   import flash.display.DisplayObject;
   
   public class FarmZaspManager extends ZaspManager
   {
      
      public function FarmZaspManager(displayRoot:DisplayObject)
      {
         super(displayRoot);
      }
      
      override protected function gameDefCon() : int
      {
         return DefconManager.defconLevel;
      }
      
      override protected function modifyReport(report:Object) : void
      {
         var profileData:Object = null;
         if(report["type"] == "fps")
         {
            report["constants"] += " V:2";
            report["game_state"] = this.gameDetail();
            report["string5"] = Global.player ? Global.player.level : -1;
            report["string6"] = LoadingManager.getObjectsLoaded();
            report["string7"] = profileData ? profileData["npc"] : 0;
            report["string8"] = profileData ? profileData["npcv"] : 0;
            report["number7"] = profileData ? profileData["build"] : 0;
            report["number8"] = profileData ? profileData["buildv"] : 0;
         }
         else if(report["type"] == "GPI")
         {
            report["level"] = Global.player ? Global.player.level : -1;
         }
      }
   }
}

