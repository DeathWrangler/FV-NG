package Widgets.Slots.BushelBaby
{
   import Classes.BushelBaby.BushelBabyNPC;
   import Classes.BushelBaby.BushelBabyNPCLevel;
   import Classes.Constants.ZLocConstants;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BushelBaby.BushelBabyOrderItemSlotContainerFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.WidgetTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BushelBabyNPCSlot extends ZwSlotFrame
   {
      
      private static const UNLOCKED_ALPHA:Number = 1;
      
      private static const LOCKED_ALPHA:Number = 0.6;
      
      protected var m_data:BushelBabyNPC;
      
      private var m_previewFrame:ResourcePreviewFrame;
      
      private var m_itemTitle:ZwTextField;
      
      private var m_stageText:ZwTextField;
      
      private var m_stageBar:FarmProgressBar;
      
      private var m_completeAllWidget:ZwWidget;
      
      private var m_lockWidget:ZwWidget;
      
      private var m_orderTooltip:WidgetTooltip;
      
      private var m_orderTooltipFrame:BushelBabyOrderItemSlotContainerFrame;
      
      private var m_mainTooltipFrame:ZwFrame;
      
      private var m_mainTooltipHeaderTextField:ZwTextField;
      
      private var m_mainTooltipSubheaderTextField:ZwTextField;
      
      private var m_replayTooltipButton:FarmAnimatedTextButton;
      
      private var m_unlockTooltipButton:FarmAnimatedCashButton;
      
      private var m_mainTooltip:WidgetTooltip;
      
      public function BushelBabyNPCSlot(element:DisplayObject)
      {
         super(element);
         m_element.hit_bt.visible = true;
         this.m_itemTitle = addWidget(new ZwTextField(m_element.item_tf)) as ZwTextField;
         this.m_previewFrame = addWidget(new ResourcePreviewFrame(m_element.icon_mc)) as ResourcePreviewFrame;
         m_element.icon_mc.mouseEnabled = m_element.icon_mc.mouseChildren = false;
         this.m_stageText = addWidget(new ZwTextField(m_element.stage_tf)) as ZwTextField;
         this.m_stageBar = addWidget(new FarmProgressBar(m_element.meter_mc)) as FarmProgressBar;
         this.m_lockWidget = addWidget(new ZwWidget(m_element.locked_mc),false) as ZwWidget;
         this.m_completeAllWidget = addWidget(new ZwWidget(m_element.complete_mc),false) as ZwWidget;
         addWidget(this.m_orderTooltipFrame = new BushelBabyOrderItemSlotContainerFrame(m_element.order_mc),false);
         this.m_orderTooltip = new WidgetTooltip(this.m_orderTooltipFrame);
         this.m_orderTooltip.fixed = true;
         this.m_orderTooltip.interactive = true;
         this.m_mainTooltipFrame = new ZwFrame(m_element.tooltip_mc) as ZwFrame;
         this.m_mainTooltipHeaderTextField = this.m_mainTooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.header_tf)) as ZwTextField;
         this.m_mainTooltipSubheaderTextField = this.m_mainTooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.subheader_tf)) as ZwTextField;
         this.m_unlockTooltipButton = this.m_mainTooltipFrame.addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.unlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSlotUnlock"),"",this.onUnlockButtonClick,true)) as FarmAnimatedCashButton;
         this.m_replayTooltipButton = this.m_mainTooltipFrame.addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.raise_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"QuestManagerV2_replayableCompletedQuestsReplayButtonText"),this.onReplayButtonClick)) as FarmAnimatedTextButton;
         this.m_mainTooltip = new WidgetTooltip(this.m_mainTooltipFrame);
         this.m_mainTooltip.fixed = true;
         this.m_mainTooltip.interactive = true;
      }
      
      override public function release() : void
      {
         this.m_previewFrame = null;
         this.m_lockWidget = null;
         this.m_mainTooltipHeaderTextField = null;
         this.m_mainTooltipSubheaderTextField = null;
         this.m_replayTooltipButton = null;
         this.m_mainTooltip = null;
         this.m_itemTitle = null;
         this.m_data = null;
         this.m_stageText = null;
         this.m_stageBar = null;
         this.m_completeAllWidget = null;
         this.m_orderTooltip = null;
         this.m_orderTooltipFrame = null;
         this.m_mainTooltipFrame = null;
         this.m_unlockTooltipButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as BushelBabyNPC;
         this.refresh(true);
      }
      
      public function refresh(reloadIcon:Boolean = false) : void
      {
         var currentLevel:BushelBabyNPCLevel = null;
         if(this.m_data)
         {
            currentLevel = this.m_data.getCurrentLevel();
            if(reloadIcon)
            {
               this.m_previewFrame.load(currentLevel.assetUrl,currentLevel.getFullExportName(),this.onAssetLoaded);
            }
            this.m_previewFrame.visible = true;
            this.m_itemTitle.text = currentLevel.friendlyItemTitle;
            this.m_stageText.text = this.m_data.currentLevelNum + " / " + this.m_data.totalLevels;
            this.m_stageBar.maximum = this.m_data.totalLevels;
            this.m_stageBar.progress = this.m_data.currentLevelNum;
            this.m_itemTitle.visible = this.m_stageBar.visible = this.m_stageText.visible = true;
            this.m_unlockTooltipButton.setAmountText(this.m_data.unlockCost.toString());
            this.m_mainTooltipHeaderTextField.text = this.m_data.friendlyTitle;
            this.m_orderTooltipFrame.refresh();
            this.refreshState();
         }
      }
      
      private function onAssetLoaded() : void
      {
         var bound:DisplayObject = null;
         var mc:MovieClip = this.m_previewFrame.exportedMovieClip;
         this.m_previewFrame.scale = 1;
         if(mc)
         {
            bound = m_element.icon_mc.bounds_mc;
            if(bound)
            {
               DisplayObjectUtils.fitDisplayObject(mc,bound.width,bound.height,true);
               if(mc.height > bound.height * 1.5)
               {
                  mc.scaleX = mc.scaleY = bound.height * 1.5 / mc.height;
               }
            }
            mc.y = -mc.height;
            mc.x = -mc.width / 2;
         }
      }
      
      public function refreshState() : void
      {
         if(Boolean(m_element) && Boolean(this.m_data))
         {
            if(this.m_data.unlocked)
            {
               this.m_previewFrame.alpha = UNLOCKED_ALPHA;
               this.m_lockWidget.visible = false;
               this.m_completeAllWidget.visible = this.m_data.hasCompletedBefore();
               if(this.m_data.complete && this.m_data.currentLevelNum >= this.m_data.totalLevels)
               {
                  if(m_tooltip != this.m_mainTooltip)
                  {
                     detachTooltip();
                     attachTooltip(this.m_mainTooltip);
                  }
                  this.m_mainTooltipSubheaderTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"playAgainToRaiseAnotherBaby");
                  this.m_mainTooltipSubheaderTextField.visible = true;
                  this.m_replayTooltipButton.visible = true;
                  this.m_unlockTooltipButton.visible = this.m_orderTooltipFrame.visible = false;
               }
               else
               {
                  if(m_tooltip != this.m_orderTooltip)
                  {
                     detachTooltip();
                     attachTooltip(this.m_orderTooltip);
                  }
                  this.m_orderTooltipFrame.populate(this.m_data.getCurrentLevel());
                  this.m_mainTooltipFrame.visible = this.m_unlockTooltipButton.visible = false;
               }
            }
            else
            {
               this.m_previewFrame.alpha = LOCKED_ALPHA;
               this.m_lockWidget.visible = true;
               if(m_tooltip != this.m_mainTooltip)
               {
                  detachTooltip();
                  attachTooltip(this.m_mainTooltip);
               }
               this.m_mainTooltipSubheaderTextField.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"UnlockNRaise",{"name":this.m_data.friendlyTitle});
               this.m_mainTooltipSubheaderTextField.visible = true;
               this.m_unlockTooltipButton.visible = this.m_unlockTooltipButton.enabled = this.m_data.canUnlock;
               this.m_replayTooltipButton.visible = this.m_orderTooltipFrame.visible = this.m_completeAllWidget.visible = false;
            }
         }
      }
      
      private function onReplayButtonClick(event:MouseEvent) : void
      {
         this.m_data.system.logStats("replay",this.m_data.animalName);
         this.m_data.resetLevel();
         this.refreshState();
         this.showOrderTooltip();
      }
      
      public function showOrderTooltip() : void
      {
         this.m_orderTooltipFrame.visible = true;
         this.m_mainTooltipFrame.visible = false;
         if(m_tooltip != this.m_orderTooltip)
         {
            detachTooltip();
            attachTooltip(this.m_orderTooltip);
         }
      }
      
      private function onUnlockButtonClick(event:MouseEvent) : void
      {
         this.m_data.system.logStats("unlock",this.m_data.animalName);
         var message:String = this.m_data.system.getLocalizedString("NPCTooltip_UnlockButton_Confirmation",{
            "cost":this.m_data.unlockCost,
            "npcName":this.m_data.friendlyTitle
         });
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"BushelBabyUnlockNPC",true);
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.m_data.buyUnlock();
            this.refreshState();
         }
      }
   }
}

