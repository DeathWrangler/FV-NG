package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.GetVillageCurrencySlot;
   
   public class GetVillageCurrencyWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/Village/FV_villageCoin_3_panel_packages.swf";
      
      private static const ZLOC_PREFIX:String = "VillageCoinPurchase";
      
      public static const VC_DIALOG_STAT:String = "vc_dialog";
      
      public function GetVillageCurrencyWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var title:String = null;
         super.postLoadComplete();
         if(m_window.title_tf != null)
         {
            title = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,ZLOC_PREFIX + "Title");
            addWidget(new ZwTextField(m_window.title_tf,title));
         }
         var packages:Array = Global.farmGameSettingsManager.getFarmItemsArrayByNames(["villageCoins_exchange1","villageCoins_exchange2","villageCoins_exchange3"]);
         addWidget(new GenericSlotContainerFrame(m_window.slots_center_mc,GetVillageCurrencySlot,packages,this));
         StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,GetVillageCurrencyWindow.VC_DIALOG_STAT,"impressions");
      }
      
      override public function close() : void
      {
         StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,GetVillageCurrencyWindow.VC_DIALOG_STAT,"close");
         super.close();
      }
   }
}

