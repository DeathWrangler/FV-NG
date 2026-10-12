package Widgets.Slots.Breeding
{
   import Classes.Animal;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.FeatureManager;
   import Classes.ImageLoader;
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Transactions.TSellStorageBuidingItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.StorageContentsSlotFrame;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.MovieClipTooltip;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   
   public class AnimalBreedingContentsSlot extends ZwSlotFrame
   {
      
      public static const DEFAULT_Y:Number = 2.6;
      
      protected static const TOOLTIP_SHOW_FRAME_NUM:int = 30;
      
      protected static const TOOLTIP_ICON_SIZE:int = 50;
      
      protected static const TOOLTIP_SHARE_BUY_REMOVE:int = 1;
      
      protected static const TOOLTIP_BUY_REMOVE:int = 2;
      
      protected static const TOOLTIP_SHARE_BUY:int = 3;
      
      protected static const TOOLTIP_SHARE_REMOVE:int = 4;
      
      protected static const TOOLTIP_REMOVE:int = 5;
      
      protected static const TOOLTIP_SHARE:int = 6;
      
      protected static const TOOLTIP_BUY:int = 7;
      
      protected static const TOOLTIP_NOTAVAIALABLE:int = 8;
      
      public static const CHECK_FRAME_SELL_BUTTON:int = 1;
      
      public static const UNCHECK_FRAME_SELL_BUTTON:int = 0;
      
      private static const DEFAULT_VALUE:int = -1;
      
      protected static const BABY_NOT_AVAILABLE_ICON:String = "assets/dialogs/4d_elements/Animal_HorsePaddock/currentlyNotAvailable.png";
      
      private var m_slotBGIcon:DisplayObject;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_itemAmount:ZwTextField = null;
      
      protected var m_itemTitle:ZwTextField = null;
      
      protected var m_farmItem:FarmItem = null;
      
      protected var m_parentWindow:BaseContentsWindow = null;
      
      protected var m_animalSprite:Sprite = null;
      
      protected var m_sign:MovieClip = null;
      
      protected var m_masteryFrame:MarketSlotMasteryFrame = null;
      
      protected var m_marketButton:ZwButton = null;
      
      protected var m_secondaryActionButton:ZwButton = null;
      
      protected var m_leftSecondaryActionButton:ZwButton = null;
      
      protected var m_popupIcon:FarmIcon = null;
      
      protected var m_removeButton:FarmAnimatedTextButton = null;
      
      protected var m_buyButton:FarmAnimatedTextButton = null;
      
      protected var m_notAvailable:ZwTextField = null;
      
      protected var m_itemMetadataHash:String = null;
      
      protected var m_metadata:String = "";
      
      protected var m_useFarmItemAsPopupIcon:Boolean = false;
      
      public var m_tickMark:ZwWidget;
      
      private var m_sellButton:FarmAnimatedTextButton;
      
      private var m_SellButtonCallBack:Function;
      
      public var m_slotData:Object;
      
      private var m_enabled:Boolean = false;
      
      private var m_itemNumber:Number = 0;
      
      private var m_quantity:Number = 0;
      
      private var m_totalCount:Number = 0;
      
      private var m_parentFrame:StorageContentsSlotFrame;
      
      private var m_vipTag:ZwWidget;
      
      private var m_slotCompilingArray:Array;
      
      public function AnimalBreedingContentsSlot(element:DisplayObject, parentWindow:BaseContentsWindow, labBuildingConfig:XML = null, sellButtonCallBack:Function = null, slotFrame:StorageContentsSlotFrame = null)
      {
         var buttonBGPath:String = null;
         this.m_slotCompilingArray = [DragonContentsSlot,IconBreedingContentSlot];
         super(element);
         this.m_parentFrame = slotFrame;
         this.m_parentWindow = parentWindow;
         this.m_SellButtonCallBack = sellButtonCallBack;
         if(m_element.hasOwnProperty("itemAmount_tf"))
         {
            this.m_itemAmount = new ZwTextField(m_element.itemAmount_tf,"");
            addWidget(this.m_itemAmount);
         }
         if(m_element.hasOwnProperty("viptag_mc"))
         {
            this.m_vipTag = new ZwWidget(m_element.viptag_mc);
            addWidget(this.m_vipTag,false);
         }
         if(m_element.itemTitle_tf_new)
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf_new,"");
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_element.itemTitle_tf_new);
            }
         }
         else if(m_element.hasOwnProperty("itemTitle_tf"))
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf,"");
         }
         if(this.m_itemTitle)
         {
            addWidget(this.m_itemTitle);
         }
         if(m_element.hasOwnProperty("sign_mc"))
         {
            this.m_sign = m_element.sign_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("mastery_mc"))
         {
            this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         }
         if(m_element.hasOwnProperty("market_bt"))
         {
            this.m_marketButton = addWidget(new FarmAnimatedTextButton(m_element.market_bt,ZLocUtils.t("Dialogs","Market"),this.onClickMarket)) as ZwButton;
         }
         if(m_element.hasOwnProperty("sell_bt"))
         {
            this.m_sellButton = addWidget(new FarmAnimatedTextButton(m_element.sell_bt,ZLocUtils.t("Dialogs","GiftBox_Sell"),this.onSellClick)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_tickMark = addWidget(new ZwWidget(m_element.checkmark_mc),true) as ZwWidget;
         }
         this.attachTooltip(new MovieClipTooltip(element as MovieClip,TOOLTIP_SHOW_FRAME_NUM));
         if(m_element.hasOwnProperty("tooltip_mc") && Boolean(m_element.tooltip_mc.hasOwnProperty("tooltipIcon_mc")))
         {
            this.m_popupIcon = new FarmIcon(m_element.tooltip_mc.tooltipIcon_mc);
            this.m_popupIcon.setIconSize(TOOLTIP_ICON_SIZE,TOOLTIP_ICON_SIZE);
            addWidget(this.m_popupIcon);
         }
         if(m_element.hasOwnProperty("mc_Button"))
         {
            buttonBGPath = Global.worldSettingsManager.getSlotBGImagePath("Button100");
            if(buttonBGPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_element.mc_Button.addChild(this.m_slotBGIcon);
                  m_element.mc_Button.visible = true;
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function onSellClick(ev:MouseEvent) : void
      {
         this.updateSellIcon();
      }
      
      public function isSlotEnabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function isSelected() : Boolean
      {
         var result:Boolean = false;
         if(this.m_tickMark)
         {
            result = this.m_tickMark.visible;
         }
         return result;
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
         if(this.m_farmItem)
         {
            if(!this.m_farmItem.sellable)
            {
               this.enableSell(false);
            }
            else
            {
               this.enableSell(true);
            }
         }
         if(Boolean(this.m_slotData) && Boolean(this.m_slotData.hasOwnProperty("quantity")) && this.m_slotData.quantity < 1)
         {
            this.enableSell(false);
         }
         if(this.m_SellButtonCallBack != null)
         {
            this.m_SellButtonCallBack(this.m_tickMark.visible,hasChanged);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_objectPreviewFrame = null;
         this.m_itemAmount = null;
         this.m_itemTitle = null;
         this.m_parentWindow = null;
         this.m_animalSprite = null;
         this.m_sign = null;
         this.m_masteryFrame = null;
         this.m_marketButton = null;
         this.m_popupIcon = null;
         this.m_removeButton = null;
         this.m_buyButton = null;
         this.m_notAvailable = null;
         this.m_itemMetadataHash = null;
         this.m_metadata = null;
         this.m_tickMark = null;
         this.m_sellButton = null;
         this.m_SellButtonCallBack = null;
         this.m_slotData = null;
      }
      
      override public function populate(data:Object) : void
      {
         var holder:MovieClip = null;
         var mastery:Mastery = null;
         var masteryCurrentLevel:int = 0;
         super.populate(data);
         this.m_slotData = data;
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(data.hasOwnProperty("metadataHash"))
         {
            this.m_itemMetadataHash = data.metadataHash;
            this.m_metadata = this.m_parentWindow.building.getStorageMetaDataForHash(this.m_itemMetadataHash) as String;
         }
         if(data.hasOwnProperty("useOverrideIcon"))
         {
            this.m_useFarmItemAsPopupIcon = data.useOverrideIcon;
         }
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_farmItem.displayLoader.canUseAnimation)
         {
            this.m_farmItem.displayLoader.useAnimation = true;
         }
         if(this.m_farmItem.sellable)
         {
            if(this.m_tickMark)
            {
               this.m_tickMark.visible = false;
            }
            if(this.m_sellButton)
            {
               this.m_sellButton.visible = true;
            }
            this.enableSell(true);
         }
         else
         {
            this.enableSell(false);
         }
         this.loadIconMC(data,this.m_metadata);
         var tooltipState:int = this.checkTooltipState(data);
         this.setupTooltip(tooltipState);
         if(this.m_itemTitle != null)
         {
            if(data.hasOwnProperty("displayName"))
            {
               this.m_itemTitle.text = data.displayName;
            }
            else
            {
               this.m_itemTitle.text = this.m_farmItem.friendlyTitle;
            }
            this.m_itemTitle.visible = true;
         }
         if(this.m_sign != null)
         {
            this.m_sign.visible = true;
            if(data.quantity > 0)
            {
               this.m_sign.gotoAndStop(1);
            }
            else
            {
               this.m_sign.gotoAndStop(2);
               this.m_itemTitle.color = 16777215;
            }
         }
         if(data.quantity > 0)
         {
            if(this.m_masteryFrame != null)
            {
               if(this.m_farmItem is HarvestableItem && (this.m_farmItem as HarvestableItem).hasMastery)
               {
                  mastery = (this.m_farmItem as HarvestableItem).mastery;
                  masteryCurrentLevel = mastery.currentLevel + 1;
                  this.m_masteryFrame.update(masteryCurrentLevel,mastery.currentProgress,mastery.totalCropsNeeded);
                  this.m_masteryFrame.visible = true;
                  if(this.m_secondaryActionButton)
                  {
                     this.m_secondaryActionButton.visible = masteryCurrentLevel < MarketSlotMasteryFrame.MAX_LEVEL;
                  }
               }
               else
               {
                  this.m_masteryFrame.visible = false;
                  if(this.m_secondaryActionButton)
                  {
                     this.m_secondaryActionButton.visible = false;
                  }
               }
               this.m_marketButton.visible = false;
               this.enableSell(true);
            }
         }
         else if(this.m_farmItem.canPurchase)
         {
            this.enableSell(false);
            this.makeTransparent(this.m_objectPreviewFrame);
            if(this.m_marketButton != null)
            {
               this.m_masteryFrame.visible = false;
               this.m_marketButton.visible = true;
               if(this.m_secondaryActionButton)
               {
                  this.m_secondaryActionButton.visible = false;
               }
            }
         }
         else
         {
            this.enableSell(false);
            this.makeTransparent(this.m_objectPreviewFrame);
            if(this.m_masteryFrame)
            {
               this.m_masteryFrame.visible = false;
               if(this.m_secondaryActionButton)
               {
                  this.m_secondaryActionButton.visible = false;
               }
            }
            if(this.m_marketButton)
            {
               this.m_marketButton.visible = false;
            }
         }
         if(this.m_itemAmount != null)
         {
            if(Boolean(data.hasOwnProperty("unique")) && Boolean(data.unique) && data.quantity == 1)
            {
               this.m_itemAmount.visible = false;
            }
            else
            {
               this.m_totalCount = data.quantity;
               this.m_itemAmount.text = "x" + data.quantity.toString();
               this.m_itemAmount.visible = true;
            }
         }
         if(Boolean(this.m_leftSecondaryActionButton) && Boolean(this.m_leftSecondaryActionButton.element))
         {
            this.m_leftSecondaryActionButton.visible = true;
         }
         if(this.m_vipTag)
         {
            this.m_vipTag.visible = false;
         }
      }
      
      private function enableSell(setBool:Boolean) : void
      {
         this.m_enabled = setBool;
         if(this.m_tickMark)
         {
            this.m_tickMark.enabled = setBool;
         }
         if(this.m_sellButton)
         {
            this.m_sellButton.enabled = setBool;
         }
      }
      
      public function sellMultipleGiftsHandler(data:Object, parentSellCompleteHandler:Function = null, sendTransactionImmediately:Boolean = true) : void
      {
         var item:FarmItem = null;
         var friendlyNameText:String = null;
         var quantity:int = 0;
         var itemKey:String = null;
         var itemName:String = null;
         if(data != null && data.item != null && data.quantitySelected != null)
         {
            item = data.item;
            friendlyNameText = item.friendlyTitle;
            quantity = int(data.quantitySelected);
            this.m_quantity = quantity;
            itemKey = this.m_slotData.code;
            itemName = this.m_slotData.itemName;
            TransactionManager.addTransaction(new TSellStorageBuidingItem(itemKey,false,this.onSellCompleteAfterGiftBoxDeletion,Global.player.currentStorageWorldId,quantity,this.m_parentWindow.building.getId(),this.m_metadata),sendTransactionImmediately);
         }
      }
      
      private function refreshSlots(quantity:Number) : void
      {
         this.m_totalCount -= quantity;
         this.m_itemAmount.text = "x" + this.m_totalCount.toString();
         this.m_tickMark.visible = false;
         if(this.m_slotData.hasOwnProperty("quantity"))
         {
            this.m_slotData.quantity -= quantity;
         }
         if(this.m_totalCount > 0)
         {
            this.m_sellButton.enabled = true;
         }
         else
         {
            if(this.m_objectPreviewFrame)
            {
               this.makeTransparent(this.m_objectPreviewFrame);
            }
            this.setupTooltip(TOOLTIP_BUY);
            this.m_sellButton.enabled = false;
         }
      }
      
      private function onSellCompleteAfterGiftBoxDeletion() : void
      {
         this.m_parentWindow.untintWindow();
         this.m_parentWindow.enableInput = true;
         if(this.m_animalSprite)
         {
            this.refreshSlots(this.m_quantity);
            if(this.m_itemMetadataHash)
            {
               this.m_parentWindow.building.lastMetaHashRemoved = this.m_itemMetadataHash;
            }
            this.m_parentWindow.building.removeContents(this.m_slotData.code,this.m_quantity);
         }
      }
      
      protected function loadIconMC(data:Object, metadata:String) : void
      {
         var holder:MovieClip = null;
         var offset:Point = null;
         if(m_element.hasOwnProperty("icon_mc"))
         {
            holder = m_element.icon_mc;
            offset = new Point(0,0);
            if(data.hasOwnProperty("offsetX"))
            {
               offset.x = data.offsetX;
            }
            if(data.hasOwnProperty("offsetY"))
            {
               offset.y = data.offsetY;
            }
            this.m_objectPreviewFrame = new ObjectPreviewFrame(holder,this.m_farmItem,null,[this.m_farmItem.sizeX == 1 ? 2 : 1.75],null,Animal.STATE_FRONT_IDLE,metadata,null,offset);
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
            this.m_animalSprite = this.m_objectPreviewFrame.sprite;
            if(Boolean(this.m_animalSprite) && data.quantity > 0)
            {
               this.m_animalSprite.buttonMode = true;
               this.m_animalSprite.mouseChildren = true;
               this.m_animalSprite.useHandCursor = true;
               this.m_animalSprite.addEventListener(MouseEvent.CLICK,this.animalMouseClickHandler);
            }
         }
      }
      
      protected function animalMouseClickHandler(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"remove",this.m_farmItem.name);
         this.m_parentWindow.skipCloseStat = true;
         if(this.m_animalSprite)
         {
            this.m_animalSprite.removeEventListener(MouseEvent.CLICK,this.animalMouseClickHandler);
            this.m_animalSprite = null;
         }
         var extraData:Object = new Object();
         extraData.isGift = false;
         extraData.repopGift = false;
         extraData.metadata = this.m_metadata;
         this.m_farmItem.onUse(this.m_parentWindow.building.getId(),extraData);
         this.m_parentWindow.close();
      }
      
      protected function makeTransparent(previewFrame:ObjectPreviewFrame) : void
      {
         var alphaFilter:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.6,0]);
         (previewFrame.element as MovieClip).filters = [alphaFilter];
      }
      
      protected function onClickMarket(event:MouseEvent) : void
      {
         var createWindow:Function;
         var building:FeatureBuilding = null;
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"market",this.m_farmItem.name);
         this.m_parentWindow.skipCloseStat = true;
         building = this.m_parentWindow.building;
         createWindow = function(purchased:Boolean = false):void
         {
            if(!purchased)
            {
               building.displayStorageDialog();
            }
         };
         UI.displayMiniMarketDialog([this.m_farmItem.name],"animal","animal",createWindow,true);
         this.m_parentWindow.close();
      }
      
      public function pause() : void
      {
         if(this.m_parentWindow)
         {
            this.m_parentWindow.tintWindow();
            this.m_parentWindow.enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(this.m_parentWindow)
         {
            this.m_parentWindow.untintWindow();
            this.m_parentWindow.enableInput = true;
         }
      }
      
      protected function checkTooltipState(data:Object) : int
      {
         var canPurchase:Boolean = false;
         var state:int = 0;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(farmItem)
         {
            canPurchase = farmItem.canPurchase;
            if(data.quantity > 0)
            {
               if(farmItem as IUGCItem)
               {
                  state = TOOLTIP_REMOVE;
               }
               else if(canPurchase && this.isSharable())
               {
                  state = TOOLTIP_SHARE_BUY_REMOVE;
               }
               else if(this.isSharable())
               {
                  state = TOOLTIP_SHARE_REMOVE;
               }
               else if(canPurchase)
               {
                  state = TOOLTIP_BUY_REMOVE;
               }
               else
               {
                  state = TOOLTIP_REMOVE;
               }
            }
            else if(canPurchase && this.isSharable())
            {
               state = TOOLTIP_SHARE_BUY;
            }
            else if(this.isSharable())
            {
               state = TOOLTIP_SHARE;
            }
            else if(canPurchase)
            {
               state = TOOLTIP_BUY;
            }
            else
            {
               state = TOOLTIP_NOTAVAIALABLE;
            }
         }
         return state;
      }
      
      protected function setupTooltip(state:int) : void
      {
         if(this.popupHasIcon)
         {
            this.showPopupIcon(state);
         }
         switch(state)
         {
            case TOOLTIP_SHARE_BUY_REMOVE:
               this.toggleTooltipStates(true,true,false,true,TOOLTIP_SHARE_BUY_REMOVE);
               break;
            case TOOLTIP_BUY_REMOVE:
               this.toggleTooltipStates(true,true,false,true,TOOLTIP_BUY_REMOVE);
               break;
            case TOOLTIP_SHARE_BUY:
               this.toggleTooltipStates(true,false,false,true,TOOLTIP_SHARE_BUY);
               break;
            case TOOLTIP_SHARE_REMOVE:
               this.toggleTooltipStates(false,true,false,true,TOOLTIP_SHARE_REMOVE);
               break;
            case TOOLTIP_REMOVE:
               this.toggleTooltipStates(false,true,false,true,TOOLTIP_REMOVE);
               break;
            case TOOLTIP_SHARE:
               this.toggleTooltipStates(false,false,false,true,TOOLTIP_SHARE);
               break;
            case TOOLTIP_BUY:
               this.toggleTooltipStates(true,false,false,true,TOOLTIP_SHARE_BUY);
               break;
            case TOOLTIP_NOTAVAIALABLE:
               this.toggleTooltipStates(false,false,true,false,TOOLTIP_NOTAVAIALABLE);
         }
      }
      
      protected function toggleTooltipStates(showBuy:Boolean, showRemove:Boolean, showText:Boolean, showPopup:Boolean, frameNum:int) : void
      {
         var tooltip:MovieClip = null;
         if(m_element.hasOwnProperty("tooltip_mc"))
         {
            tooltip = m_element.tooltip_mc as MovieClip;
            tooltip.gotoAndStop(TOOLTIP_NOTAVAIALABLE);
            tooltip.gotoAndStop(frameNum);
         }
         else if(showBuy || showRemove || showText)
         {
            ErrorManager.addError("toggleTooltipStates(...) local var m_element.tooltip_mc is null");
         }
         if(showBuy)
         {
            if(m_element.tooltip_mc.buy_bt)
            {
               removeWidget(m_element.tooltip_mc.buy_bt);
               this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.buy_bt,ZLocUtils.t("Dialogs","Market"),this.onClickMarket)) as FarmAnimatedTextButton;
               this.m_buyButton.visible = true;
            }
         }
         else if(this.m_buyButton != null)
         {
            this.m_buyButton = null;
         }
         if(showRemove)
         {
            if(m_element.tooltip_mc.remove_bt)
            {
               removeWidget(m_element.tooltip_mc.remove_bt);
               this.m_removeButton = addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.remove_bt,ZLocUtils.t("Dialogs","Generic_CompletedRemove"),this.animalMouseClickHandler)) as FarmAnimatedTextButton;
               this.m_removeButton.visible = true;
            }
         }
         else if(this.m_removeButton != null)
         {
            this.m_removeButton = null;
         }
         if(showText)
         {
            if(m_element.tooltip_mc.generic_tf)
            {
               removeWidget(m_element.tooltip_mc.generic_tf);
               this.m_notAvailable = addWidget(new ZwTextField(m_element.tooltip_mc.generic_tf,ZLocUtils.t("Dialogs","AnimalWildlifePen_Dialog_NotAvailable"))) as ZwTextField;
               this.m_notAvailable.visible = true;
            }
         }
         else if(this.m_notAvailable != null)
         {
            this.m_notAvailable = null;
         }
         if(this.popupHasIcon)
         {
            if(showPopup)
            {
               this.m_popupIcon.visible = true;
            }
            else
            {
               this.m_popupIcon.visible = false;
            }
         }
         m_element.tooltip_mc.visible = this.popupHasIcon || (showBuy || showRemove || showText);
      }
      
      protected function showPopupIcon(state:int) : void
      {
         var babyItem:FarmItem = null;
         var babyName:String = null;
         var breedingShare:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            babyName = this.m_farmItem.getStringFromDataSource("baby");
            breedingShare = this.m_farmItem.getStringFromDataSource("breedingShare");
         }
         else
         {
            babyName = this.m_farmItem.xml.baby;
            breedingShare = this.m_farmItem.xml.breedingShare;
         }
         if(state != TOOLTIP_NOTAVAIALABLE)
         {
            if(null != babyName && "" != babyName)
            {
               babyItem = Global.farmGameSettingsManager.getFarmItemByName(babyName);
            }
            else if(breedingShare == "common" || breedingShare == "exclusiveCommon")
            {
               babyItem = Global.farmGameSettingsManager.getFarmItemByCode(this.commonBabyCode);
            }
            else if(breedingShare == "rare" || breedingShare == "exclusiveRare")
            {
               babyItem = Global.farmGameSettingsManager.getFarmItemByCode(this.rareBabyCode);
            }
            if(babyItem)
            {
               if(this.m_popupIcon.getIconWidth() != TOOLTIP_ICON_SIZE)
               {
                  this.m_popupIcon.setIconSize(TOOLTIP_ICON_SIZE,TOOLTIP_ICON_SIZE);
               }
               this.m_popupIcon.loadIcon(babyItem.icon);
            }
            else if(Boolean(this.m_farmItem as IUGCItem) || this.m_useFarmItemAsPopupIcon)
            {
               if(this.m_popupIcon.getIconWidth() != TOOLTIP_ICON_SIZE)
               {
                  this.m_popupIcon.setIconSize(TOOLTIP_ICON_SIZE,TOOLTIP_ICON_SIZE);
               }
               this.m_popupIcon.loadIcon(this.m_farmItem.icon);
            }
            else if(babyItem == null && babyName == "")
            {
               this.m_popupIcon.clearDimensions();
               this.m_popupIcon.loadIcon(BABY_NOT_AVAILABLE_ICON);
            }
            else
            {
               this.m_popupIcon.visible = false;
            }
         }
      }
      
      protected function isSharable() : Boolean
      {
         var babyName:String = null;
         var breedingShare:String = null;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            babyName = this.m_farmItem.getStringFromDataSource("baby");
            breedingShare = this.m_farmItem.getStringFromDataSource("breedingShare");
         }
         else
         {
            babyName = this.m_farmItem.xml.baby;
            breedingShare = this.m_farmItem.xml.breedingShare;
         }
         if((breedingShare == "exclusiveCommon" || breedingShare == "exclusiveRare") && (null == babyName || "" == babyName))
         {
            result = false;
         }
         return result;
      }
      
      public function get commonBabyCode() : String
      {
         var itemName:String = null;
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemName = this.m_parentWindow.building.getItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME).getString("rewardItemCommon");
         }
         else
         {
            itemName = this.m_parentWindow.building.getItem().getFeatureXMLByName("harvester").rewardItemCommon;
         }
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(farmItem != null)
         {
            result = farmItem.code;
         }
         return result;
      }
      
      public function get rareBabyCode() : String
      {
         var itemName:String = null;
         var result:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemName = this.m_parentWindow.building.getItem().getFeatureDataByName(FeatureManager.HARVEST_FEATURE_NAME).getString("rewardItemRare");
         }
         else
         {
            itemName = this.m_parentWindow.building.getItem().getFeatureXMLByName("harvester").rewardItemRare;
         }
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(farmItem != null)
         {
            result = farmItem.code;
         }
         return result;
      }
      
      protected function get popupHasIcon() : Boolean
      {
         return this.m_popupIcon != null;
      }
   }
}

