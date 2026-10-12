package Widgets.Windows.MOTD
{
   import Managers.DragonBreedingManager;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DragonBreedingMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function DragonBreedingMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
         FarmStatsManager.count("MOTD","impressions","MOTD_dragonbreeding");
      }
      
      override protected function postLoadComplete() : void
      {
         if(!Global.player.getSeenFlag(DragonBreedingManager.VIDEO_SHOWN_FLAG))
         {
            DragonBreedingManager.showIntroVideo(this.onVideoComplete);
            Global.player.setSeenFlag(DragonBreedingManager.VIDEO_SHOWN_FLAG);
            super.postLoadComplete();
            this.hide();
         }
         else
         {
            super.postLoadComplete();
         }
      }
      
      public function onVideoComplete() : void
      {
         this.show();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         close();
         var actionParams:Object = null;
         if(currentMOTD.hasOwnProperty("customActionParams"))
         {
            actionParams = currentMOTD["customActionParams"];
         }
         var buildingName:String = actionParams.buildingName;
         DragonBreedingManager.getInstance(buildingName).showEyrieAndOpenWindow(buildingName);
         FarmStatsManager.count("MOTD","clicks","MOTD_dragonbreeding");
      }
   }
}

