package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FuelItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   
   public class TBuyFuel extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      protected var m_isGift:Boolean;
      
      public function TBuyFuel(item:String, isGift:Boolean = false)
      {
         var count:Number = NaN;
         super();
         this.m_isGift = isGift;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         var addedEnergy:Number = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            count = this.m_item.getNumberFromDataSource("count");
         }
         else
         {
            count = Number(this.m_item.xml.count);
         }
         if(this.m_isGift)
         {
            if(FuelItem.OwnsFuelVehicle())
            {
               Global.player.removeGift(null,this.m_item.name);
               addedEnergy = count * Global.player.energyMax;
               Global.player.energy += addedEnergy;
               UI.displayGiftBoxWindow();
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","MustOwnVehicleGift"),GenericPopup.TYPE_OK,this.onAcceptVehicleNeeded,"",true);
            }
         }
         else
         {
            addedEnergy = count * Global.player.energyMax;
            Global.player.energy += addedEnergy;
            Global.player.gold -= this.m_item.cost;
            Global.player.cash -= this.m_item.cash;
         }
         if(addedEnergy > 0)
         {
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_AddEnergy",{"fuelNum":addedEnergy}));
         }
         else
         {
            canPerform = false;
         }
      }
      
      private function onAcceptVehicleNeeded(event:GenericPopupEvent) : void
      {
         UI.displayMarketDialog("unknown","vehicle",null,"all");
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.buyFuel",this.m_item.name,this.m_isGift);
      }
      
      override protected function onComplete(result:Object) : void
      {
      }
      
      private function onInit() : void
      {
      }
   }
}

