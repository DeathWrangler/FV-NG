package Widgets.Windows.MOTD
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.RegionAchievementManager;
   import flash.events.MouseEvent;
   
   public class JapanAchievementMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function JapanAchievementMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
         FarmStatsManager.count("MOTD","impressions","MOTD_japanRA");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_JAPAN && Boolean(m_accept_bt))
         {
            m_accept_bt.text = ZLocUtils.t("Dialogs","MOTD_japanRA_buttonText_alt");
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         var featureName:String = null;
         super.onAccept(event);
         close();
         var actionParams:Object = null;
         if(currentMOTD.hasOwnProperty("customActionParams"))
         {
            actionParams = currentMOTD["customActionParams"];
         }
         if(actionParams.hasOwnProperty("featureName"))
         {
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_JAPAN)
            {
               featureName = actionParams.featureName;
               RegionAchievementManager.getInstance(featureName).showUI();
            }
            else
            {
               Global.hud.travelNameDisplay.showNewTravelWindow();
            }
            FarmStatsManager.count("MOTD","clicks","MOTD_japanRA");
         }
      }
   }
}

