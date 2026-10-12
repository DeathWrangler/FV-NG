package Widgets.Windows.DecoPoints
{
   import Classes.Constants.Experiments;
   import Classes.PhotoGalleryImageData;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.MarketEvent;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.View.Tooltips.ToolTipManager;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class DecoPointsVoteTab extends ZwFrame
   {
      
      public static const LEFT_IMAGE_INDEX:Number = 0;
      
      public static const RIGHT_IMAGE_INDEX:Number = 1;
      
      private var m_mgr:DecoPointsManager;
      
      private var m_leftVoteSlot:DecoPointsGallerySlot;
      
      private var m_rightVoteSlot:DecoPointsGallerySlot;
      
      private var m_emptyGallery:ZwFrame;
      
      private var m_miniMarketButton:FarmAnimatedTextButton;
      
      private var m_combinedItemCodes:Array;
      
      public function DecoPointsVoteTab(element:DisplayObject, decomgr:DecoPointsManager)
      {
         var decoPoints:String = null;
         this.m_combinedItemCodes = new Array();
         super(element);
         this.m_mgr = decomgr;
         if(m_element.generic_0_tf)
         {
            this.addWidget(new FarmTextField(m_element.generic_0_tf,this.m_mgr.getWeeklyPhotoContestTitle()));
         }
         if(m_element.generic_1_tf)
         {
            decoPoints = ZLocUtils.t("FarmGame",Global.worldManager.currentWorldScoreId);
            this.addWidget(new FarmTextField(m_element.generic_1_tf,ZLocUtils.t("Dialogs","DPVoteTab_DPRewardMessage",{"worldscore":decoPoints})));
         }
         if(m_element.slot_0_mc)
         {
            this.m_leftVoteSlot = new DecoPointsGallerySlot(m_element.slot_0_mc,this.actOnGalleryData);
            this.addWidget(this.m_leftVoteSlot,true);
         }
         if(m_element.slot_1_mc)
         {
            this.m_rightVoteSlot = new DecoPointsGallerySlot(m_element.slot_1_mc,this.actOnGalleryData);
            this.addWidget(this.m_rightVoteSlot,true);
         }
         if(m_element.challenge_tf)
         {
            this.addWidget(new FarmTextField(m_element.challenge_tf,this.m_mgr.getWeeklyPhotoContestTheme()));
         }
         if(Boolean(m_element.empty_mc) && Boolean(m_element.empty_mc.generic_0_tf))
         {
            this.m_emptyGallery = new ZwFrame(m_element.empty_mc);
            this.m_emptyGallery.addWidget(new FarmTextField(m_element.empty_mc.generic_0_tf,ZLocUtils.t("Dialogs","DPVoteTab_EmptyGallery")));
            this.addWidget(this.m_emptyGallery,false);
         }
         if(m_element.market_bt)
         {
            ToolTipManager.getInstance().addToolTip(m_element.market_bt,ZLocUtils.t("Dialogs","DPVoteTab_MiniMarketButtonToolTip"));
            this.m_miniMarketButton = addWidget(new FarmAnimatedTextButton(m_element.market_bt,ZLocUtils.t("Dialogs","DPVoteTab_MiniMarketButtonText"),this.onOpenMiniMarket)) as FarmAnimatedTextButton;
         }
      }
      
      public function refreshGalleryImages(fetch:Boolean = false) : void
      {
         this.disableUI();
         if(Boolean(DecoPointsManager.instance.isGalleryImagesAvailableToVote(fetch)) && Boolean(this.m_leftVoteSlot) && Boolean(this.m_rightVoteSlot))
         {
            this.m_leftVoteSlot.loadIconToVote(LEFT_IMAGE_INDEX);
            this.m_rightVoteSlot.loadIconToVote(RIGHT_IMAGE_INDEX);
            this.enableUI();
         }
         if(Boolean(this.m_emptyGallery) && Boolean(!DecoPointsManager.instance.isGalleryImagesAvailableToVote()) && !DecoPointsManager.instance.waitingOnCallBack())
         {
            this.m_emptyGallery.visible = true;
         }
         else
         {
            this.m_emptyGallery.visible = false;
         }
      }
      
      private function disableUI() : void
      {
         this.m_leftVoteSlot.disableUI();
         this.m_rightVoteSlot.disableUI();
         this.m_miniMarketButton.visible = false;
      }
      
      private function enableUI() : void
      {
         this.enabled = true;
         this.m_leftVoteSlot.enableUI();
         this.m_rightVoteSlot.enableUI();
         this.updateMiniMarketButton();
      }
      
      public function actOnGalleryData(action:Number, slot:DecoPointsGallerySlot) : void
      {
         var leftGalleryData:PhotoGalleryImageData = null;
         var rightGalleryData:PhotoGalleryImageData = null;
         var obj:Object = null;
         var key:String = "";
         var votes:Object = new Object();
         if(this.m_leftVoteSlot != null && this.m_rightVoteSlot != null && slot != null)
         {
            leftGalleryData = this.m_leftVoteSlot.data;
            rightGalleryData = this.m_rightVoteSlot.data;
            votes[leftGalleryData.key] = DecoPointsManager.SUBMIT_GALLERY_SEEN;
            votes[rightGalleryData.key] = DecoPointsManager.SUBMIT_GALLERY_SEEN;
            key = slot.data.key;
            votes[key] = action;
            obj = new Object();
            obj["eventId"] = DecoPointsManager.instance.getWeeklyContestName();
            obj["votes"] = votes;
            DecoPointsManager.instance.actOnGalleryData(obj);
            this.m_leftVoteSlot.resetSlotData();
            this.m_rightVoteSlot.resetSlotData();
            this.refreshGalleryImages(true);
         }
      }
      
      public function enableVoteTab() : void
      {
         if(!this.m_mgr.isGalleryImagesAvailableToVote())
         {
            this.enabled = false;
         }
         this.refreshGalleryImages();
      }
      
      private function onOpenMiniMarket(event:Event) : void
      {
         var itemNames:Array = null;
         var itemCodesLength:int = 0;
         var i:int = 0;
         var miniMarketWindow:MarketWindow = null;
         if(Boolean(this.m_combinedItemCodes) && this.m_combinedItemCodes.length > 0)
         {
            itemNames = new Array();
            itemCodesLength = int(this.m_combinedItemCodes.length);
            FarmStatsManager.count("deco_points","","decorateNow","Vote","","",1);
            for(i = 0; i < itemCodesLength; i++)
            {
               itemNames.push(Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_combinedItemCodes[i]));
            }
            miniMarketWindow = UI.displayMiniMarketDialog(itemNames) as MarketWindow;
            miniMarketWindow.addEventListener(MarketEvent.MARKET_BUY,DecoPointsManager.closeMainWindowOnPurchase);
         }
      }
      
      private function updateMiniMarketButton() : void
      {
         this.m_miniMarketButton.visible = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DP_ITEM_TAGGING) >= 1)
         {
            this.combineItemCodes();
            this.m_miniMarketButton.visible = this.m_combinedItemCodes.length > 0;
         }
      }
      
      private function combineItemCodes() : void
      {
         var numLeftPhotoItemCodes:int = 0;
         var numRightPhotoItemCodes:int = 0;
         var leftData:PhotoGalleryImageData = this.m_leftVoteSlot.data;
         var rightData:PhotoGalleryImageData = this.m_rightVoteSlot.data;
         this.m_combinedItemCodes = new Array();
         if(Boolean(leftData) && Boolean(rightData))
         {
            numLeftPhotoItemCodes = int(leftData.itemCodes.length);
            numRightPhotoItemCodes = int(rightData.itemCodes.length);
            if(numLeftPhotoItemCodes > 0 && numRightPhotoItemCodes > 0)
            {
               this.m_combinedItemCodes = leftData.itemCodes.concat(rightData.itemCodes);
            }
            else if(numLeftPhotoItemCodes > 0)
            {
               this.m_combinedItemCodes = leftData.itemCodes;
            }
            else if(numRightPhotoItemCodes > 0)
            {
               this.m_combinedItemCodes = rightData.itemCodes;
            }
            this.m_combinedItemCodes = DecoPointsManager.validateAndSortItemCodes(this.m_combinedItemCodes);
         }
      }
   }
}

