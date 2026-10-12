package Display
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class BuyPottingShedPopup extends GenericPopup
   {
      
      private static const FLOWER_BUILDING_NAME:String = "flowershed";
      
      private static const FLOWER_BUILDING_CASH_NAME:String = "flowershed_cash";
      
      private static const COVE_FLOWER_BUILDING_NAME:String = "xcoveflowershed";
      
      private static const COVE_FLOWER_BUILDING_CASH_NAME:String = "xcoveflowershed_cash";
      
      protected var m_buildingName:String;
      
      public function BuyPottingShedPopup(buildingName:String)
      {
         var message:String = ZLocUtils.t("Dialogs","BuyHarvestStorage_" + buildingName);
         super(message,GenericPopup.TYPE_YESNO,this.onBuyPottingShed);
         this.m_buildingName = buildingName;
      }
      
      private function onBuyPottingShed(event:GenericPopupEvent) : void
      {
         var itemNames:Array = null;
         if(event.button == GenericPopup.YES)
         {
            itemNames = [this.m_buildingName];
            if(FLOWER_BUILDING_NAME == this.m_buildingName)
            {
               if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_FISHERMAN)
               {
                  itemNames.push(COVE_FLOWER_BUILDING_CASH_NAME);
               }
               else
               {
                  itemNames.push(FLOWER_BUILDING_CASH_NAME);
               }
            }
            if(FLOWER_BUILDING_CASH_NAME == this.m_buildingName)
            {
               if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_FISHERMAN)
               {
                  itemNames.push(COVE_FLOWER_BUILDING_NAME);
               }
               else
               {
                  itemNames.push(FLOWER_BUILDING_NAME);
               }
            }
            UI.displayMiniMarketDialog(itemNames,"unknown","building",this.onMarketCloseClick);
            FarmStatsManager.count("harvestStorage",this.m_buildingName,"buy_storage_dialog","gift_clicker","click_buy");
         }
         else
         {
            Global.player.setCanShowHarvestBuildingFeed(this.m_buildingName,true);
            FarmStatsManager.count("harvestStorage",this.m_buildingName,"buy_storage_dialog","gift_clicker","click_cancel");
         }
      }
      
      private function onMarketCloseClick(isCloseFromBuy:Boolean) : void
      {
         if(!isCloseFromBuy)
         {
            Global.player.setCanShowHarvestBuildingFeed(this.m_buildingName,true);
         }
      }
   }
}

