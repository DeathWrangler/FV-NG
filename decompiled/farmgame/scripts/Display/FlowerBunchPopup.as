package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGiftFlowerDecorationNoShed;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FlowerBunchPopup extends Dialog
   {
      
      private var DIALOG_ASSET:String = "assets/dialogs/FV_GiftMission.swf";
      
      private var m_accept:GenericButton;
      
      private var m_reject:GenericButton;
      
      private var m_iconLoader:Loader;
      
      private var m_plotId:int;
      
      private var m_buildingName:String;
      
      private var m_seedName:String;
      
      private var m_harvestItemName:String;
      
      private var m_showBuyStorageDialog:Boolean;
      
      public function FlowerBunchPopup(buildingName:String, seedName:String, harvestItemName:String, plotId:int, showBuyStorage:Boolean)
      {
         this.m_buildingName = buildingName;
         this.m_seedName = seedName;
         this.m_harvestItemName = harvestItemName;
         this.m_plotId = plotId;
         m_dialogAsset = this.DIALOG_ASSET;
         this.m_showBuyStorageDialog = showBuyStorage;
         super(true);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.giftmission_mc.greeting_tf.text = ZLocUtils.t_pk("Dialogs:Harvested_" + this.m_buildingName);
         setTrackerKey("flowers-flowerGift");
         this.m_accept = new GenericButton(m_window.giftmission_mc.accept_bt,this.onOkClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","ShareHarvest");
         this.m_reject = new GenericButton(m_window.giftmission_mc.cancel_bt,this.onCancelClick);
         this.m_reject.text = ZLocUtils.t("Dialogs","Cancel");
         var iconUrl:String = Global.farmGameSettingsManager.getFarmItemByName(this.m_harvestItemName).icon;
         this.m_iconLoader = LoadingManager.load(iconUrl,this.onIconLoaded);
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.giftmission_mc.image_mc;
         iconMc.scaleX = iconMc.scaleY = 1;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_iconLoader.content;
         newIcon.x = -0.7 * newIcon.width;
         newIcon.y = newIcon.height / 3;
         iconMc.addChild(newIcon);
      }
      
      private function onOkClick(event:MouseEvent) : void
      {
         if(getTrackerEnabled())
         {
            FarmStatsManager.count("dialog",getTrackerKey(),"OK");
         }
         m_window.giftmission_mc.accept_bt.removeEventListener(MouseEvent.CLICK,this.onOkClick);
         m_window.giftmission_mc.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         event.stopPropagation();
         close();
         var seedXml:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_seedName);
         if(seedXml)
         {
            TransactionManager.addTransaction(new TGiftFlowerDecorationNoShed(this.m_plotId,seedXml.name,this.m_buildingName,this.displayBuyStorageDialog));
            Global.player.setCanShowHarvestBuildingFeed(this.m_buildingName,false);
         }
         FarmStatsManager.count("harvestStorage",this.m_buildingName,"first_harvest_gift_prompt","click_share");
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         if(getTrackerEnabled())
         {
            FarmStatsManager.count("dialog",getTrackerKey(),"Cancel");
         }
         m_window.giftmission_mc.accept_bt.removeEventListener(MouseEvent.CLICK,this.onOkClick);
         m_window.giftmission_mc.cancel_bt.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         event.stopPropagation();
         close();
         this.displayBuyStorageDialog();
         FarmStatsManager.count("harvestStorage",this.m_buildingName,"first_harvest_gift_prompt","click_cancel");
      }
      
      private function displayBuyStorageDialog() : void
      {
         if(this.m_showBuyStorageDialog)
         {
            UI.displayPopup(new BuyPottingShedPopup(this.m_buildingName));
         }
      }
   }
}

