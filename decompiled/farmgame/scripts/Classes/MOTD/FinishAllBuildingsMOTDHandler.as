package Classes.MOTD
{
   import Classes.util.FarmGameUtil;
   import Events.FarmGameWorldEvent;
   import Managers.FarmStatsManager;
   import Managers.FinishAllBuildingsUtil;
   import Widgets.Windows.MOTD.FinishAllBuildingsMOTDWindow;
   
   public class FinishAllBuildingsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function FinishAllBuildingsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         if(Global.worldManager.isWorldLoading)
         {
            Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         }
         else
         {
            this.onExecute();
         }
         m_isFinished = true;
      }
      
      private function onExecute() : void
      {
         var saleItemList:Array = FinishAllBuildingsUtil.getSaleItems();
         FarmStatsManager.count(FinishAllBuildingsMOTDWindow.FINISH_ALL_BUILDING_COUNTER,"dialog_view",saleItemList.length.toString());
         super.execute();
         var freqFlag:String = FinishAllBuildingsUtil.getFrequencyFlag();
         if(Global.player.getFeatureLastShown(freqFlag) == 0)
         {
            Global.player.setFeatureLastShown(freqFlag,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         }
         FinishAllBuildingsUtil.conditionallyShowHudIcon();
      }
      
      public function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         if(!Global.worldManager.isVisiting())
         {
            Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
            this.onExecute();
         }
      }
   }
}

