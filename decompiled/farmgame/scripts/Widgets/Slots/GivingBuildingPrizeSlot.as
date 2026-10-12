package Widgets.Slots
{
   import Classes.BuildingItemUseMediator;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.SuperBuildingCompleteEvent;
   import Managers.FarmStatsManager;
   import Managers.OlyInnovationManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.GivingBuildingWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GivingBuildingPrizeSlot extends ZwSlotFrame
   {
      
      private var m_tooltipFrame:ZwFrame;
      
      private var m_activeFrame:ZwFrame;
      
      private var m_redeemedFrame:ZwFrame;
      
      private var m_lockedFrame:ZwFrame;
      
      private var m_presentFrame:ZwFrame;
      
      private var m_rewardNumText:ZwTextField;
      
      private var m_redeemedBuyButton:FarmAnimatedCashButton;
      
      private var m_activeBuyButton:FarmAnimatedCashButton;
      
      private var m_redeemedItemTitleText:ZwTextField;
      
      private var m_redeemedGenericText:ZwTextField;
      
      private var m_activeItemTitleText:ZwTextField;
      
      private var m_lockedItemTitleText:ZwTextField;
      
      private var m_lockedBodyText:ZwTextField;
      
      private var m_activeCountNeededText:ZwTextField;
      
      private var m_activeUseButton:FarmAnimatedTextButton;
      
      private var m_presentIcon:FarmIcon;
      
      private var m_data:Object;
      
      protected var m_owner:DisplayObject;
      
      public function GivingBuildingPrizeSlot(element:DisplayObject, owner:DisplayObject)
      {
         super(element);
         this.m_owner = owner;
         addWidget(this.m_presentFrame = new ZwFrame(m_element.present_mc));
         this.m_presentFrame.addWidget(this.m_rewardNumText = new ZwTextField(m_element.present_mc.number_tf,""));
         addWidget(this.m_tooltipFrame = new ZwFrame(m_element.tooltip_mc));
         this.m_tooltipFrame.addWidget(this.m_activeFrame = new ZwFrame(m_element.tooltip_mc.tooltipUnlocked_mc)) as ZwFrame;
         this.m_activeFrame.addWidget(this.m_activeItemTitleText = new ZwTextField(m_element.tooltip_mc.tooltipUnlocked_mc.header_tf,""));
         this.m_activeFrame.addWidget(this.m_activeBuyButton = new FarmAnimatedCashButton(m_element.tooltip_mc.tooltipUnlocked_mc.buy_bt,ZLocUtils.t("Dialogs","Open"),"",this.onBuyActive));
         this.m_activeFrame.addWidget(this.m_activeUseButton = new FarmAnimatedTextButton(m_element.tooltip_mc.tooltipUnlocked_mc.use_bt,"",this.onUse));
         this.m_activeFrame.addWidget(this.m_activeCountNeededText = new ZwTextField(m_element.tooltip_mc.tooltipUnlocked_mc.count_tf,""));
         this.m_tooltipFrame.addWidget(this.m_redeemedFrame = new ZwFrame(m_element.tooltip_mc.tooltipRedeemed_mc)) as ZwFrame;
         this.m_redeemedFrame.addWidget(this.m_redeemedItemTitleText = new ZwTextField(m_element.tooltip_mc.tooltipRedeemed_mc.header_tf,""));
         this.m_redeemedFrame.addWidget(this.m_redeemedGenericText = new ZwTextField(m_element.tooltip_mc.tooltipRedeemed_mc.generic_tf,""));
         this.m_redeemedFrame.addWidget(this.m_redeemedBuyButton = new FarmAnimatedCashButton(m_element.tooltip_mc.tooltipRedeemed_mc.buy_bt,ZLocUtils.t("Dialogs","Buy"),"",this.onBuyRedeemed));
         this.m_redeemedFrame.addWidget(new ZwFrame(m_element.tooltip_mc.tooltipRedeemed_mc.checkmark_mc));
         this.m_tooltipFrame.addWidget(this.m_lockedFrame = new ZwFrame(m_element.tooltip_mc.tooltipLocked_mc)) as ZwFrame;
         this.m_lockedFrame.addWidget(this.m_lockedItemTitleText = new ZwTextField(m_element.tooltip_mc.tooltipLocked_mc.header_tf,""));
         this.m_lockedFrame.addWidget(this.m_lockedBodyText = new ZwTextField(m_element.tooltip_mc.tooltipLocked_mc.generic_tf,""));
         m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverCallback,false,0,true);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutCallback,false,0,true);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_presentFrame.visible = true;
         this.m_tooltipFrame.visible = false;
         this.m_data = data;
         var building:FeatureBuilding = data.building as FeatureBuilding;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(data.award);
         this.m_redeemedItemTitleText.text = rewardItem.friendlyTitle;
         this.m_redeemedGenericText.text = ZLocUtils.t("Dialogs",building.bldgName + "Redeemed");
         var partItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(data.partName);
         var cashCost:Number = partItem.cash;
         this.m_redeemedBuyButton.setAmountText(rewardItem.cash.toString());
         this.m_activeItemTitleText.text = ZLocUtils.t("Dialogs",building.bldgName + "UnopenedTitle");
         var progress:int = building.getExpansionPartCount(Global.farmGameSettingsManager.getFarmItemCodeByName(data.partName));
         var partsLeft:int = data.partNeeded - progress;
         var totalParts:int = Global.player.getGiftCountForItem(data.partName);
         this.m_activeCountNeededText.text = progress + "/" + data.partNeeded;
         if(totalParts == 0)
         {
            this.m_activeUseButton.text = "Use";
            this.m_activeUseButton.enabled = false;
         }
         else
         {
            this.m_activeUseButton.text = "Use " + Math.min(partsLeft,totalParts);
         }
         this.m_activeBuyButton.setAmountText(building.expand.getExpandCashNeeded().toString());
         this.m_lockedItemTitleText.text = ZLocUtils.t("Dialogs",building.bldgName + "UnopenedTitle");
         this.m_lockedBodyText.text = ZLocUtils.t("Dialogs",building.bldgName + "LockedLevel");
         this.m_rewardNumText.text = (data.level - 1).toString();
         var currentLevel:int = building.storageLevel;
         if(this.m_data.level <= currentLevel)
         {
            this.unwrapGift();
         }
      }
      
      private function unwrapGift() : void
      {
         var rewardItem:FarmItem = null;
         this.m_presentFrame.element.gotoAndStop(2);
         if(this.m_presentFrame.element.hasOwnProperty("icon_mc") && this.m_data != null)
         {
            if(!this.m_presentIcon)
            {
               this.m_presentFrame.addWidget(this.m_presentIcon = new FarmIcon(m_element.present_mc.icon_mc));
            }
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.award);
            if(rewardItem != null)
            {
               this.m_presentIcon.loadIcon(rewardItem.iconUrl);
            }
         }
      }
      
      override public function release() : void
      {
         this.m_tooltipFrame = null;
         this.m_activeFrame = null;
         this.m_redeemedFrame = null;
         this.m_lockedFrame = null;
         this.m_presentFrame = null;
         this.m_rewardNumText = null;
         this.m_redeemedBuyButton = null;
         this.m_activeBuyButton = null;
         this.m_redeemedItemTitleText = null;
         this.m_redeemedGenericText = null;
         this.m_activeItemTitleText = null;
         this.m_lockedItemTitleText = null;
         this.m_lockedBodyText = null;
         this.m_activeCountNeededText = null;
         this.m_activeUseButton = null;
         this.m_presentIcon = null;
         m_element.removeEventListener(MouseEvent.MOUSE_OVER);
         m_element.removeEventListener(MouseEvent.MOUSE_OUT);
         this.m_data = null;
         this.m_owner = null;
         super.release();
      }
      
      private function onBuyActive(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.award);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_data.building.bldgName + "BuyActiveConfirmPopup",{"cashQuantity":this.m_data.building.expand.getExpandCashNeeded()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onActiveConfirmBuyPopupClose,"",true);
         this.m_activeBuyButton.enabled = false;
      }
      
      private function onBuyRedeemed(event:Event) : void
      {
         var item:FarmItem = null;
         if(this.m_data)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.award);
            UI.displayMessage(ZLocUtils.t("Dialogs",this.m_data.building.bldgName + "BuyRedeemedConfirmPopup",{
               "cashQuantity":item.cash,
               "item":item.friendlyTitle
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onRedeemedConfirmBuyPopupClose,"",true);
         }
         this.m_redeemedBuyButton.enabled = false;
      }
      
      private function onActiveConfirmBuyPopupClose(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         var cash_req:int = 0;
         var buildingItemName:String = null;
         if(event.button == GenericPopup.YES)
         {
            if(this.m_data)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.award);
               cash_req = int(this.m_data.building.expand.getExpandCashNeeded());
               if(Global.player.canBuyCash(cash_req))
               {
                  (this.m_data.building as FeatureBuilding).expand.frictionlessExpand();
                  this.m_activeUseButton.enabled = false;
                  this.m_activeBuyButton.enabled = false;
                  (this.m_owner as GivingBuildingWindow).refreshWidgets();
                  if((this.m_data.building as FeatureBuilding).hasReachedMaxExpansionLevel())
                  {
                     GlobalEventManager.getInstance().dispatchEvent(new Event(OlyInnovationManager.EVENT_HB_COMPLETE));
                     buildingItemName = (this.m_data.building as FeatureBuilding).getItemName();
                     GlobalEventManager.getInstance().dispatchEvent(new SuperBuildingCompleteEvent(SuperBuildingCompleteEvent.BUILDING_COMPLETED,{"name":buildingItemName}));
                  }
               }
            }
         }
         this.m_activeBuyButton.enabled = true;
      }
      
      private function onRedeemedConfirmBuyPopupClose(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         if(event.button == GenericPopup.YES)
         {
            if(this.m_data)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.award);
               if(Global.player.canBuyCash(item.cash))
               {
                  TransactionManager.addTransaction(new TBuyItemPutGiftbox(item,Currency.CASH,1,true,true,null,true),true);
               }
            }
         }
         this.m_redeemedBuyButton.enabled = true;
      }
      
      private function onUse(event:Event) : void
      {
         var building:FeatureBuilding = this.m_data.building as FeatureBuilding;
         var progress:int = building.getExpansionPartCount(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_data.partName));
         var left:int = this.m_data.partNeeded - progress;
         var totalParts:int = Global.player.getGiftCountForItem(this.m_data.partName);
         var countToAdd:int = Math.min(left,totalParts);
         BuildingItemUseMediator.getInstance().mediate(this.m_data.partName,true,building,true,true,countToAdd);
         if(left == countToAdd)
         {
            this.unwrapGift();
            this.m_activeUseButton.enabled = false;
            this.m_activeBuyButton.enabled = false;
         }
         else
         {
            this.m_activeUseButton.enabled = false;
         }
         (this.m_owner as GivingBuildingWindow).refreshWidgets();
         FarmStatsManager.count(building.bldgName,this.m_data.partName,"Use",countToAdd.toString());
      }
      
      private function onMouseOverCallback(event:MouseEvent) : void
      {
         var currentLevel:int = 0;
         this.m_tooltipFrame.visible = true;
         if(this.m_data)
         {
            currentLevel = (this.m_data.building as FeatureBuilding).storageLevel;
            if(this.m_data.level < currentLevel + 1)
            {
               this.m_redeemedFrame.visible = true;
               this.m_lockedFrame.visible = false;
               this.m_activeFrame.visible = false;
            }
            else if(this.m_data.level == currentLevel + 1)
            {
               this.m_redeemedFrame.visible = false;
               this.m_lockedFrame.visible = false;
               this.m_activeFrame.visible = true;
            }
            else
            {
               this.m_redeemedFrame.visible = false;
               this.m_lockedFrame.visible = true;
               this.m_activeFrame.visible = false;
            }
         }
      }
      
      private function onMouseOutCallback(event:MouseEvent) : void
      {
         this.m_tooltipFrame.visible = false;
      }
   }
}

