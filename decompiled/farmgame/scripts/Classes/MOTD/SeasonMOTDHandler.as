package Classes.MOTD
{
   import Classes.ZItem.ExpansionData;
   import Display.MOTD;
   
   public class SeasonMOTDHandler extends ExpansionAccessMotdHandler
   {
      
      protected var m_accessType:String;
      
      public function SeasonMOTDHandler(currentMOTD:Object, accessType:String)
      {
         this.m_accessType = accessType;
         super(currentMOTD);
      }
      
      override protected function get FTUEPath() : String
      {
         var result:String = "";
         if(this.seasonId != -1)
         {
            result = m_expansionData.motdAssets[this.m_accessType + "_" + String(this.seasonId)][ExpansionData.KEY_FTUE];
         }
         return result;
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
      
      override protected function get assetPath() : String
      {
         var result:String = "";
         if(this.seasonId != -1)
         {
            result = m_expansionData.seasons[this.seasonId].dialog[this.m_accessType];
         }
         return result;
      }
      
      override public function execute() : void
      {
         ztrack("impressions");
         Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
         m_isFinished = true;
      }
      
      protected function loadNextSeason(worldType:String) : void
      {
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.worldManager.swapFarm(worldType,true,true);
         }
         else
         {
            Global.worldManager.loadNextSeason(worldType);
         }
      }
      
      override protected function get onBoardingWindowClass() : String
      {
         return "Widgets.Windows.SeasonRewardWindow";
      }
   }
}

