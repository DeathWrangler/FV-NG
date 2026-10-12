package Transactions
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   
   public class TBuyTurboChargers extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      protected var m_isGift:Boolean;
      
      public function TBuyTurboChargers(item:String, isGift:Boolean = false)
      {
         super();
         this.m_isGift = isGift;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(!this.hasTractor() && this.m_isGift)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","MustOwnVehicleGift"),GenericPopup.TYPE_OK,null,"",true);
         }
         else
         {
            this.onInit();
         }
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.buyTurboChargers",this.m_item.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_isGift)
         {
            Global.player.removeGift(null,this.m_item.name);
            UI.displayGiftBoxWindow();
         }
      }
      
      private function hasTractor() : Boolean
      {
         return Global.world.getEquipment() != null || Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME;
      }
      
      private function onInit() : void
      {
         var addedChargers:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            addedChargers = this.m_item.getNumberFromDataSource("count");
         }
         else
         {
            addedChargers = Number(this.m_item.xml.count);
         }
         Global.player.turboChargers += addedChargers;
         if(!this.m_isGift)
         {
            if(this.m_item.marketIsWorldCurrency || this.m_item.marketIsBerry)
            {
               Global.player.updateWorldCurrency(this.m_item.currency,-this.m_item.cost);
            }
            else
            {
               Global.player.gold -= this.m_item.cost;
               Global.player.cash -= this.m_item.cash;
            }
         }
      }
   }
}

