package Widgets.Windows.LimitedGifting
{
   import Classes.Constants.Experiments;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.QueuedIcon;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Managers.LimitedGiftingManager;
   import Managers.TemplateUIUtility;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Transactions.TLimitedGiftingSend;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LimitedGifting.LimitedGiftingItemsSlotFrame;
   import Widgets.Frames.LimitedGifting.LimitedGiftingSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Slots.LimitedGifting.LimitedGiftingItemSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class LimitedGiftingWindow extends FarmWindow
   {
      
      public static const LIMITED_GIFTING_FLAG:String = "LimitedGifting_";
      
      private static const GIFT_ICON_SIZE:int = 100;
      
      private static const GIFTING_USD:String = "USD";
      
      public static const GIFTING_FC:String = "FC";
      
      private static const LATEST_CHOSEN_RECIPIENTS:String = "latest_chosen_recipients";
      
      private static const MAX_USD_RETRY:int = 5;
      
      private static const MAX_GIFTABLE_FRIENDS:int = 6;
      
      private static const MFS_GIFTING_SELECT_LOWER:int = 6;
      
      private static const MFS_GIFTING_SELECT_HIGHER:int = 8;
      
      private var m_featureName:String;
      
      private var m_giftingCurrency:String;
      
      private var m_USDCost:Number;
      
      private var m_featureConfig:LimitedGiftingManager;
      
      private var m_friendsList:Array;
      
      private var m_friendsSlotFrame:LimitedGiftingSlotFrame;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_costText:ZwTextField;
      
      private var m_mainDescriptionText:ZwTextField;
      
      private var m_shouldShowArrows:Boolean = false;
      
      protected var m_sortByButton:FarmTabButton;
      
      protected var m_sortByMenu:DropDownMenu;
      
      private var m_friendData:Object;
      
      private var m_giftItems:Array;
      
      private var m_giftingSlotFrame:LimitedGiftingItemsSlotFrame;
      
      private var m_totalCost:Number;
      
      private var m_giftItemNames:Array;
      
      private var m_isGiftingWithChoice:Boolean = false;
      
      private var m_indiciesToPreselect:Array;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_slotBGIcon:DisplayObject;
      
      private var m_npcUrl:String;
      
      private var m_npcLoader:ImageLoader = null;
      
      private var m_npcIcon:DisplayObject = null;
      
      public function LimitedGiftingWindow(extraData:Object)
      {
         var windowAssetRelUrl:String = null;
         var suggestedIds:Array = null;
         var shuffleTemp:Array = null;
         var i:int = 0;
         this.m_featureName = extraData.featureName;
         this.m_featureConfig = new LimitedGiftingManager(this.m_featureName);
         this.m_friendsList = new Array();
         this.m_giftingCurrency = this.m_featureConfig.giftingCurrency;
         this.m_isGiftingWithChoice = this.m_featureConfig.isGiftingWithChoice;
         this.m_dialogBackground = extraData.mainWindowBackgroundImage;
         this.m_npcUrl = this.m_featureConfig.npcUrl;
         if(this.m_isGiftingWithChoice)
         {
            windowAssetRelUrl = extraData.giftingUIUrlChoice;
            this.m_indiciesToPreselect = this.m_featureConfig.preselectIndices;
         }
         else
         {
            windowAssetRelUrl = extraData.giftingUIUrl;
         }
         super(windowAssetRelUrl);
         if(this.m_giftingCurrency == null)
         {
            this.m_giftingCurrency = "FC";
         }
         this.m_USDCost = this.m_featureConfig.getUSDCost();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIMITED_GIFTING) > 1)
         {
            this.m_shouldShowArrows = true;
            this.m_friendData = extraData.friendsList["requestedFriends"];
            if(this.m_friendData != null)
            {
               if(this.m_friendData["CurrentMostGifts"] != null && this.m_friendData["CurrentMostGifts"].length > 0)
               {
                  this.m_friendsList = this.m_friendData["CurrentMostGifts"];
               }
               else if(this.m_friendData["CurrentFriendsAlpha"] != null)
               {
                  this.m_friendsList = this.m_friendData["CurrentFriendsAlpha"];
               }
            }
         }
         else
         {
            suggestedIds = extraData.friendsList as Array;
            shuffleTemp = new Array();
            for(i = 0; i < suggestedIds.length; i++)
            {
               if(!Global.player.getSeenSessionFlag(LIMITED_GIFTING_FLAG + suggestedIds[i]))
               {
                  shuffleTemp.push(suggestedIds[i]);
               }
            }
            while(shuffleTemp.length > 0)
            {
               this.m_friendsList.push(shuffleTemp.splice(Math.round(Math.random() * (shuffleTemp.length - 1)),1)[0]);
            }
         }
         this.updateFriends();
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         if(this.m_npcUrl != null)
         {
            this.m_npcLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_npcUrl));
            this.m_npcLoader.getContent(this.onNpcLoad);
         }
      }
      
      public static function getCashPackage(cashNeeded:int) : Number
      {
         var pack:Object = null;
         var difference:int = 0;
         var cashPackages:Array = InGamePaymentsManager.packages;
         var smallestViable:Number = -1;
         for each(pack in cashPackages)
         {
            difference = parseInt(pack["amount"]) + Global.player.cash - cashNeeded;
            if(difference >= 0 && (difference < smallestViable || smallestViable == -1))
            {
               smallestViable = difference;
            }
         }
         if(smallestViable == -1)
         {
            FarmStatsManager.count("error","GenericExpandSlot","whichCashPackage","No package viable");
            smallestViable = Global.player.cash - cashNeeded;
         }
         return smallestViable - Global.player.cash + cashNeeded;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function get giftingCurrency() : String
      {
         var result:String = GIFTING_FC;
         if(this.m_giftingCurrency == GIFTING_USD && this.m_USDCost != 0)
         {
            result = GIFTING_USD;
         }
         else
         {
            this.m_giftingCurrency = GIFTING_FC;
         }
         return result;
      }
      
      private function onNpcLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_npcIcon = dispObj;
      }
      
      private function updateFriends() : void
      {
         var subtitle:String = null;
         for(var i:int = 0; i < this.m_friendsList.length; i++)
         {
            if(Global.player.getSeenSessionFlag(LIMITED_GIFTING_FLAG + this.m_friendsList[i].uid))
            {
               this.m_friendsList.splice(i,1);
            }
         }
         if(this.m_friendsSlotFrame != null)
         {
            this.m_friendsSlotFrame.items = this.m_friendsList;
         }
         if(this.m_mainDescriptionText != null)
         {
            if(this.m_friendsList.length > 1)
            {
               subtitle = ZLocUtils.t("Dialogs",this.m_featureName + "_subtitle",{"friendCount":this.m_friendsList.length.toString()});
            }
            else
            {
               subtitle = ZLocUtils.t("Dialogs",this.m_featureName + "_subtitleSingle",{"friendName":this.m_friendsList[0].name});
            }
            this.m_mainDescriptionText.text = subtitle;
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var giftItemName:String = null;
         var giftItem:FarmItem = null;
         var giftCost:Number = NaN;
         var rewardItem:FarmItem = null;
         var title_mc:FarmIcon = null;
         var descriptionText:String = null;
         var subtitle:String = null;
         var slotV100Path:String = null;
         var sortByMenuItems:Array = null;
         var tabName:String = null;
         var menuItem:MenuItem = null;
         var maxFriends:int = 0;
         var text1:String = null;
         var text2:String = null;
         var farmIcon:FarmIcon = null;
         var objPreview:ObjectPreviewFrame = null;
         var rewardIcon:FarmIcon = null;
         super.onLoadComplete(event);
         FarmStatsManager.count("dialog",this.m_featureName,"sender","view");
         if(this.m_featureConfig.isFeatureVisible())
         {
            this.m_giftItems = new Array();
            this.m_giftItemNames = new Array();
            for each(giftItemName in this.m_featureConfig.giftableItems)
            {
               this.m_giftItemNames.push(giftItemName);
               this.m_giftItems.push(Global.farmGameSettingsManager.getFarmItemByName(giftItemName));
            }
            giftItem = this.getGiftFarmItem();
            giftCost = giftItem.cash;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_featureConfig.appreciationItem);
            title_mc = null;
            if(m_window.hasOwnProperty("title_tf"))
            {
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.location))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_title")));
            }
            if(m_window.hasOwnProperty("whatisthis_mc"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.howDoesThisWorkClick));
            }
            if(m_window.hasOwnProperty("buy_bt"))
            {
               this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,"",null);
               if(m_window.buy_bt.hasOwnProperty("cost_tf"))
               {
                  this.m_costText = new ZwTextField(m_window.buy_bt.cost_tf,"");
               }
            }
            if(this.giftingCurrency == GIFTING_USD)
            {
               giftCost = this.m_USDCost;
               if(m_window.hasOwnProperty("buy2_bt"))
               {
                  this.m_buyButton = new FarmAnimatedTextButton(m_window.buy2_bt,"",null);
                  this.m_costText = new ZwTextField(m_window.buy2_bt.cost_tf,"");
               }
               if(m_window.hasOwnProperty("title_usd_mc"))
               {
                  title_mc = new FarmIcon(m_window.title_usd_mc);
               }
            }
            else if(m_window.hasOwnProperty("title_fc_mc"))
            {
               title_mc = new FarmIcon(m_window.title_fc_mc);
            }
            if(this.m_buyButton != null)
            {
               addWidget(this.m_buyButton);
            }
            if(this.m_costText != null)
            {
               addWidget(this.m_costText);
            }
            if(title_mc)
            {
               addWidget(title_mc);
            }
            if(this.m_shouldShowArrows)
            {
               this.m_sortByButton = addWidget(new FarmTabButton(m_window.sortBy_bt,ZLocUtils.t("Dialogs","SortBy"))) as FarmTabButton;
               (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver,false,0,true);
               (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
               this.m_sortByMenu = addWidget(new DropDownMenu(m_window.frame_subNav2_mc,this.onSortByMenuItemSelected),false) as DropDownMenu;
               (this.m_sortByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
               sortByMenuItems = [];
               for(tabName in this.m_friendData)
               {
                  menuItem = new MenuItem(tabName,ZLocUtils.t("Dialogs",tabName));
                  sortByMenuItems.push(menuItem);
               }
               this.m_sortByMenu.items = sortByMenuItems;
            }
            descriptionText = "Choose exclusive gifts to send to your friends!";
            if(this.m_friendsList.length > 1)
            {
               maxFriends = this.m_shouldShowArrows ? int(this.m_friendsList.length) : int(Math.min(MAX_GIFTABLE_FRIENDS,this.m_friendsList.length));
               subtitle = ZLocUtils.t("Dialogs",this.m_featureName + "_subtitle",{"friendCount":maxFriends.toString()});
            }
            else if(this.m_friendsList.length == 1)
            {
               subtitle = ZLocUtils.t("Dialogs",this.m_featureName + "_subtitleSingle",{"friendName":this.m_friendsList[0].name});
            }
            addWidget(this.m_mainDescriptionText = new ZwTextField(m_window.generic_tf,subtitle));
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.location))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.generic_tf);
            }
            addWidget(new ZwTextField(m_window.generic2_tf,descriptionText));
            if(m_window.hasOwnProperty("generic3_tf") && Boolean(rewardItem))
            {
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.location))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.generic3_tf);
               }
               addWidget(new ZwTextField(m_window.generic3_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_senderGift",{"rewardName":rewardItem.friendlyTitle})));
            }
            if(m_window.hasOwnProperty("info_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.info_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_ClickHereText"),this.onMoreInfoClick));
            }
            if(m_window.hasOwnProperty("body1_tf") && this.m_featureName != "BirthdayPaidGifting")
            {
               text1 = ZLocUtils.t("Dialogs",this.m_featureName + "_senderGift");
               addWidget(new ZwTextField(m_window.body1_tf,text1));
            }
            if(m_window.hasOwnProperty("body2_tf"))
            {
               text2 = ZLocUtils.t("Dialogs",this.m_featureName + "_body2");
               addWidget(new ZwTextField(m_window.body2_tf,text2));
            }
            if(this.m_isGiftingWithChoice)
            {
               this.m_giftingSlotFrame = new LimitedGiftingItemsSlotFrame(m_window.slotFrame_mc,this.onSlotClick,false,this.updateButtonText);
               this.m_giftingSlotFrame.items = this.m_giftItems;
               addWidget(this.m_giftingSlotFrame);
               this.m_giftingSlotFrame.centerSlots();
               this.setNumberOfSelectedItems();
            }
            else
            {
               if(m_window.hasOwnProperty("rewardName_tf") && Boolean(giftItem))
               {
                  addWidget(new ZwTextField(m_window.rewardName_tf,giftItem.friendlyTitle));
               }
               if(m_window.hasOwnProperty("individualCost_tf"))
               {
                  addWidget(new ZwTextField(m_window.individualCost_tf,ZLocUtils.t("Dialogs","limitedGifting_individualPrice_" + this.giftingCurrency,{"cost":giftCost})));
               }
               farmIcon = new FarmIcon(m_window.icon_mc);
               farmIcon.loadIcon(giftItem.icon);
               farmIcon.setIconSize(GIFT_ICON_SIZE,GIFT_ICON_SIZE);
               farmIcon.visible = true;
               addWidget(farmIcon);
            }
            if(this.m_isGiftingWithChoice)
            {
               objPreview = new ObjectPreviewFrame(m_window.icon2_mc,rewardItem,null,null,null,"","",null,new Point(35,35));
               addWidget(objPreview);
            }
            else
            {
               rewardIcon = new FarmIcon(m_window.icon2_mc);
               addWidget(rewardIcon);
               rewardIcon.loadIcon(rewardItem.icon);
               rewardIcon.setIconSize(GIFT_ICON_SIZE,GIFT_ICON_SIZE);
               rewardIcon.visible = true;
            }
            this.m_friendsSlotFrame = new LimitedGiftingSlotFrame(m_window.slotcontainer_mc,this.onSlotClick,this.m_shouldShowArrows,this.updateButtonText);
            this.m_friendsSlotFrame.items = this.m_friendsList;
            this.setNumberOfSelected();
            addWidget(this.m_friendsSlotFrame);
            this.updateButtonText();
            if(m_window.hasOwnProperty("mc_AnimalFrame_big") && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame_big));
            }
            slotV100Path = Global.worldSettingsManager.getSlotBGImagePath("V100",this.m_featureConfig.location);
            if(slotV100Path)
            {
               ImageLoader.getInstance(Global.getAssetURL(slotV100Path)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_window["mc_Slot_V_0"].addChild(this.m_slotBGIcon);
                  m_window["mc_Slot_V_0"].visible = true;
               }
            }
            if(Boolean(m_window.mc_NPC) && Boolean(this.m_npcIcon))
            {
               m_window.mc_NPC.addChild(this.m_npcIcon);
               m_window.mc_NPC.visible = true;
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function setNumberOfSelectedItems() : void
      {
         if(this.m_isGiftingWithChoice)
         {
            this.m_giftingSlotFrame.setNumberOfSelected(this.m_indiciesToPreselect);
         }
      }
      
      private function setNumberOfSelected() : void
      {
         switch(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIMITED_GIFTING))
         {
            case 2:
               this.m_friendsSlotFrame.setNumberOfSelected(MFS_GIFTING_SELECT_LOWER);
               break;
            case 3:
               this.m_friendsSlotFrame.setNumberOfSelected(MFS_GIFTING_SELECT_HIGHER);
         }
      }
      
      private function onBuyClick(evt:Event) : void
      {
         var itemNames:String = null;
         var gift:FarmItem = null;
         if(this.m_totalCost > 10)
         {
            if(this.m_isGiftingWithChoice)
            {
               itemNames = this.getSelectedItemNames();
            }
            else
            {
               gift = this.getGiftFarmItem();
               itemNames = gift.friendlyTitle;
            }
            UI.displayMessage(ZLocUtils.t("Dialogs","gifting_confirmation",{
               "cash":this.m_totalCost,
               "itemNames":itemNames
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationClicked,"",true);
         }
         else
         {
            this.onSendGift(evt);
         }
      }
      
      private function onConfirmationClicked(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.OK)
         {
            this.onSendGift(evt);
         }
      }
      
      private function getSelectedItemNames() : String
      {
         var slot:LimitedGiftingItemSlot = null;
         var itemNames:String = "";
         for each(slot in this.m_giftingSlotFrame.slots)
         {
            if(Boolean(slot.item) && slot.selected)
            {
               if(itemNames.length != 0)
               {
                  itemNames += ", ";
               }
               itemNames += slot.item.friendlyTitle;
            }
         }
         return itemNames;
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         var howDoesThisWorkDialog:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs",this.m_featureName + "_howDoesThisWork"),GenericPopup.TYPE_OK);
         UI.displayPopup(howDoesThisWorkDialog,false,this.m_featureName + "_howDoesThisWorkPopup",true);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_friendsList = null;
         this.m_friendsSlotFrame = null;
         this.m_buyButton = null;
         this.m_costText = null;
         this.m_mainDescriptionText = null;
      }
      
      private function onSlotClick() : void
      {
         this.updateButtonText();
      }
      
      protected function onMoreInfoClick(event:MouseEvent) : void
      {
         var url:String = ZLocUtils.t("Dialogs",this.m_featureName + "_ClickHereUrl");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function updateButtonText() : void
      {
         var slot:LimitedGiftingItemSlot = null;
         var gift:FarmItem = null;
         var requiredUSD:int = 0;
         var requiredCash:int = 0;
         var totalCost:Number = 0;
         if(this.m_isGiftingWithChoice)
         {
            if(m_window.hasOwnProperty("slotFrame_mc"))
            {
               for each(slot in this.m_giftingSlotFrame.slots)
               {
                  if(slot.selected)
                  {
                     totalCost += slot.cash;
                  }
               }
            }
         }
         else
         {
            gift = this.getGiftFarmItem();
            totalCost = gift.cash;
         }
         var numFriends:int = int(this.m_friendsSlotFrame.getSelectedFriends().length);
         if(numFriends > 0)
         {
            if(this.giftingCurrency == GIFTING_USD)
            {
               requiredUSD = this.m_USDCost * numFriends;
               this.m_costText.text = requiredUSD.toString();
               this.m_buyButton.callback = this.onBuyClick;
               this.m_buyButton.enabled = true;
               this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingBuyAndSend");
               this.m_buyButton.applyGrayOut = false;
               this.m_totalCost = requiredUSD;
            }
            else
            {
               requiredCash = totalCost * numFriends;
               if(Global.player.cash >= requiredCash)
               {
                  this.m_costText.text = requiredCash.toString();
                  this.m_buyButton.callback = this.onBuyClick;
                  this.m_buyButton.enabled = true;
                  this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingBuyAndSend");
                  this.m_buyButton.applyGrayOut = false;
               }
               else
               {
                  this.m_costText.text = requiredCash.toString();
                  this.m_buyButton.callback = this.inAppPurchase;
                  this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingNotEnoughCash");
                  this.m_buyButton.enabled = true;
                  this.m_buyButton.applyGrayOut = false;
               }
               this.m_totalCost = requiredCash;
            }
         }
         else
         {
            this.m_costText.text = "0";
            this.m_buyButton.enabled = false;
            this.m_buyButton.applyGrayOut = true;
            this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingBuyAndSend");
            this.m_totalCost = 0;
         }
      }
      
      private function onSendGift(event:Event) : void
      {
         var gift:FarmItem = null;
         var recipients:Array = null;
         var selectedItems:Array = null;
         var slot:LimitedGiftingItemSlot = null;
         var itemIndex:Number = NaN;
         if(this.m_isGiftingWithChoice)
         {
            selectedItems = new Array();
            for each(slot in this.m_giftingSlotFrame.slots)
            {
               if(slot.selected)
               {
                  gift = Global.farmGameSettingsManager.getFarmItemByName(slot.itemName);
                  recipients = this.m_friendsSlotFrame.getSelectedFriends();
                  FarmStatsManager.count("dialog",this.m_featureName,"click",recipients.length.toString());
                  FarmStatsManager.count("dialog",this.m_featureName,"enough",recipients.length.toString());
                  if(this.giftingCurrency == GIFTING_USD)
                  {
                     FarmStatsManager.count("fv_buyableGift","send_gift",gift.name,this.m_USDCost.toString());
                     PaymentUtil.instance.addGiftToCart(gift.code,recipients.length,"ZORG:" + this.m_featureName + ":" + gift.name,this.onPaymentSuccess,this.onPaymentFailure);
                     TransactionManager.addTransaction(new TGenericTransaction("PresentService","storeUSDLatestChosen",null,[recipients]),true);
                  }
                  else
                  {
                     FarmStatsManager.count("fv_buyableGift","send_gift",gift.name,gift.cash.toString());
                     Global.player.cash -= gift.cash * recipients.length;
                  }
                  itemIndex = this.m_giftItemNames.indexOf(slot.itemName);
                  selectedItems.push(itemIndex);
               }
            }
            this.giftFriends(selectedItems);
         }
         else
         {
            gift = this.getGiftFarmItem();
            recipients = this.m_friendsSlotFrame.getSelectedFriends();
            FarmStatsManager.count("dialog",this.m_featureName,"click",recipients.length.toString());
            FarmStatsManager.count("dialog",this.m_featureName,"enough",recipients.length.toString());
            if(this.giftingCurrency == GIFTING_USD)
            {
               FarmStatsManager.count("fv_buyableGift","send_gift",gift.name,this.m_USDCost.toString());
               PaymentUtil.instance.addGiftToCart(gift.code,recipients.length,"ZORG:" + this.m_featureName + ":" + gift.name,this.onPaymentSuccess,this.onPaymentFailure);
               TransactionManager.addTransaction(new TGenericTransaction("PresentService","storeUSDLatestChosen",null,[recipients]),true);
            }
            else
            {
               FarmStatsManager.count("fv_buyableGift","send_gift",gift.name,gift.cash.toString());
               Global.player.cash -= gift.cash * recipients.length;
               this.giftFriends();
            }
         }
      }
      
      private function onPaymentSuccess(orderId:String, status:String) : void
      {
         GlobalEngine.info("PaidGifting","onPaymentSuccess [status=" + status + "]");
         FarmStatsManager.count("paidGifting_" + this.giftingCurrency,"payment_completed");
         this.giftFriends();
      }
      
      private function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
         FarmStatsManager.count("paidGifting_" + this.giftingCurrency,"onPaymentsFail","[code=" + errorCode + ", msg=" + errorMessage + "]");
      }
      
      private function giftFriends(itemIndexArray:Array = null) : void
      {
         var list:Object = null;
         var friendList:Object = null;
         var recipient:Number = NaN;
         var i:int = 0;
         var recipients:Array = this.m_friendsSlotFrame.getSelectedFriends();
         var limitedGiftingIcon:QueuedIcon = Global.hud.rightSideIconQueue.getIconByName("limitedGifting");
         var listsToSplice:Array = new Array();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIMITED_GIFTING) > 1)
         {
            for each(friendList in this.m_friendData)
            {
               listsToSplice.push(friendList);
            }
         }
         else
         {
            listsToSplice.push(this.m_friendsList);
         }
         for each(list in listsToSplice)
         {
            for each(recipient in recipients)
            {
               Global.player.setSeenSessionFlag(LIMITED_GIFTING_FLAG + recipient);
               for(i = 0; i < list.length; i++)
               {
                  if(recipient == list[i].uid)
                  {
                     list.splice(i,1);
                     break;
                  }
               }
            }
         }
         this.m_friendsSlotFrame.items = this.m_friendsList;
         if(this.m_isGiftingWithChoice)
         {
            TransactionManager.addTransaction(new TLimitedGiftingSend(this.m_featureName,recipients,this.onGiftingSuccess,0,true,itemIndexArray),true);
         }
         else
         {
            TransactionManager.addTransaction(new TLimitedGiftingSend(this.m_featureName,recipients,this.onGiftingSuccess),true);
         }
         if(this.m_friendsList.length > 0)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIMITED_GIFTING) > 1)
            {
               limitedGiftingIcon.extraData.friendsList["requestedFriends"] = this.m_friendData;
            }
            else
            {
               limitedGiftingIcon.extraData["friendsList"] = this.m_friendsList;
            }
            this.updateFriends();
            this.updateButtonText();
            refreshWindow();
         }
         else
         {
            Global.hud.rightSideIconQueue.removeIconByName("limitedGifting");
            close();
         }
      }
      
      private function onGiftingSuccess(result:Object) : void
      {
         var retryCount:int = 0;
         var recipients:Array = null;
         if(this.m_giftingCurrency == GIFTING_USD)
         {
            retryCount = int(result["retryCount"]);
            recipients = result["recipients"];
            if(result["USDProcessed"] != null && result["USDProcessed"] == false)
            {
               if(retryCount > MAX_USD_RETRY)
               {
                  FarmStatsManager.count("paidGifting_" + this.giftingCurrency,"reached max transaction retry count");
               }
               else
               {
                  TransactionManager.addTransaction(new TLimitedGiftingSend(this.m_featureName,recipients,this.onGiftingSuccess,++retryCount),true);
               }
            }
            else
            {
               this.sendSuccessToaster(result);
            }
         }
         else
         {
            this.sendSuccessToaster(result);
         }
      }
      
      private function sendSuccessToaster(result:Object) : void
      {
         var giftItem:FarmItem = null;
         var gift:FarmItem = null;
         var rewardName:String = this.m_featureConfig.appreciationItem;
         if(this.m_giftItemNames.length != 0)
         {
            for each(giftItem in this.m_giftItems)
            {
               FarmStatsManager.count("fv_buyableGift","transaction_complete",giftItem.name,giftItem.cash.toString());
            }
         }
         else
         {
            gift = this.getGiftFarmItem();
            FarmStatsManager.count("fv_buyableGift","transaction_complete",gift.name,gift.cash.toString());
         }
         if(rewardName != null)
         {
            Global.player.addGift(rewardName);
            ToasterManager.getInstance().add(new LimitedGiftingSendToasterWindow(rewardName,this.m_featureName));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("dialog",this.m_featureName,"sender","x");
         super.onClose(event);
      }
      
      private function inAppPurchase(event:Event) : void
      {
         var gift:FarmItem = this.getGiftFarmItem();
         var numFriends:int = int(this.m_friendsSlotFrame.getSelectedFriends().length);
         FarmStatsManager.count("fv_buyableGift","not_enough_cash",gift.name,gift.cash.toString());
         FarmStatsManager.count("dialog",this.m_featureName,"click",numFriends.toString());
         FarmStatsManager.count("dialog",this.m_featureName,"insufficient",numFriends.toString());
         PaymentUtil.instance.addCashToCart(LimitedGiftingWindow.getCashPackage(gift.cash * numFriends),"LimitedGifting_" + this.m_featureName,this.onSuccessGetMoreCash);
      }
      
      protected function onSuccessGetMoreCash(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(this.balanceRefreshed),true);
      }
      
      protected function balanceRefreshed(result:Object) : void
      {
         this.updateButtonText();
      }
      
      private function getGiftFarmItem() : FarmItem
      {
         var giftableFarmItem:FarmItem = null;
         if(Boolean(this.m_featureConfig) && Boolean(this.m_featureConfig.giftableItem))
         {
            giftableFarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_featureConfig.giftableItem);
         }
         return giftableFarmItem;
      }
      
      private function onSortByMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_sortByMenu.visible)
         {
            this.m_sortByButton.setToggleState(ZwToggleState.SELECTED);
            this.m_sortByMenu.visible = true;
         }
      }
      
      private function onSortByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_sortByButton.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_sortByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_sortByMenu.visible = false;
         }
      }
      
      private function onSortByMenuItemSelected(item:MenuItem) : void
      {
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         this.m_friendsList = this.m_friendData[item.data];
         this.m_friendsSlotFrame.items = this.m_friendsList;
         this.setNumberOfSelected();
         this.updateButtonText();
      }
   }
}

