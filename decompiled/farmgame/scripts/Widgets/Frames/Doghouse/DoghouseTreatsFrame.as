package Widgets.Frames.Doghouse
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.DoghouseManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class DoghouseTreatsFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_icon:FarmIcon;
      
      private var m_countTextField:FarmTextField;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_waitingFeedCallback:Boolean = false;
      
      public function DoghouseTreatsFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.treat_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_countTextField = addWidget(new FarmTextField(m_element.treatCount_tf,"")) as FarmTextField;
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.askFor_mc,ZLocUtils.t("Dialogs","Doghouse_AskForTreats"),this.onAskButtonClick)) as FarmAnimatedTextButton;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_mc,ZLocUtils.t("Dialogs","Doghouse_BuyTreat"),"00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_mc,ZLocUtils.t("Dialogs","Doghouse_UseTreat"),this.onUseButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_countTextField = null;
         this.m_askButton = null;
         this.m_buyButton = null;
         this.m_useButton = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var item:FarmItem = null;
         var consumableCount:int = 0;
         var parentWindow:DoghouseContentsWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
         if(parentWindow)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(DoghouseManager.getFetchConsumableItemName(parentWindow.building));
            if(item)
            {
               this.m_icon.loadIcon(item.iconUrl);
               consumableCount = DoghouseManager.getFetchConsumableItemCount(parentWindow.building);
               this.m_countTextField.text = String(consumableCount);
               if(consumableCount > 0 && parentWindow.building.hasNextExpansion())
               {
                  this.m_useButton.visible = true;
                  this.m_buyButton.visible = false;
               }
               else
               {
                  this.m_buyButton.setAmountText(String(item.cash));
                  this.m_buyButton.visible = true;
                  this.m_useButton.visible = false;
               }
               this.refreshAskButton();
            }
         }
      }
      
      private function refreshAskButton() : void
      {
         var item:FarmItem = null;
         var parentWindow:DoghouseContentsWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
         if(parentWindow)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(DoghouseManager.getFetchConsumableItemName(parentWindow.building));
            if(item)
            {
               this.m_askButton.enabled = !this.m_waitingFeedCallback && parentWindow.building.canRequestPartFeed(item.code);
               if(this.m_askButton.enabled)
               {
                  this.m_askButton.text = ZLocUtils.t("Dialogs","Doghouse_AskForTreats");
               }
               else
               {
                  this.m_askButton.text = "Ask in " + FarmGameUtil.toFriendlyTime(parentWindow.building.getTimeUntilPostAnotherFeed(item.code),true);
               }
            }
         }
      }
      
      private function onAskButtonClick(event:MouseEvent) : void
      {
         var parentWindow:DoghouseContentsWindow = null;
         var item:FarmItem = null;
         if(this.m_askButton.enabled)
         {
            parentWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
            if(parentWindow)
            {
               this.m_waitingFeedCallback = true;
               this.m_askButton.enabled = false;
               item = Global.farmGameSettingsManager.getFarmItemByName(DoghouseManager.getFetchConsumableItemName(parentWindow.building));
               if(item)
               {
                  parentWindow.building.requestExpansionPart(item,this.askFeedCallback,FeatureBuilding.PART_ASK_METHOD_FEED);
               }
            }
         }
      }
      
      private function askFeedCallback(result:Object = null) : void
      {
         if(result != null)
         {
            this.m_waitingFeedCallback = false;
         }
         this.refreshAskButton();
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var parentWindow:DoghouseContentsWindow = null;
         var item:FarmItem = null;
         var currency:String = null;
         var putInGiftbox:Boolean = false;
         if(this.m_buyButton.enabled)
         {
            parentWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
            if(parentWindow)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(DoghouseManager.getFetchConsumableItemName(parentWindow.building));
               if(item)
               {
                  currency = Currency.CASH;
                  putInGiftbox = parentWindow.building.hasReachedMaxExpansionLevel();
                  Global.player.buyFarmItem(item,currency,1,putInGiftbox,false,false,this.handleBuyAndPutGiftboxResult);
                  if(putInGiftbox)
                  {
                     this.m_buyButton.enabled = false;
                  }
                  else
                  {
                     parentWindow.refresh();
                  }
               }
            }
         }
      }
      
      private function handleBuyAndPutGiftboxResult(result:Object) : void
      {
         var parentWindow:DoghouseContentsWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
         if(parentWindow)
         {
            this.m_buyButton.enabled = true;
            parentWindow.refresh();
         }
      }
      
      private function onUseButtonClick(event:MouseEvent) : void
      {
         var parentWindow:DoghouseContentsWindow = null;
         var item:FarmItem = null;
         var extraData:Object = null;
         if(this.m_useButton.enabled)
         {
            parentWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
            if(parentWindow)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(DoghouseManager.getFetchConsumableItemName(parentWindow.building));
               if(item)
               {
                  extraData = {
                     "suppressGiftRepop":true,
                     "storageBuilding":parentWindow.building
                  };
                  item.onUse(parentWindow.building.getId(),extraData);
                  parentWindow.refresh();
               }
            }
         }
      }
   }
}

