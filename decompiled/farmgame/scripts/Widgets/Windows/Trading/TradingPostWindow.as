package Widgets.Windows.Trading
{
   import Classes.Trading.OrderTypes;
   import Classes.Trading.TradingPostConstants;
   import Classes.Trading.TradingPostManager;
   import Classes.Trading.UserTradingOfferings;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Trading.TradingPostOrderSlotFrame;
   import Widgets.Frames.Trading.TradingPostUserSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TradingPostWindow extends FarmWindow
   {
      
      public static const TAB_ORDERS:String = "tab_orders";
      
      private var m_friendOfferings:Array = null;
      
      private var m_myOffering:UserTradingOfferings = null;
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_sellingUsersFrame:TradingPostUserSlotFrame = null;
      
      protected var m_ordersFrame:TradingPostOrderSlotFrame = null;
      
      private var m_sellingUsersFrameToggle:ZwVisibilityToggle = null;
      
      private var m_ordersFrameToggle:ZwVisibilityToggle = null;
      
      private var m_defaultTab:String = null;
      
      private var m_dataLoaded:Boolean = false;
      
      private var m_uiBuilt:Boolean = false;
      
      private var m_loadingUI:GenericPopup = null;
      
      public function TradingPostWindow(friendOfferings:Array, myOffering:UserTradingOfferings)
      {
         this.m_friendOfferings = friendOfferings;
         if(this.m_friendOfferings != null)
         {
            this.m_friendOfferings.sortOn("hasClaimableOrders",[Array.DESCENDING]);
         }
         this.m_myOffering = myOffering;
         if(this.m_myOffering == null)
         {
            this.m_myOffering = new UserTradingOfferings(Global.player.uid,OrderTypes.CROP_ORDER);
         }
         super("assets/dialogs/FV_TradePostUI.swf");
         TradingPostManager.getInstance().reloadTradingData(this.onTradingDataLoaded);
      }
      
      public function onTradingDataLoaded() : void
      {
         this.m_dataLoaded = true;
         this.m_friendOfferings = TradingPostManager.getInstance().marketView.getAllFriendOfferingsSafe();
         this.m_myOffering = TradingPostManager.getInstance().marketView.getMyUserOffering();
         if(this.m_friendOfferings != null)
         {
            this.m_friendOfferings = this.sortOrdersByAvailable(this.m_friendOfferings);
         }
         if(this.m_myOffering == null)
         {
            this.m_myOffering = new UserTradingOfferings(Global.player.uid,OrderTypes.CROP_ORDER);
         }
         if(!this.m_uiBuilt)
         {
            this.buildUI();
         }
         if(this.m_loadingUI != null)
         {
            this.m_loadingUI.close();
         }
      }
      
      private function sortOrdersByAvailable(tradingUsers:Array) : Array
      {
         var offering:UserTradingOfferings = null;
         var result:Array = null;
         var available:Array = new Array();
         var notAvailable:Array = new Array();
         for each(offering in tradingUsers)
         {
            if(offering.ordersFromFriends.length > 0 && !offering.hasClaimableOrders)
            {
               notAvailable.push(offering);
            }
            else
            {
               available.push(offering);
            }
         }
         available.sortOn("mostRecentGoodTime",[Array.DESCENDING]);
         available.sortOn("hasClaimableOrders",[Array.DESCENDING]);
         return available.concat(notAvailable);
      }
      
      override protected function postLoadComplete() : void
      {
         if(this.m_dataLoaded)
         {
            this.buildUI();
         }
         else
         {
            this.m_loadingUI = new GenericPopup(ZLocUtils.t("Dialogs","tradingPost_Loading"));
            UI.displayPopup(this.m_loadingUI,false);
         }
         this.m_window.x += 70;
         this.m_window.y += 100;
      }
      
      private function buildUI() : void
      {
         var sellingUsersButton:FarmAnimatedTextButton = null;
         var ordersButton:FarmAnimatedTextButton = null;
         var ordersFromFriends:Array = null;
         if(!this.m_uiBuilt && m_window != null && m_window.title_tf != null)
         {
            this.m_uiBuilt = true;
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs","tradingpost_UI_title")));
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkCallback));
            sellingUsersButton = new FarmAnimatedTextButton(m_window.selectorTab_bt,ZLocUtils.t("Dialogs","tradingpost_UI_tab_Selling"),null);
            addWidget(sellingUsersButton);
            ordersButton = new FarmAnimatedTextButton(m_window.selector_bt,ZLocUtils.t("Dialogs","tradingpost_UI_tab_Orders"),null);
            addWidget(ordersButton);
            this.m_toggleManager = new ZwToggleManager();
            this.m_sellingUsersFrame = new TradingPostUserSlotFrame(m_window.inventoryFrame_mc,this.m_friendOfferings,this);
            addWidget(this.m_sellingUsersFrame,true);
            ordersFromFriends = new Array();
            if(this.m_myOffering != null && this.m_myOffering.hasOwnProperty("ordersFromFriends"))
            {
               ordersFromFriends = this.m_myOffering.ordersFromFriendsSafe;
               ordersFromFriends.sortOn("isFilledOrder",[Array.DESCENDING]);
            }
            this.m_ordersFrame = new TradingPostOrderSlotFrame(m_window.SellingFrame_mc,ordersFromFriends,this);
            addWidget(this.m_ordersFrame,false);
            this.m_sellingUsersFrameToggle = new ZwVisibilityToggle(sellingUsersButton,this.m_sellingUsersFrame);
            this.m_toggleManager.addToggle(this.m_sellingUsersFrameToggle,true);
            this.m_ordersFrameToggle = new ZwVisibilityToggle(ordersButton,this.m_ordersFrame);
            this.m_toggleManager.addToggle(this.m_ordersFrameToggle);
            this.switchTabs();
            if(!Global.player.getSeenFlag(TradingPostConstants.SEEN_TRADING_POST_HELP))
            {
               this.howDoesThisWorkCallback(null);
               Global.player.setSeenFlag(TradingPostConstants.SEEN_TRADING_POST_HELP);
            }
         }
      }
      
      public function switchTabs() : void
      {
         if(this.m_defaultTab != null)
         {
            switch(this.m_defaultTab)
            {
               case TAB_ORDERS:
                  this.m_toggleManager.performToggle(this.m_ordersFrameToggle);
            }
         }
      }
      
      public function setDefaultTab(tabName:String) : void
      {
         this.m_defaultTab = tabName;
      }
      
      protected function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         TutorialUI.displayTradingPostTutorialWindow(false,null);
      }
      
      override protected function onClose(event:Event) : void
      {
         var tradingPost:FarmItem = null;
         if(!Global.player.getSeenSessionFlag(TradingPostConstants.SEEN_TRADING_NO_ORDER_PROMPT))
         {
            tradingPost = Global.farmGameSettingsManager.getFarmItemByName("tradingpost");
            if(Global.player.inExperimentFeedCheckBoxV2())
            {
               UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","tradingpost_UI_close_ui"),GenericPopup.TYPE_SHARECHECKBOX,this.onShare,tradingPost.icon,false,false,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET_CHECKBOX,null,false,false,ZLocUtils.t("Dialogs","tradingpost_UI_no_orders_checkbox")),false);
            }
            else
            {
               UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","tradingpost_UI_close_ui"),GenericPopup.TYPE_SHARECANCEL,this.onShare,tradingPost.icon),false);
            }
            Global.player.setSeenSessionFlag(TradingPostConstants.SEEN_TRADING_NO_ORDER_PROMPT);
         }
         super.onClose(event);
         TradingPostManager.getInstance().clearTradingPostWindow();
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var feedImage:String = null;
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            feedImage = Global.getAssetURL("assets/newsfeed/feed_tradingpostbountiful.png");
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}?ref=trading_post_close_ui",
                  "src":feedImage
               }],
               "user":Global.player.firstName
            };
            messageType = "tradingpost_CloseUI";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
      }
      
      override protected function release() : void
      {
         var myOffering:UserTradingOfferings = TradingPostManager.getInstance().marketView.getMyUserOffering();
         if(myOffering != null)
         {
            myOffering.flushOrdersToRemove();
         }
         this.m_toggleManager = null;
         this.m_sellingUsersFrame = null;
         this.m_ordersFrame = null;
         this.m_sellingUsersFrameToggle = null;
         this.m_ordersFrameToggle = null;
         super.release();
      }
   }
}

