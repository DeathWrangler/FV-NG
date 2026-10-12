package Classes.MOTD
{
   import Classes.ZItem.ExpansionData;
   import Classes.util.ZLocUtils;
   import Display.MOTD;
   import Display.UI;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   import flash.utils.getDefinitionByName;
   
   public class ExpansionGASeasonMotdHandler extends ExpansionAccessMotdHandler
   {
      
      public function ExpansionGASeasonMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD,addPopupToQueue);
      }
      
      protected function get seasonId() : int
      {
         var result:int = -1;
         if(m_currentMOTD.hasOwnProperty(SEASON_ID))
         {
            result = int(m_currentMOTD.seasonId);
         }
         return result;
      }
      
      override protected function get FTUEPath() : String
      {
         var result:String = "";
         if(this.seasonId != -1)
         {
            result = m_expansionData.motdAssets[GENERAL_ACCESS_TYPE + "_" + String(this.seasonId)][ExpansionData.KEY_FTUE];
         }
         return result;
      }
      
      override protected function get assetPath() : String
      {
         return m_expansionData.motdAssets[GENERAL_ACCESS_TYPE + "_" + String(this.seasonId)][ExpansionData.KEY_ASSET];
      }
      
      override public function execute() : void
      {
         var expansionOnboardingWindowClass:Class = getDefinitionByName(this.onBoardingWindowClass) as Class;
         m_expansionOnboardingWindow = new expansionOnboardingWindowClass(this.assetPath,ZLocUtils.t("Dialogs",brochureButtonZLocKey),acceptMOTD,this.closeMOTD,m_access,m_expansionData.worldId,FTUEClick) as ExpansionOnboardingWindow;
         m_expansionOnboardingWindow.setHideFirstTimeClose(m_hideFirstTimeClose);
         UI.displayPopup(m_expansionOnboardingWindow,m_addPopupToQueue);
         ztrack("impressions");
         Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
         m_isFinished = true;
      }
      
      override protected function get onBoardingWindowClass() : String
      {
         return "Widgets.Windows.Expansion.ExpansionOnboardingWindow";
      }
   }
}

