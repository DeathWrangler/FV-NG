package Widgets.Slots.Charity
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.MultiDonateManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.StaticWidgetTooltip;
   import Widgets.Windows.Charity.MultiDonateThanksWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class FCMultiDonateSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String = null;
      
      private var m_slotItemName:String = null;
      
      private var m_slotItem:FarmItem = null;
      
      private var m_slotCost:int = 0;
      
      private var m_slotNum:int = 0;
      
      private var m_checkBoxFrame:ZwFrame = null;
      
      private var m_checkmarkFrame:ZwFrame = null;
      
      private var m_titleText:ZwTextField = null;
      
      private var m_charityImageFrame:FarmButton = null;
      
      private var m_charityImageTooltipTitle:ZwTextField = null;
      
      private var m_charityImageTooltipBody:ZwTextField = null;
      
      private var m_bodyText:ZwTextField = null;
      
      private var m_itemIcon:FarmIcon = null;
      
      private var m_contributeButton:FarmAnimatedCashButton = null;
      
      private var m_prizeTooltipTitle:ZwTextField = null;
      
      private var m_prizeTooltipSub:ZwTextField = null;
      
      private var m_prizeTooltipInfo:ZwTextField = null;
      
      private var m_prizeTooltipSubInfo1:ZwTextField = null;
      
      private var m_prizeTooltipSubInfo2:ZwTextField = null;
      
      private var m_prizeTooltipIcon:FarmIcon = null;
      
      public function FCMultiDonateSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         var tooltipFrame:ZwFrame = null;
         var prizeTipFrame:ZwFrame = null;
         super(element);
         this.m_titleText = addWidget(new ZwTextField(m_element.title_tf,"")) as ZwTextField;
         if(m_element.charityIcon_mc)
         {
            this.m_charityImageFrame = addWidget(new FarmButton(m_element.charityIcon_mc,this.onClickCharityImage)) as FarmButton;
            (this.m_charityImageFrame.element as MovieClip).buttonMode = true;
         }
         if(m_element.campTip_0_mc)
         {
            tooltipFrame = new ZwFrame(m_element.campTip_0_mc);
            this.m_charityImageTooltipTitle = tooltipFrame.addWidget(new ZwTextField(m_element.campTip_0_mc.tip_title_tf,"")) as ZwTextField;
            this.m_charityImageTooltipBody = tooltipFrame.addWidget(new ZwTextField(m_element.campTip_0_mc.tip_body_tf,"")) as ZwTextField;
            this.m_charityImageFrame.attachTooltip(new StaticWidgetTooltip(tooltipFrame));
            this.m_charityImageFrame.registerEventListener(MouseEvent.ROLL_OVER,this.onSlotOver);
         }
         if(m_element.generic_tf)
         {
            this.m_bodyText = addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","contributeAndReceive"))) as ZwTextField;
         }
         this.m_itemIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         if(m_element.accept_bt)
         {
            this.m_contributeButton = addWidget(new FarmAnimatedCashButton(m_element.accept_bt,"","",this.onContribute,false,false,true)) as FarmAnimatedCashButton;
         }
         if(Boolean(m_element.checkBox_mc) && Boolean(m_element.checkBox_mc.checkmark_mc))
         {
            this.m_checkBoxFrame = addWidget(new ZwFrame(m_element.checkBox_mc)) as ZwFrame;
            this.m_checkmarkFrame = this.m_checkBoxFrame.addWidget(new ZwFrame(m_element.checkBox_mc.checkmark_mc)) as ZwFrame;
         }
         if(m_element.prizeTip_mc)
         {
            prizeTipFrame = new ZwFrame(m_element.prizeTip_mc);
            this.m_prizeTooltipTitle = prizeTipFrame.addWidget(new ZwTextField(m_element.prizeTip_mc.title_tf)) as ZwTextField;
            this.m_prizeTooltipSub = prizeTipFrame.addWidget(new ZwTextField(m_element.prizeTip_mc.generic_0_tf)) as ZwTextField;
            this.m_prizeTooltipInfo = prizeTipFrame.addWidget(new ZwTextField(m_element.prizeTip_mc.info_tf,"",true)) as ZwTextField;
            this.m_prizeTooltipSubInfo2 = prizeTipFrame.addWidget(new ZwTextField(m_element.prizeTip_mc.generic_2_tf)) as ZwTextField;
            this.m_itemIcon.attachTooltip(new StaticWidgetTooltip(prizeTipFrame));
            this.m_itemIcon.registerEventListener(MouseEvent.ROLL_OVER,this.onSlotOver);
         }
      }
      
      private function onSlotOver(event:MouseEvent) : void
      {
         var parentElement:DisplayObjectContainer = null;
         if(!event.isRelatedObjectInaccessible)
         {
            parentElement = this.element.parent;
            parentElement.setChildIndex(this.element as MovieClip,parentElement.numChildren - 1);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_featureName = data.featureName;
         this.m_slotItemName = data.itemName;
         this.m_slotNum = data.slotNum;
         var slotItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(data.itemName);
         if(slotItem != null)
         {
            this.m_slotItem = slotItem;
            this.m_slotCost = data.itemCost;
            if(this.m_titleText)
            {
               this.m_titleText.visible = true;
               this.m_titleText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_slot_" + this.m_slotNum + "_title");
            }
            if(this.m_charityImageFrame)
            {
               this.m_charityImageFrame.visible = true;
            }
            if(this.m_bodyText)
            {
               this.m_bodyText.visible = true;
               if(data.isBonus)
               {
                  this.m_bodyText.text = ZLocUtils.t("Dialogs","supportAll3");
               }
            }
            if(this.m_contributeButton)
            {
               this.m_contributeButton.visible = true;
               this.m_contributeButton.text = ZLocUtils.t("Dialogs","Accept_btn_" + this.m_featureName);
               this.m_contributeButton.setAmountText(this.m_slotCost.toString());
            }
            if(Boolean(this.m_charityImageTooltipTitle) && Boolean(this.m_charityImageTooltipBody))
            {
               this.m_charityImageTooltipTitle.text = ZLocUtils.t("Dialogs",this.m_featureName + "_campTip_" + this.m_slotNum + "_title");
               this.m_charityImageTooltipBody.text = ZLocUtils.t("Dialogs",this.m_featureName + "_campTip_" + this.m_slotNum + "_body");
            }
            if(Boolean(this.m_checkBoxFrame) && Boolean(this.m_checkmarkFrame) && MultiDonateManager.getInstance(this.m_featureName).isClaimed(this.m_slotItemName))
            {
               this.m_checkBoxFrame.visible = true;
               this.m_checkmarkFrame.visible = true;
            }
            this.m_itemIcon.loadIcon(this.m_slotItem.icon);
            this.m_itemIcon.visible = true;
            if(this.m_prizeTooltipTitle)
            {
               this.m_prizeTooltipTitle.text = ZLocUtils.t("Dialogs",this.m_featureName + "_prizeTooltip_" + this.m_slotNum + "_title");
               this.m_prizeTooltipSub.text = ZLocUtils.t("Dialogs",this.m_featureName + "_prizeTooltip_" + this.m_slotNum + "_body0");
               this.m_prizeTooltipInfo.text = ZLocUtils.t("Dialogs",this.m_featureName + "_prizeTooltip_" + this.m_slotNum + "_body1");
               this.m_prizeTooltipSubInfo2.text = ZLocUtils.t("Dialogs",this.m_featureName + "_prizeTooltip_info");
            }
         }
         else
         {
            this.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_titleText = null;
         this.m_bodyText = null;
         this.m_charityImageFrame = null;
         this.m_charityImageTooltipBody = null;
         this.m_charityImageTooltipTitle = null;
         this.m_contributeButton = null;
         this.m_prizeTooltipIcon = null;
         this.m_prizeTooltipInfo = null;
         this.m_prizeTooltipSub = null;
         this.m_prizeTooltipSubInfo1 = null;
         this.m_prizeTooltipSubInfo2 = null;
         this.m_prizeTooltipTitle = null;
         this.m_itemIcon = null;
         this.m_titleText = null;
         super.release();
      }
      
      private function onContribute(event:Event) : void
      {
         var donationSuccess:Boolean = false;
         if(this.m_slotItemName)
         {
            donationSuccess = MultiDonateManager.getInstance(this.m_featureName).buyItemForCharity(this.m_slotItemName,this.showThanksDialog);
            if(donationSuccess)
            {
               if(Boolean(this.m_checkBoxFrame) && Boolean(this.m_checkmarkFrame))
               {
                  this.m_checkBoxFrame.visible = true;
                  this.m_checkmarkFrame.visible = true;
               }
            }
         }
         else
         {
            GlobalEngine.info("Donate","Trying to contribute with no item");
         }
      }
      
      private function showThanksDialog(result:Object) : void
      {
         var claimedBonus:Boolean = false;
         var bonusName:String = null;
         if(Boolean(result && result.hasOwnProperty("feed")) && Boolean(result.hasOwnProperty("itemName")) && Boolean(result["feed"].hasOwnProperty("rewardLink")) && Boolean(result["feed"].hasOwnProperty("rewardName")))
         {
            claimedBonus = MultiDonateManager.getInstance(this.m_featureName).tryClaimRewardBonus();
            bonusName = null;
            if(claimedBonus)
            {
               bonusName = MultiDonateManager.getInstance(this.m_featureName).bonusItemName;
            }
            UI.displayPopup(new MultiDonateThanksWindow(this.m_featureName,result["itemName"],result["feed"]["rewardLink"],result["feed"]["rewardName"],bonusName));
         }
      }
      
      protected function onClickCharityImage(event:Event) : void
      {
         FarmStatsManager.count(this.m_featureName,"tooltip","click","charity" + (this.m_slotNum + 1));
         var url:String = ZLocUtils.t("Dialogs",this.m_featureName + "_ClickHereUrl_" + this.m_slotNum);
         navigateToURL(new URLRequest(url),"_blank");
      }
   }
}

