package Widgets.Windows.Crafting
{
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingStatsManager;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   
   public class ReconfigureStallWindow extends GenericPopup
   {
      
      private var m_bushelItemCode:String = "";
      
      private var m_marketStallId:int;
      
      public function ReconfigureStallWindow(bushelItemCode:String)
      {
         this.m_bushelItemCode = bushelItemCode;
         super(" ",GenericPopup.TYPE_ACCEPTCANCEL,this.onReconfigureClicked,"assets/dialogs/FV_GenericMedPopUp.swf");
         StatsManager.experimentGoal("fv_fm_reactivator_test","impressions");
      }
      
      override protected function onShow() : void
      {
         var newCropBuilding:MarketStallBuilding = null;
         var oldCrop:FarmItem = null;
         super.onShow();
         CraftingStatsManager.recordReplaceStallPageView();
         var newCrop:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_bushelItemCode);
         var existingCropBuilding:MarketStallBuilding = CraftingManager.getInstance().getMarketStallByBushel(this.m_bushelItemCode);
         if(existingCropBuilding == null)
         {
            newCropBuilding = CraftingManager.getInstance().getMarketStallNearestExpiration();
            if(newCropBuilding != null)
            {
               this.m_marketStallId = newCropBuilding.getId();
               oldCrop = Global.farmGameSettingsManager.getFarmItemByCode(newCropBuilding.bushelItemCode);
               this.m_message = ZLocUtils.t("Crafting","ReconfigureStallDialog_MainText",{
                  "itemA":ZLocUtils.tk_pk(oldCrop.friendlyName),
                  "itemB":ZLocUtils.tk_pk(newCrop.friendlyName)
               });
               this.setMessage();
               m_window.popupBox_mc.accept_bt.text = ZLocUtils.t("Crafting","ReconfigureStallDialog_AcceptButtonText");
               m_window.popupBox_mc.cancel_bt.text = ZLocUtils.t("Crafting","ReconfigureStallDialog_CancelButtonText");
            }
            else
            {
               this.close();
            }
         }
         else
         {
            this.close();
         }
      }
      
      private function onReconfigureClicked(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            CraftingStatsManager.recordReplaceStallAccept();
            CraftingManager.getInstance().reconfigureMarketStall(this.m_marketStallId,this.m_bushelItemCode);
         }
         this.close();
      }
   }
}

