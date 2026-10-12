package Widgets.Windows.Crafting
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingStatsManager;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.Crafting.CraftedGoodOffering;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketStallOffering;
   import Managers.Crafting.MarketViewManager;
   import Managers.Crafting.SmartBushelHelper;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.SocialMissions.SMTabButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwToggle;
   import Widgets.Frames.Crafting.BagsRemainingFrame;
   import Widgets.Frames.Crafting.PurchaseLimitHitFrame;
   import Widgets.Frames.Crafting.SiloFullFrame;
   import Widgets.Frames.Crafting.VisitingMarketStallSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   
   public class VisitingMarketStallWindow extends FarmWindow
   {
      
      public const RENDER_MODE_BUSHELS:String = "bushels";
      
      public const RENDER_MODE_CRAFTS:String = "crafts";
      
      protected var m_CurrentUser:String = "0";
      
      protected var m_LastBushelTaken:String;
      
      protected var m_LastItemTaken:MarketInventoryItem;
      
      protected var m_CurrentFriend:Friend = null;
      
      protected var m_marketStallOffering:MarketStallOffering;
      
      protected var m_craftedGoodOffering:CraftedGoodOffering;
      
      protected var m_SingleOfferingFrame:VisitingMarketStallSlotFrame;
      
      protected var m_DoubleOfferingFrame:VisitingMarketStallSlotFrame;
      
      protected var m_MultipleOfferingFrame:VisitingMarketStallSlotFrame;
      
      protected var m_BagsRemainingFrame:BagsRemainingFrame;
      
      protected var m_SiloFullFrame:SiloFullFrame;
      
      protected var m_PurchaseLimitHitFrame:PurchaseLimitHitFrame;
      
      protected var m_SendThankYouFrame:ZwFrame;
      
      protected var m_instructionsFrame:ZwFrame;
      
      protected var m_lastIcon:FarmIcon;
      
      protected var m_mode:String;
      
      protected var m_bushelToPresort:String;
      
      protected var m_thankYouFeedBundle:String;
      
      private var m_tabShowBundlesButton:SMTabButton;
      
      private var m_tabShowCraftsButton:SMTabButton;
      
      private var m_toggleShowBundles:uint;
      
      private var m_toggleShowCrafts:uint;
      
      private var m_toggleManager:ZwToggleManager;
      
      private var m_checkboxText:String;
      
      private var m_checkBox:MovieClip;
      
      private var m_checkMark:MovieClip;
      
      private var m_selected:Boolean;
      
      public function VisitingMarketStallWindow(uid:String, mode:String, thankYouFeedBundle:String = "", bushelItemCodeToPresort:String = "")
      {
         this.m_CurrentUser = uid;
         this.m_bushelToPresort = bushelItemCodeToPresort;
         if(SmartBushelHelper.inExperiment() && uid == SmartBushelHelper.FICTIONAL_CHARACTER_ID)
         {
            this.m_CurrentFriend = SmartBushelHelper.getFriendData();
         }
         else
         {
            this.m_CurrentFriend = Global.friendManager.getFriendData(uid);
         }
         this.m_thankYouFeedBundle = thankYouFeedBundle;
         var assetPath:String = "assets/dialogs/FV_Craft_FriendStall.swf";
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            assetPath = "assets/dialogs/FV_Craft_FriendStall_checkbox.swf";
         }
         super(assetPath);
         this.m_mode = mode;
      }
      
      public function SetThankYouFeedBundle(thankYouFeedBundle:String) : void
      {
         this.m_thankYouFeedBundle = thankYouFeedBundle;
      }
      
      override protected function postLoadComplete() : void
      {
         var playerIcon:FarmIcon = null;
         CraftingStatsManager.recordFriendMarketStallPageView();
         addWidget(new ZwTextField(m_window.goldTitle_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Title")));
         if(this.isSmartBushels())
         {
            addWidget(new ZwTextField(m_window.friendName_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_SubTitle",{"user":ZLocUtils.tn(this.m_CurrentFriend.name,ZLocUtils.tg("m"))})));
            playerIcon = new FarmIcon(m_window.friendIcon_mc,SmartBushelHelper.getFriendData().picture);
         }
         else
         {
            addWidget(new ZwTextField(m_window.friendName_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_SubTitle",{"user":ZLocUtils.tn(this.m_CurrentFriend.name,ZLocUtils.tg(Global.friendManager.getFriendGender(this.m_CurrentFriend.uid)))})));
            playerIcon = new FarmIcon(m_window.friendIcon_mc,FarmGameUtil.getFriendIconByUid(this.m_CurrentUser));
         }
         playerIcon.setIconSize(50,50);
         addWidget(playerIcon);
         addWidget(new FarmAnimatedTextButton(m_window.howDoes_mc,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_MoreInfo"),this.onMoreInfoClick));
         addWidget(new FarmAnimatedTextButton(m_window.leaveStallGreen_bt,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Close"),this.closeWindow));
         this.m_SingleOfferingFrame = new VisitingMarketStallSlotFrame(m_window.oneStallInventory_mc,new Array(),this.onBushelTaken,this.onItemPurchased,this.m_CurrentUser);
         addWidget(this.m_SingleOfferingFrame,false);
         this.m_DoubleOfferingFrame = new VisitingMarketStallSlotFrame(m_window.twoStallInventory_mc,new Array(),this.onBushelTaken,this.onItemPurchased,this.m_CurrentUser);
         addWidget(this.m_DoubleOfferingFrame,false);
         this.m_MultipleOfferingFrame = new VisitingMarketStallSlotFrame(m_window.multipleStallInventory_mc,new Array(),this.onBushelTaken,this.onItemPurchased,this.m_CurrentUser);
         addWidget(this.m_MultipleOfferingFrame,false);
         this.m_BagsRemainingFrame = new BagsRemainingFrame(m_window.limit_mc,this.m_CurrentUser,this.m_mode == this.RENDER_MODE_CRAFTS);
         addWidget(this.m_BagsRemainingFrame,false);
         this.m_SiloFullFrame = new SiloFullFrame(m_window.siloFull_mc,this.m_mode);
         addWidget(this.m_SiloFullFrame,false);
         this.m_PurchaseLimitHitFrame = new PurchaseLimitHitFrame(m_window.shoppingLimit_mc);
         addWidget(this.m_PurchaseLimitHitFrame,false);
         this.m_SendThankYouFrame = new ZwFrame(m_window.freeGift_mc);
         addWidget(this.m_SendThankYouFrame,false);
         this.m_instructionsFrame = new ZwFrame(m_window.avatarMessage_mc);
         this.m_instructionsFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_BushelInstructions")));
         addWidget(this.m_instructionsFrame,false);
         this.m_toggleManager = new ZwToggleManager();
         this.m_tabShowBundlesButton = new SMTabButton(m_window.shopBushels_bt,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ShopBushels"),this.onShowBushelsClick);
         this.m_tabShowCraftsButton = new SMTabButton(m_window.shopGoods_bt,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ShopCrafts"),this.onShowCraftsClick);
         addWidget(this.m_tabShowBundlesButton);
         addWidget(this.m_tabShowCraftsButton);
         this.m_toggleShowBundles = this.m_toggleManager.addToggle(new ZwToggle(this.m_tabShowBundlesButton),this.m_mode == this.RENDER_MODE_BUSHELS);
         this.m_toggleShowCrafts = this.m_toggleManager.addToggle(new ZwToggle(this.m_tabShowCraftsButton),this.m_mode == this.RENDER_MODE_CRAFTS);
         if(this.m_mode == this.RENDER_MODE_BUSHELS)
         {
            enableInput = false;
            MarketViewManager.getInstance().beginGetMarketOfferingForUser(this.m_CurrentUser,this.onMarketOfferingLoaded);
         }
         else
         {
            enableInput = false;
            MarketViewManager.getInstance().beginGetMarketOfferingForUser(this.m_CurrentUser,this.onCraftedGoodOfferingLoaded);
         }
         this.m_lastIcon = new FarmIcon(m_window.freeGift_mc.friendIcon_mc);
         this.m_SendThankYouFrame.addWidget(this.m_lastIcon);
         this.m_SendThankYouFrame.addWidget(new ZwTextField(m_window.freeGift_mc.popupBox_tf));
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            if(m_window.freeGift_mc.checkMark_mc)
            {
               this.m_checkMark = m_window.freeGift_mc.checkMark_mc as MovieClip;
               this.m_checkMark.mouseEnabled = true;
               this.m_checkMark.visible = this.m_selected = true;
               this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
            }
            if(m_window.freeGift_mc.checkBox_mc)
            {
               this.m_checkBox = m_window.freeGift_mc.checkBox_mc as MovieClip;
               this.m_checkBox.addEventListener(MouseEvent.CLICK,this.onClick);
               this.m_checkBox.visible = true;
            }
            if(m_window.freeGift_mc.checkbox_tf)
            {
               this.m_checkboxText = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ThankYouGift");
               m_window.freeGift_mc.checkbox_tf.visible = true;
               m_window.freeGift_mc.checkbox_tf.text = this.m_checkboxText;
               this.m_SendThankYouFrame.addWidget(new ZwTextField(m_window.freeGift_mc.checkbox_tf));
            }
         }
         else
         {
            this.m_SendThankYouFrame.addWidget(new FarmAnimatedTextButton(m_window.freeGift_mc.accept_bt,"",this.onShareFeedClicked));
            this.m_SendThankYouFrame.addWidget(new FarmAnimatedTextButton(m_window.freeGift_mc.cancel_bt,"",this.closeWindow));
         }
         var isInTutorial:Boolean = Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode;
         if(isInTutorial)
         {
            enableInput = false;
            tintWindow();
            CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_MARKET_STALL);
         }
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      protected function onMoreInfoClick(evt:Event) : void
      {
         CraftingStatsManager.recordFriendMarketStallPageHowDoesWorkClick();
         if(this.m_mode == this.RENDER_MODE_BUSHELS)
         {
            enableInput = false;
            TutorialUI.displayNewMarketStallTutorialWindow(false,this.onTutorialClose);
         }
         else
         {
            TutorialUI.displayCraftingCottageTutorial2Window();
         }
      }
      
      protected function onTutorialClose() : void
      {
         enableInput = true;
      }
      
      protected function onShowBushelsClick(evt:Event) : void
      {
         this.m_mode = this.RENDER_MODE_BUSHELS;
         enableInput = false;
         MarketViewManager.getInstance().beginGetMarketOfferingForUser(this.m_CurrentUser,this.onMarketOfferingLoaded);
      }
      
      protected function onShowCraftsClick(evt:Event) : void
      {
         this.m_mode = this.RENDER_MODE_CRAFTS;
         enableInput = false;
         MarketViewManager.getInstance().beginGetMarketOfferingForUser(this.m_CurrentUser,this.onCraftedGoodOfferingLoaded);
      }
      
      protected function refresh() : void
      {
         var availableInventory:Array = null;
         var isInTutorial:Boolean = false;
         this.setButtonEnables(true);
         this.m_SingleOfferingFrame.visible = false;
         this.m_DoubleOfferingFrame.visible = false;
         this.m_MultipleOfferingFrame.visible = false;
         this.m_SendThankYouFrame.visible = false;
         if(this.renderAppropriateBagFrame() == 0)
         {
            this.renderThankYouFrame();
         }
         else
         {
            if(this.m_mode == this.RENDER_MODE_BUSHELS)
            {
               availableInventory = this.m_marketStallOffering ? this.m_marketStallOffering.availableInventory : [];
               isInTutorial = CraftingManager.getInstance().inTutorialMode;
               this.m_instructionsFrame.visible = !isInTutorial;
            }
            else
            {
               availableInventory = this.m_craftedGoodOffering ? this.m_craftedGoodOffering.availableInventory : [];
               this.m_instructionsFrame.visible = false;
            }
            this.presortAvailableInventory(availableInventory);
            switch(availableInventory.length)
            {
               case 1:
                  this.m_SingleOfferingFrame.setInventory(availableInventory,this.m_mode);
                  this.m_SingleOfferingFrame.visible = true;
                  break;
               case 2:
                  this.m_DoubleOfferingFrame.setInventory(availableInventory,this.m_mode);
                  this.m_DoubleOfferingFrame.visible = true;
                  break;
               default:
                  this.m_MultipleOfferingFrame.setInventory(availableInventory,this.m_mode);
                  this.m_MultipleOfferingFrame.visible = true;
            }
         }
      }
      
      private function presortAvailableInventory(availableInventory:Array) : void
      {
         var marketInventoryItem:MarketInventoryItem = null;
         if(availableInventory.length)
         {
            for each(marketInventoryItem in availableInventory)
            {
               if(this.m_bushelToPresort == marketInventoryItem.itemCode)
               {
                  FarmGameUtil.swapItems(availableInventory,availableInventory[0],marketInventoryItem);
                  break;
               }
            }
         }
      }
      
      private function renderThankYouFrame() : void
      {
         var lastItem:FarmItem = null;
         var bushelOrGood:String = null;
         var lastBushelIcon:FarmIcon = new FarmIcon(m_window.freeGift_mc.friendIcon_mc);
         if(this.m_mode == this.RENDER_MODE_BUSHELS)
         {
            lastItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_LastBushelTaken);
            if(lastItem)
            {
               this.m_SendThankYouFrame.visible = true;
               CraftingStatsManager.recordTakeAllThreeBushelsPageView();
               bushelOrGood = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Bushel");
            }
         }
         else if(this.m_LastItemTaken)
         {
            this.m_SendThankYouFrame.visible = true;
            lastItem = this.m_LastItemTaken.underlyingItem;
            bushelOrGood = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Good");
            FarmStatsManager.count("Crafting","Feed","CraftingCottage_shopped","impressions");
         }
         if(this.isSmartBushels())
         {
            this.m_SendThankYouFrame.visible = false;
         }
         if(this.m_SendThankYouFrame.visible)
         {
            this.m_lastIcon.loadIcon(lastItem.icon);
            if(Global.player.inExperimentFeedCheckBoxV2())
            {
               (this.m_SendThankYouFrame.getWidget(m_window.freeGift_mc.popupBox_tf) as ZwTextField).text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_GotBushel",{"name":ZLocUtils.tk_pk(lastItem.friendlyName)});
               (this.m_SendThankYouFrame.getWidget(m_window.freeGift_mc.checkbox_tf) as ZwTextField).text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ThankYouGift");
            }
            else
            {
               (this.m_SendThankYouFrame.getWidget(m_window.freeGift_mc.popupBox_tf) as ZwTextField).text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ThankYouCTA");
               (this.m_SendThankYouFrame.getWidget(m_window.freeGift_mc.accept_bt) as FarmAnimatedTextButton).text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ThankYouAcceptButton");
               (this.m_SendThankYouFrame.getWidget(m_window.freeGift_mc.cancel_bt) as FarmAnimatedTextButton).text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ThankYouCancelButton");
            }
         }
      }
      
      private function onShareFeedClicked(evt:Event) : void
      {
         if(!this.isSmartBushels())
         {
            if(this.m_mode == this.RENDER_MODE_BUSHELS)
            {
               CraftingStatsManager.recordTakeAllThreeBushelsClickShare();
               CraftingManager.getInstance().beginSendThankYouFeed(this.m_LastBushelTaken,this.m_CurrentUser,this.onShareFeedLoaded,this.m_thankYouFeedBundle);
               enableInput = false;
            }
            else
            {
               CraftingManager.getInstance().sendBuyGoodsReward();
               close();
            }
         }
      }
      
      protected function isSmartBushels() : Boolean
      {
         return SmartBushelHelper.inExperiment() && this.m_CurrentUser == SmartBushelHelper.FICTIONAL_CHARACTER_ID;
      }
      
      private function onShareFeedLoaded(evt:Event = null) : void
      {
         enableInput = true;
         close();
      }
      
      private function renderAppropriateBagFrame() : int
      {
         var purchaseLimit:int = 0;
         this.m_BagsRemainingFrame.isRenderingCraftedGoods = this.m_mode == this.RENDER_MODE_CRAFTS;
         this.m_BagsRemainingFrame.visible = false;
         this.m_BagsRemainingFrame.refresh();
         this.m_SiloFullFrame.visible = false;
         this.m_PurchaseLimitHitFrame.visible = false;
         this.m_PurchaseLimitHitFrame.refresh();
         var remainingBags:int = 0;
         var overLimit:Boolean = false;
         var siloFull:Boolean = false;
         if(this.m_mode == this.RENDER_MODE_BUSHELS)
         {
            remainingBags = CraftingManager.getInstance().getBagsAvailableByUser(this.m_CurrentUser);
            siloFull = Global.player.craftingState.inventoryState.isFull;
            overLimit = Global.player.craftingState.shoppingState.getTotalDailyPurchases() > Global.player.craftingState.shoppingState.maxPurchasesPerDay;
         }
         else
         {
            remainingBags = CraftingManager.getInstance().getCraftingBagsAvailableByUser(this.m_CurrentUser);
            siloFull = Global.player.craftingState.totalCraftedGoods >= Global.storageSettings.maxStorageCap(CraftingConstants.CRAFTED_GOOD_STORAGE_NAME);
            overLimit = Global.player.craftingState.shoppingState.getTotalDailyCraftingPurchases() > Global.player.craftingState.shoppingState.maxCraftingPurchasesPerDay;
         }
         if(overLimit)
         {
            this.m_PurchaseLimitHitFrame.message = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_ShoppingLimit");
            this.m_PurchaseLimitHitFrame.visible = true;
         }
         else if(remainingBags == 0)
         {
            if(this.m_mode == this.RENDER_MODE_BUSHELS)
            {
               purchaseLimit = Global.player.craftingState.shoppingState.maxBagsPerUser;
            }
            else
            {
               purchaseLimit = Global.player.craftingState.shoppingState.maxCraftingBagsPerUser;
            }
            this.m_PurchaseLimitHitFrame.message = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_PerUserPurchaseLimit",{"quantity":purchaseLimit});
            this.m_PurchaseLimitHitFrame.visible = true;
         }
         else if(siloFull)
         {
            this.m_SiloFullFrame.visible = true;
         }
         else
         {
            this.m_BagsRemainingFrame.visible = true;
         }
         return remainingBags;
      }
      
      protected function onMarketOfferingLoaded(uid:String) : void
      {
         if(m_window)
         {
            enableInput = true;
            this.m_marketStallOffering = MarketViewManager.getInstance().getMarketStallOfferingForUser(uid);
            this.refresh();
         }
      }
      
      protected function onCraftedGoodOfferingLoaded(uid:String) : void
      {
         enableInput = true;
         this.m_craftedGoodOffering = MarketViewManager.getInstance().getCraftedGoodOfferingForUser(uid);
         this.refresh();
      }
      
      protected function onBushelTaken(itemCode:String) : void
      {
         this.setButtonEnables(false);
         this.m_LastBushelTaken = itemCode;
         this.renderAppropriateBagFrame();
         CraftingManager.getInstance().beginClaimMarketStallItemFromFriend(this.m_CurrentUser,itemCode);
         this.refresh();
      }
      
      protected function onItemPurchased(inventoryItem:MarketInventoryItem) : void
      {
         this.setButtonEnables(false);
         this.m_LastItemTaken = inventoryItem;
         this.renderAppropriateBagFrame();
         CraftingManager.getInstance().beginBuyCraftedGood(inventoryItem.itemCode,inventoryItem.level,this.m_CurrentUser,inventoryItem.price);
         this.refresh();
      }
      
      protected function closeWindow(event:Event) : void
      {
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            if(this.m_selected)
            {
               this.onShareFeedClicked(event);
            }
         }
         CraftingStatsManager.recordFriendMarketStallPageLeaveStallClick();
         this.close();
      }
      
      override public function hide() : void
      {
         this.visible = false;
         this.onHide();
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            if(Global.worldManager.isVisiting())
            {
               InputManager.disableInput();
               Utilities.toggleInputAndChildren(Global.ui,false);
            }
            m_cursorId = UI.setCursor(null);
            this.centerPopup();
            Utilities.toggleInputAndChildren(this,true);
            m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,onResize);
         }
         else
         {
            m_showOnLoad = true;
         }
         SoundManager.playSound("dialogSpawn");
      }
      
      override protected function onHide() : void
      {
         if(m_shown == true)
         {
            if(Global.worldManager.isVisiting())
            {
               InputManager.enableInput();
               Utilities.toggleInputAndChildren(Global.ui,true);
            }
            m_shown = false;
            Utilities.toggleInputAndChildren(this,false);
            UI.removeCursor(m_cursorId);
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.removeEventListener(Event.RESIZE,onResize);
         }
         m_showOnLoad = false;
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_SingleOfferingFrame = null;
         this.m_DoubleOfferingFrame = null;
         this.m_MultipleOfferingFrame = null;
         this.m_BagsRemainingFrame = null;
         this.m_SiloFullFrame = null;
         this.m_PurchaseLimitHitFrame = null;
         this.m_SendThankYouFrame = null;
         this.m_instructionsFrame = null;
         this.m_marketStallOffering = null;
         this.m_craftedGoodOffering = null;
      }
      
      public function setButtonEnables(bool:Boolean) : void
      {
         this.m_SingleOfferingFrame.setButtonEnables(bool);
         this.m_DoubleOfferingFrame.setButtonEnables(bool);
         this.m_MultipleOfferingFrame.setButtonEnables(bool);
      }
   }
}

