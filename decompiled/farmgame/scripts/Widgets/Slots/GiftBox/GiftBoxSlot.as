package Widgets.Slots.GiftBox
{
   import Classes.Constants.Experiments;
   import Classes.ItemRequirement;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.ZItem.FuelItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Managers.FarmStatsManager;
   import Managers.GiftBoxUseAllManager;
   import Managers.IrrigationManager;
   import Managers.PetManager;
   import Transactions.TSellStoredItem;
   import Transactions.TShareRegiftItem;
   import Transactions.TUseAllSpecialDelivery;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.UseAllAmountSelectionWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class GiftBoxSlot extends ZwSlotFrame
   {
      
      private static const DEFAULT_INFO_TEXT_COLOR:uint = 5543823;
      
      private static const ERROR_INFO_TEXT_COLOR:uint = 16711680;
      
      public static const TOO_MANY_GIFTS_SEEN:String = "tooManyGifts";
      
      public static const SPECIAL_DELIVERY_CLASS_NAME:String = "SocialPlumbingMysteryGift";
      
      public static const FUEL_CANNISTER_ITEM_NAME:String = "fuel1";
      
      public static const RTUE_DELIVERY_CLASS_NAME:String = "RTUEMysteryGift";
      
      public static const CHECK_FRAME_SELL_BUTTON:int = 1;
      
      public static const UNCHECK_FRAME_SELL_BUTTON:int = 0;
      
      private static const DEFAULT_VALUE:int = -1;
      
      private var m_giftBoxWindow:GiftBoxWindow = null;
      
      private var m_data:Object = null;
      
      private var m_farmItem:FarmItem = null;
      
      private var m_title:ZwTextField;
      
      private var m_count:ZwTextField;
      
      private var m_description:ZwTextField;
      
      private var m_extra:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_helpButton:FarmAnimatedTextButton;
      
      private var m_reGiftButton:FarmAnimatedTextButton;
      
      private var m_sellButton:FarmAnimatedTextButton;
      
      private var m_tickMark:ZwWidget;
      
      private var m_SellButtonCallBack:Function;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_useAllButton:FarmAnimatedTextButton;
      
      private var m_itemNumber:Number = 0;
      
      public function GiftBoxSlot(element:DisplayObject, giftBoxWindow:GiftBoxWindow, sellButtonCallBack:Function = null)
      {
         this.m_giftBoxWindow = giftBoxWindow;
         super(element);
         this.m_title = addWidget(new ZwTextField(m_element.title_tf,"",true)) as ZwTextField;
         this.m_count = addWidget(new ZwTextField(m_element.itemCount_tf)) as ZwTextField;
         this.m_extra = addWidget(new ZwTextField(m_element.extra_tf)) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.attachTooltip(new MarketTooltip());
         this.m_helpButton = addWidget(new FarmAnimatedTextButton(m_element.question_bt,"?"),false) as FarmAnimatedTextButton;
         this.m_helpButton.attachTooltip(new MarketTooltip());
         this.m_reGiftButton = addWidget(new FarmAnimatedTextButton(m_element.reGift_bt,ZLocUtils.t("Dialogs","GiftBox_ReGift"),this.onReGiftClick)) as FarmAnimatedTextButton;
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_SellButtonCallBack = sellButtonCallBack;
            this.m_tickMark = addWidget(new ZwWidget(m_element.checkmark_mc)) as ZwWidget;
            this.m_sellButton = addWidget(new FarmAnimatedTextButton(m_element.sell_bt,ZLocUtils.t("Dialogs","GiftBox_Sell"),this.onSellClick)) as FarmAnimatedTextButton;
         }
         else
         {
            this.m_sellButton = addWidget(new FarmAnimatedTextButton(m_element.sell_bt,ZLocUtils.t("Dialogs","GiftBox_Sell"),this.onSellClick)) as FarmAnimatedTextButton;
         }
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","GiftBox_Use"),this.onUseClick)) as FarmAnimatedTextButton;
         this.m_useAllButton = addWidget(new FarmAnimatedTextButton(m_element.useAll_bt,ZLocUtils.t("Dialogs","GiftBox_UseAll"),this.onUseClick),false) as FarmAnimatedTextButton;
         this.m_icon.setIconSize(48,48);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_giftBoxWindow = null;
         this.m_data = null;
         this.m_farmItem = null;
         this.m_title = null;
         this.m_count = null;
         this.m_extra = null;
         this.m_icon = null;
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_tickMark = null;
         }
         this.m_helpButton = null;
         this.m_reGiftButton = null;
         this.m_sellButton = null;
         this.m_useButton = null;
         this.m_useAllButton = null;
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         if(this.m_farmItem)
         {
            this.setButtonEnableAndVisibility(enable);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var group:Array = null;
         var quantity:Number = NaN;
         var tooltipText:String = null;
         var item:Object = null;
         var dayCnt:Number = NaN;
         var acceptableBuildings:String = null;
         var allStorageFilters:Array = null;
         var i:int = 0;
         this.m_data = data;
         var name:String = data.name;
         if(data.group)
         {
            group = data.group as Array;
            this.m_itemNumber = Math.floor(Math.random() * group.length);
            name = data.group[this.m_itemNumber].name;
            this.m_data.name = name;
         }
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(this.m_farmItem)
         {
            this.m_title.text = this.m_farmItem.friendlyTitle;
            if(this.m_title.text == "" && this.m_farmItem.className != null && this.m_farmItem.className != "")
            {
               this.m_title.text = ZLocUtils.tk_pk_asTitle("Items:" + this.m_farmItem.className + "_friendlyName");
            }
            this.m_title.visible = true;
            this.m_icon.loadIcon(this.m_farmItem.icon);
            this.m_icon.visible = true;
            this.m_count.visible = true;
            quantity = Number(data.quantity);
            if(!data.quantity)
            {
               quantity = 0;
               for each(item in data.group)
               {
                  quantity += item.quantity;
               }
            }
            this.m_count.text = "x" + quantity;
            if(data.quantity > 999)
            {
               this.m_count.text = "x999+";
            }
            tooltipText = this.m_farmItem.getUsageDescription();
            if(this.m_farmItem.hasWhatIsThis && Boolean(tooltipText))
            {
               this.m_helpButton.visible = true;
               (this.m_helpButton.tooltip as MarketTooltip).setText(tooltipText);
            }
            tooltipText = ZLocUtils.t("Dialogs","Yield",{
               "coinQuantity":Math.floor(this.m_farmItem.sellDisplayPrice),
               "Coin_word":ZLocUtils.tk("FarmGame",this.m_farmItem.sellCurrency,"",Math.floor(this.m_farmItem.sellPrice))
            });
            if(this.m_farmItem is HarvestableItem)
            {
               dayCnt = (this.m_farmItem as HarvestableItem).harvestTime;
               tooltipText.concat("\n" + ZLocUtils.t("Dialogs","GrowthDays",{
                  "quantity":dayCnt,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",dayCnt)
               }));
            }
            if(this.m_farmItem is BuildingItem)
            {
               acceptableBuildings = "";
               allStorageFilters = Global.storageSettings.getAllStorageFilters(this.m_farmItem.name);
               for(i = 0; i < allStorageFilters.length; i++)
               {
                  if(ZLocUtils.tk_pk_asTitle("Items:" + allStorageFilters[i] + "_friendlyName") != "")
                  {
                     acceptableBuildings += "\n• " + ZLocUtils.tk_pk_asTitle("Items:" + allStorageFilters[i] + "_friendlyName");
                  }
               }
               if(acceptableBuildings != "")
               {
                  tooltipText += ZLocUtils.t_pk("Dialogs","GiftboxPartsTooltip",{"itemsList":acceptableBuildings});
               }
            }
            (this.m_icon.tooltip as MarketTooltip).setText(tooltipText);
            this.setButtonEnableAndVisibility(true);
         }
      }
      
      public function get isSellChecked() : Boolean
      {
         return this.m_tickMark.visible;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      private function setButtonEnableAndVisibility(enabledIn:Boolean) : void
      {
         var requirement:ItemRequirement = null;
         var missingRequirement:ItemRequirement = null;
         var ls:Array = null;
         if(this.m_farmItem.giftable)
         {
            this.m_reGiftButton.visible = true;
            if(GiftBoxWindow.dailyRegiftCount < this.m_giftBoxWindow.MAX_NUMBER_OF_RE_GIFTS && GiftBoxWindow.isReGiftOptionAvailable)
            {
               this.m_reGiftButton.enabled = enabledIn;
            }
            else
            {
               this.m_reGiftButton.enabled = false;
            }
         }
         else
         {
            this.m_reGiftButton.visible = false;
            this.m_reGiftButton.enabled = false;
         }
         if(this.m_farmItem.sellable && this.m_farmItem.canSellFromGiftBox)
         {
            if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
            {
               this.m_tickMark.visible = false;
               this.m_sellButton.visible = enabledIn;
            }
            else
            {
               this.m_sellButton.visible = true;
               this.m_sellButton.enabled = enabledIn;
            }
         }
         else
         {
            this.m_sellButton.visible = false;
            if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) != 2)
            {
               this.m_sellButton.enabled = false;
            }
         }
         if(this.m_data.level > 0)
         {
            this.m_extra.text = ZLocUtils.t("Dialogs","Level",{"quantity":this.m_data.level});
         }
         else
         {
            this.m_extra.text = "";
         }
         var giftboxLockRequirement:ItemRequirement = null;
         var requirements:Array = this.m_farmItem.requirements;
         var marketCardDesc:String = this.m_farmItem.marketCardName;
         for each(requirement in requirements)
         {
            if(requirement.shouldLockGiftbox())
            {
               giftboxLockRequirement = requirement;
               break;
            }
         }
         if(giftboxLockRequirement)
         {
            this.m_extra.visible = true;
            this.m_extra.text = giftboxLockRequirement.getShortReadableMessage(marketCardDesc);
         }
         giftboxLockRequirement = null;
         var missingRequirements:Array = this.m_farmItem.allMissingRequirements;
         for each(missingRequirement in missingRequirements)
         {
            if(missingRequirement.shouldLockGiftbox())
            {
               giftboxLockRequirement = missingRequirement;
               break;
            }
         }
         if(giftboxLockRequirement)
         {
            this.m_useButton.visible = true;
            this.m_useButton.enabled = false;
            this.m_extra.visible = true;
            this.m_extra.text = giftboxLockRequirement.getShortReadableMessage(marketCardDesc);
            this.m_extra.color = ERROR_INFO_TEXT_COLOR;
         }
         else if(Global.player.checkItemLimit(this.m_farmItem.name,false))
         {
            this.m_useButton.visible = true;
            this.m_useButton.enabled = false;
            ls = this.m_farmItem.getLockedStates();
            if(ls.indexOf(FarmItemLock.LIMIT_HIT) > -1)
            {
               this.m_extra.text = ZLocUtils.t("Dialogs","LimitHit",{"quantity":this.m_farmItem.limit});
               this.m_extra.color = ERROR_INFO_TEXT_COLOR;
               this.m_extra.visible = true;
            }
         }
         else
         {
            if(GiftBoxUseAllManager.isItemUseAllEnabled(this.m_farmItem))
            {
               this.m_useAllButton.visible = true;
               this.m_useAllButton.enabled = enabledIn;
            }
            else
            {
               this.m_useButton.visible = true;
               this.m_useButton.enabled = enabledIn;
            }
            this.m_extra.color = DEFAULT_INFO_TEXT_COLOR;
         }
      }
      
      private function onReGiftClick(event:MouseEvent) : void
      {
         this.m_giftBoxWindow.setButtonEnable(false);
         var textBundle:Object = {};
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t("Dialogs","RegiftingDialog_tile");
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_BOTTOM_TEXT] = ZLocUtils.t("Dialogs","RegiftingDialog_warning");
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t("Dialogs","Share");
         textBundle[UseAllAmountSelectionWindow.TEXT_KEY_CANCEL_BUTTON] = ZLocUtils.t("Dialogs","Cancel");
         var dialogOptions:Object = {};
         dialogOptions[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
         UI.displayPopup(new UseAllAmountSelectionWindow(this.m_farmItem,this.m_data.quantity,1,this.shareGiftHandler,this.cancelShareGiftHandler,textBundle,dialogOptions),false);
         FarmStatsManager.count("farmville_sell_gift_screen","click_regift_item",this.m_data.name);
      }
      
      private function shareGiftHandler(data:Object) : void
      {
         var amountToGift:int = 0;
         var shouldRefresh:Boolean = false;
         this.m_giftBoxWindow.setButtonEnable(true);
         if(data != null && data.item != null && data.item.code == this.m_data.itemKey)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","click_share_button",data.item.name + "_" + data.quantitySelected.toString());
            amountToGift = Math.min(this.m_data.quantity,data.quantitySelected);
            Global.player.removeGiftWithKey(data.item.code,amountToGift);
            this.m_data.quantity = Number(this.m_data.quantity) - amountToGift;
            shouldRefresh = false;
            if(this.m_data.quantity != 0)
            {
               this.m_count.text = "x" + this.m_data.quantity;
               if(this.m_data.quantity > 999)
               {
                  this.m_count.text = "x999+";
               }
            }
            else
            {
               shouldRefresh = true;
            }
            ++GiftBoxWindow.dailyRegiftCount;
            if(GiftBoxWindow.dailyRegiftCount >= this.m_giftBoxWindow.MAX_NUMBER_OF_RE_GIFTS)
            {
               shouldRefresh = true;
            }
            if(shouldRefresh == true)
            {
               this.m_giftBoxWindow.reload();
            }
            TransactionManager.addTransaction(new TShareRegiftItem(data.item.code,amountToGift),true);
         }
      }
      
      private function cancelShareGiftHandler(data:Object) : void
      {
         FarmStatsManager.count("farmville_sell_gift_screen","click_x_button",data.item.name);
         this.m_giftBoxWindow.setButtonEnable(true);
      }
      
      public function updateSellIcon(overrideValue:int = -1) : void
      {
         var initialVisibility:Boolean = this.m_tickMark.visible;
         var hasChanged:Boolean = false;
         if(overrideValue == DEFAULT_VALUE)
         {
            this.m_tickMark.visible = !this.m_tickMark.visible;
         }
         else if(overrideValue == CHECK_FRAME_SELL_BUTTON)
         {
            this.m_tickMark.visible = true;
         }
         else
         {
            this.m_tickMark.visible = false;
         }
         if(initialVisibility != this.m_tickMark.visible)
         {
            hasChanged = true;
         }
         this.m_SellButtonCallBack(this.m_tickMark.visible,hasChanged);
      }
      
      private function onSellClick(event:MouseEvent) : void
      {
         var textBundle:Object = null;
         var dialogOptions:Object = null;
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.updateSellIcon();
         }
         else
         {
            this.m_giftBoxWindow.setButtonEnable(false);
            textBundle = {};
            textBundle[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t("Dialogs","SellAllDialog_tile");
            textBundle[UseAllAmountSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t("Dialogs","Sell");
            dialogOptions = {};
            if(!this.m_data.hasOwnProperty("quantity"))
            {
               this.sellMultipleGiftsHandler({
                  "item":this.m_farmItem,
                  "quantitySelected":1
               });
            }
            else
            {
               dialogOptions[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
               UI.displayPopup(new UseAllAmountSelectionWindow(this.m_farmItem,Global.player.getGiftCountForItem(this.m_farmItem.name),1,this.sellMultipleGiftsHandler,this.closeMultipleSellHandler,textBundle,dialogOptions),false);
            }
         }
      }
      
      private function closeMultipleSellHandler(data:Object) : void
      {
         this.m_giftBoxWindow.setButtonEnable(true);
         UI.displayGiftBoxWindow();
      }
      
      public function sellMultipleGiftsHandler(data:Object, parentSellCompleteHandler:Function = null, sendTransactionImmediately:Boolean = true) : void
      {
         var item:FarmItem = null;
         var friendlyNameText:String = null;
         var quantity:int = 0;
         var itemKey:String = null;
         var itemName:String = null;
         var yieldsString:String = null;
         var message:String = null;
         var onConfirmSell:Function = null;
         if(data != null && data.item != null && data.quantitySelected != null)
         {
            item = data.item;
            friendlyNameText = item.friendlyTitle;
            if(friendlyNameText == "" && item.className != null && item.className != "")
            {
               friendlyNameText = ZLocUtils.tk_pk_asTitle("Items:" + item.className + "_friendlyName");
            }
            if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
            {
               quantity = int(data.quantitySelected);
               itemKey = this.m_data.itemKey;
               itemName = this.m_data.itemName;
               if(!itemKey)
               {
                  itemKey = this.m_data.group[this.m_itemNumber].itemKey;
                  itemName = this.m_data.group[this.m_itemNumber].itemKey;
               }
               FarmStatsManager.count("farmville_sell_gift_screen","click_sell_multiple_item",itemName);
               TransactionManager.addTransaction(new TSellStoredItem(itemKey,false,this.onSellCompleteAfterGiftBoxDeletion(parentSellCompleteHandler),Global.world.GIFTBOX_ID,quantity),sendTransactionImmediately);
            }
            else
            {
               quantity = int(data.quantitySelected);
               yieldsString = "";
               if(item.sellCurrency != Currency.COINS)
               {
                  yieldsString = quantity * item.untunedSellPrice + " " + ZLocUtils.t("FarmGame",Currency.COINS) + " and ";
               }
               yieldsString += quantity * item.sellDisplayPrice + " " + ZLocUtils.t("FarmGame",item.sellCurrency);
               message = ZLocUtils.t("FarmGame","SellMultipleObjectSpecific",{
                  "quantity":quantity,
                  "item":friendlyNameText,
                  "yieldsString":yieldsString
               });
               onConfirmSell = function(e:GenericPopupEvent):void
               {
                  var itemKey:String = null;
                  var itemName:String = null;
                  if(e.button == GenericPopup.ACCEPT)
                  {
                     itemKey = m_data.itemKey;
                     itemName = m_data.itemName;
                     if(!itemKey)
                     {
                        itemKey = m_data.group[m_itemNumber].itemKey;
                        itemName = m_data.group[m_itemNumber].itemKey;
                     }
                     FarmStatsManager.count("farmville_sell_gift_screen","click_sell_multiple_item",itemName);
                     TransactionManager.addTransaction(new TSellStoredItem(itemKey,false,onSellComplete,Global.world.GIFTBOX_ID,quantity),true);
                  }
                  else
                  {
                     onSellComplete(null);
                  }
               };
               UI.displayMessageWithHtml(message,GenericPopup.TYPE_YESNO,onConfirmSell,"sellOneGiftHandler",true);
            }
         }
      }
      
      private function onSellComplete(result:Object) : void
      {
         var itemOwned:Number = NaN;
         var itemKey:String = null;
         var newCount:Number = NaN;
         var group:Array = null;
         var groupLen:int = 0;
         this.m_giftBoxWindow.setButtonEnable(true);
         if(result)
         {
            if(result.sellable == false)
            {
               if(result.all == true)
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","GiftNotSellableAll"),GenericPopup.TYPE_OK,null,"giftNotSellable",true);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","GiftNotSellable"),GenericPopup.TYPE_OK,null,"giftNotSellable",true);
               }
            }
            else
            {
               if(Global.player.getGiftCount() > 0)
               {
                  itemOwned = Global.player.getGiftCountForItem(this.m_data.name);
                  itemKey = this.m_data.itemKey;
                  if(this.m_data.group)
                  {
                     itemKey = this.m_data.group[this.m_itemNumber].itemKey;
                  }
                  if(result.hasOwnProperty("qtySold"))
                  {
                     Global.player.removeGiftWithKey(itemKey,result.qtySold);
                  }
                  else
                  {
                     Global.player.removeGiftWithKey(itemKey);
                  }
                  newCount = Global.player.getGiftCountForItem(this.m_data.name);
                  if(newCount == 0 && Boolean(this.m_data.group))
                  {
                     group = this.m_data.group as Array;
                     group.splice(this.m_itemNumber,1);
                     groupLen = int(group.length);
                     if(groupLen > 0)
                     {
                        this.m_itemNumber = Math.floor(Math.random() * groupLen);
                        this.m_data.name = this.m_data.group[this.m_itemNumber].name;
                     }
                  }
                  this.m_data.quantity -= itemOwned - newCount;
                  this.m_count.text = "x" + this.m_data.quantity;
                  if(this.m_data.quantity > 999)
                  {
                     this.m_count.text = "x999+";
                  }
                  if(Global.player.getGiftCount() == 0)
                  {
                     FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_impression");
                     this.m_giftBoxWindow.close();
                     this.m_giftBoxWindow = null;
                  }
               }
               else
               {
                  Global.player.removeAllGifts();
                  this.m_giftBoxWindow.close();
                  this.m_giftBoxWindow = null;
               }
               Global.hud.conditionallyRefreshHUD(true);
            }
         }
         if(null != this.m_giftBoxWindow)
         {
            this.m_giftBoxWindow.reload();
         }
      }
      
      private function onSellCompleteAfterGiftBoxDeletion(parentSellCompleteHandler:Function) : Function
      {
         var f:Function = function(result:Object):void
         {
            var itemOwned:Number = NaN;
            var itemKey:String = null;
            var newCount:Number = NaN;
            var group:Array = null;
            var groupLen:int = 0;
            m_giftBoxWindow.setButtonEnable(true);
            if(result)
            {
               if(result.sellable == false)
               {
                  if(result.all == true)
                  {
                     UI.displayMessage(ZLocUtils.t("Dialogs","GiftNotSellableAll"),GenericPopup.TYPE_OK,null,"giftNotSellable",true);
                  }
                  else
                  {
                     UI.displayMessage(ZLocUtils.t("Dialogs","GiftNotSellable"),GenericPopup.TYPE_OK,null,"giftNotSellable",true);
                  }
               }
               else if(Global.player.getGiftCount() > 0)
               {
                  itemOwned = Global.player.getGiftCountForItem(m_data.name);
                  itemKey = m_data.itemKey;
                  if(m_data.group)
                  {
                     itemKey = m_data.group[m_itemNumber].itemKey;
                  }
                  if(result.hasOwnProperty("qtySold"))
                  {
                     Global.player.removeGiftWithKey(itemKey,result.qtySold);
                  }
                  else
                  {
                     Global.player.removeGiftWithKey(itemKey);
                  }
                  newCount = Global.player.getGiftCountForItem(m_data.name);
                  if(newCount == 0 && Boolean(m_data.group))
                  {
                     group = m_data.group as Array;
                     group.splice(m_itemNumber,1);
                     groupLen = int(group.length);
                     if(groupLen > 0)
                     {
                        m_itemNumber = Math.floor(Math.random() * groupLen);
                        m_data.name = m_data.group[m_itemNumber].name;
                     }
                  }
                  m_data.quantity -= itemOwned - newCount;
                  m_count.text = "x" + m_data.quantity;
                  if(m_data.quantity > 999)
                  {
                     m_count.text = "x999+";
                  }
                  if(Global.player.getGiftCount() == 0)
                  {
                     FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_impression");
                     m_giftBoxWindow.close();
                     m_giftBoxWindow = null;
                  }
               }
               else
               {
                  Global.player.removeAllGifts();
                  m_giftBoxWindow.close();
                  m_giftBoxWindow = null;
               }
            }
            if(null != m_giftBoxWindow)
            {
            }
            parentSellCompleteHandler();
         };
         return f;
      }
      
      private function onUseClick(event:MouseEvent) : void
      {
         var dialogOptions:Object = null;
         var maxQuantityCanBeOpened:Number = NaN;
         var textBundle:Object = null;
         var throttleMaxOpenSDB:Number = NaN;
         var hideQuantity:Boolean = false;
         var throttleSampleRate:Number = NaN;
         var options:Object = null;
         var throttleMaxOpen:Number = NaN;
         var tempOptions:Object = null;
         var throttleMaxOpenWater:Number = NaN;
         var name:String = this.m_data.name;
         FarmStatsManager.count("farmville_sell_gift_screen","click_use_item",name);
         var extraData:Object = new Object();
         if(name != this.m_farmItem.name)
         {
            extraData.realItemName = name;
         }
         if(!this.m_farmItem.canUseFromGiftBox)
         {
            this.m_farmItem.displayCantUseFromGiftBoxDialog();
         }
         else if(this.m_farmItem.className == RTUE_DELIVERY_CLASS_NAME)
         {
            dialogOptions = {};
            dialogOptions[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
            maxQuantityCanBeOpened = Number(this.m_data.quantity);
            textBundle = {};
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_THROTTLE_OPEN_SDB) == 1)
            {
               throttleMaxOpenSDB = Global.flashHotParams["THROTTLE_MAX_OPEN_SDB"] as Number;
               hideQuantity = Global.flashHotParams["THROTTLE_MAX_OPEN_SDB_HIDE_QUANTITY"] as Boolean;
               if(Boolean(throttleMaxOpenSDB) && throttleMaxOpenSDB > 1)
               {
                  if(this.m_data.quantity > throttleMaxOpenSDB)
                  {
                     maxQuantityCanBeOpened = throttleMaxOpenSDB;
                     throttleSampleRate = Global.flashHotParams["THROTTLE_MAX_OPEN_SDB_STAT_SAMPLE_RATE1"] as Number;
                     FarmStatsManager.sample(throttleSampleRate,"fv_sdb_throttle_open","frontend","info","total:" + this.m_data.quantity.toString(),"throttle:" + throttleMaxOpenSDB.toString());
                  }
                  textBundle[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t("Dialogs","UseAllDialog_tile");
                  textBundle[UseAllAmountSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t("Dialogs","UseAll_useButton");
                  textBundle[UseAllAmountSelectionWindow.TEXT_KEY_CANCEL_BUTTON] = ZLocUtils.t("Dialogs","Cancel");
                  textBundle[UseAllAmountSelectionWindow.TEXT_KEY_BOTTOM_TEXT] = ZLocUtils.t("Dialogs","UseAllDialogSDB_warning",{
                     "quantity":this.m_data.quantity.toString(),
                     "itemname":this.m_farmItem.friendlyTitle.toString(),
                     "throttleMaxOpenSDB":throttleMaxOpenSDB.toString()
                  });
                  if(hideQuantity)
                  {
                     textBundle[UseAllAmountSelectionWindow.TEXT_KEY_CURRENT_QUANTITY] = " ";
                  }
               }
            }
            UI.displayPopup(new UseAllAmountSelectionWindow(this.m_farmItem,maxQuantityCanBeOpened,1,this.useSDBs,this.cancelUseItem,textBundle,dialogOptions),false);
         }
         else if((this.m_farmItem.name == FUEL_CANNISTER_ITEM_NAME || FuelItem.isAFuelCan(this.m_farmItem.name)) && FuelItem.OwnsFuelVehicle())
         {
            options = {};
            options[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
            throttleMaxOpen = Global.flashHotParams["THROTTLE_MAX_OPEN_FUEL_CAN"] as Number;
            UI.displayPopup(new UseAllAmountSelectionWindow(this.m_farmItem,Math.min(this.m_data.quantity,throttleMaxOpen),1,this.useMultiselect,this.cancelUseItem,null,options),false);
         }
         else if(this.m_farmItem.name == "consume_irrigation_water")
         {
            if(Global.worldManager.currentWorldType != "farm")
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Irrigation_useWaterBadWorld"));
            }
            else
            {
               tempOptions = {};
               tempOptions[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
               throttleMaxOpenWater = IrrigationManager.instance.getMaxWaterForActionType(IrrigationManager.WATER_PLOTS) - IrrigationManager.instance.getWaterAmount(IrrigationManager.WATER_PLOTS);
               UI.displayPopup(new UseAllAmountSelectionWindow(this.m_farmItem,Math.min(this.m_data.quantity,throttleMaxOpenWater),1,this.useMultiWater,this.cancelUseItem,null,tempOptions),false);
            }
         }
         else
         {
            if(GiftBoxUseAllManager.isItemUseAllEnabled(this.m_farmItem))
            {
               extraData["itemCount"] = GiftBoxUseAllManager.itemUseAllCount(this.m_farmItem);
            }
            this.m_farmItem.onUse(Global.world.GIFTBOX_ID,extraData);
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         }
         if(this.m_giftBoxWindow != null)
         {
            this.m_giftBoxWindow.close();
         }
         PetManager.getInstance().resetRescuePet();
      }
      
      private function useSDBs(data:Object) : void
      {
         if(data != null && data.item != null && data.quantitySelected != null)
         {
            TransactionManager.addTransaction(new TUseAllSpecialDelivery(data.item,data.quantitySelected));
         }
      }
      
      private function useMultiselect(data:Object) : void
      {
         var extraData:Object = null;
         var farmItem:FarmItem = null;
         var i:int = 0;
         if(Boolean(data) && Boolean(data.item is FarmItem) && data.quantitySelected > 0)
         {
            extraData = {};
            if(Boolean(data.name) && data.name != (data.item as FarmItem).name)
            {
               extraData.realItemName = data.name;
            }
            farmItem = data.item as FarmItem;
            for(i = 0; i < data.quantitySelected; i++)
            {
               farmItem.onUse(Global.world.GIFTBOX_ID,extraData);
            }
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         }
      }
      
      private function useMultiWater(data:Object) : void
      {
         if(Boolean(data) && Boolean(data.item is FarmItem) && data.quantitySelected > 0)
         {
            IrrigationManager.instance.consumeWaterPackages(data.quantitySelected);
         }
      }
      
      private function cancelUseItem(data:Object) : void
      {
         UI.displayGiftBoxWindow();
      }
   }
}

