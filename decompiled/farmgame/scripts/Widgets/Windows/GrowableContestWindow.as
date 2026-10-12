package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableContestTutorial;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.FeatureOptionsManager;
   import Managers.GrowableContestManager;
   import Transactions.TRefreshGifts;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.GrowableContest.GrowableContestBaseFrame;
   import Widgets.Frames.GrowableContest.GrowableContestMarketFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GrowableContestWindow extends FarmWindow
   {
      
      private static var s_window:GrowableContestWindow;
      
      public static const FRAME_ITEMS:String = "items";
      
      public static const FRAME_REQUESTS:String = "requests";
      
      public static const FRAME_MARKET:String = "market";
      
      public static const ACTION_OPEN_CONTEST:String = "openContest";
      
      private const FEATURE_DIALOG_PREFIX:String = "Window_";
      
      private const DEFAULT_WINDOW_ASSET:String = "assets/dialogs/FV_SocialPig.swf";
      
      private var m_initialFrame:String;
      
      private var m_isOnboarding:Boolean;
      
      private var m_loadingMc:ZwWidget;
      
      private var m_building:FeatureBuilding = null;
      
      private var m_requestsTab:FarmAnimatedTextButton;
      
      private var m_marketTab:FarmAnimatedTextButton;
      
      private var m_myItemTab:FarmAnimatedTextButton;
      
      private var m_numNewInvites:FarmAnimatedTextButton;
      
      private var m_prizedItemBaseFrame:GrowableContestBaseFrame;
      
      private var m_prizedItemMarketFrame:GrowableContestMarketFrame;
      
      private var m_capacityTextField:ZwTextField;
      
      private var m_feedTextField:ZwTextField;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_makeButton:FarmAnimatedTextButton;
      
      private var m_askButtonDisabled:Boolean;
      
      private var m_pigUpgradeAnnounce:ZwFrame;
      
      private var m_contest:GrowableContest;
      
      private var m_consumableCount:int;
      
      public function GrowableContestWindow(building:FeatureBuilding = null, contest:GrowableContest = null, initialFrame:String = null, isOnboarding:Boolean = false)
      {
         this.m_initialFrame = initialFrame;
         this.m_isOnboarding = isOnboarding;
         if(s_window != null)
         {
            hideWindow();
         }
         s_window = this;
         if(contest)
         {
            this.m_contest = contest;
         }
         else if(building)
         {
            this.m_contest = GrowableContestManager.instance.getContestForBuildingItemCode(building.getItem().code);
         }
         var windowAssetRelUrl:String = null;
         if(this.m_contest)
         {
            windowAssetRelUrl = this.m_contest.getAssetUrl(GrowableContest.ASSET_KEY_MAIN_WINDOW);
         }
         if(!windowAssetRelUrl)
         {
            windowAssetRelUrl = this.DEFAULT_WINDOW_ASSET;
         }
         super(windowAssetRelUrl,true,true);
      }
      
      public static function showWindow(building:FeatureBuilding = null, contest:GrowableContest = null, initialFrame:String = null, isOnboarding:Boolean = false) : void
      {
         if(s_window == null && GrowableContestManager.instance.isFeatureEnabled())
         {
            s_window = new GrowableContestWindow(building,contest,initialFrame,isOnboarding);
            UI.displayPopup(s_window,false);
         }
      }
      
      public static function showWindowForBuilding(building:FeatureBuilding = null, initialFrame:String = null, isOnboarding:Boolean = false) : void
      {
         showWindow(building,null,initialFrame,isOnboarding);
      }
      
      public static function showWindowForContest(contest:GrowableContest, initialFrame:String = null, isOnboarding:Boolean = false) : void
      {
         showWindow(null,contest,initialFrame,isOnboarding);
      }
      
      public static function hideWindow() : void
      {
         if(s_window != null)
         {
            s_window.close();
            s_window = null;
         }
      }
      
      override protected function onHide() : void
      {
         super.onHide();
         if(s_window == this)
         {
            s_window = null;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         if(this.m_contest)
         {
            this.m_loadingMc = addWidget(new ZwWidget(m_window.loading_mc)) as ZwWidget;
            addWidget(new ZwTextField(m_window.title_tf,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Title")));
            addWidget(new ZwTextField(m_window.description_tf,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Description")));
            if(Global.player.postInitFinished)
            {
               this.initWindow();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferInit);
            }
         }
      }
      
      override public function show() : void
      {
         super.show();
         this.statCount("impressions");
      }
      
      override public function close() : void
      {
         if(this.checkCachedConsumableCountGate() && this.m_consumableCount != this.m_contest.getConsumableCount())
         {
            TransactionManager.addTransaction(new TRefreshGifts(),true);
         }
         super.close();
         this.statCount("close");
      }
      
      private function deferInit(event:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferInit);
         this.initWindow();
      }
      
      private function initWindow() : void
      {
         var initialFrame:String = null;
         super.postLoadComplete();
         if(this.checkCachedConsumableCountGate())
         {
            this.m_consumableCount = this.m_contest.getConsumableCount();
         }
         if(this.m_initialFrame)
         {
            initialFrame = this.m_initialFrame;
            this.m_initialFrame = null;
         }
         else if(this.m_contest.getNumNewInvites() > 0)
         {
            initialFrame = FRAME_REQUESTS;
         }
         else if(this.m_contest.participatingList.length > 0)
         {
            initialFrame = FRAME_ITEMS;
         }
         else
         {
            initialFrame = FRAME_MARKET;
         }
         this.hideLoadingIndicator();
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick),true);
         this.m_myItemTab = addWidget(new FarmAnimatedTextButton(m_window.tab0_mc,this.m_contest.getZLocString("Dialogs","MyItemTab"),this.showMyItemFrame)) as FarmAnimatedTextButton;
         m_window.tab0_mc.notification_mc.visible = false;
         this.m_requestsTab = addWidget(new FarmAnimatedTextButton(m_window.tab1_mc,this.m_contest.getZLocString("Dialogs","RequestsTab"),this.showRequestsFrame)) as FarmAnimatedTextButton;
         this.m_numNewInvites = addWidget(new FarmAnimatedTextButton(m_window.tab1_mc.notification_mc,"")) as FarmAnimatedTextButton;
         this.refreshRequestsTab();
         this.m_marketTab = addWidget(new FarmAnimatedTextButton(m_window.tab2_mc,this.m_contest.getZLocString("Dialogs","MarketTab"),this.showMarketFrame)) as FarmAnimatedTextButton;
         m_window.tab2_mc.notification_mc.visible = false;
         this.m_prizedItemBaseFrame = addWidget(new GrowableContestBaseFrame(this,m_window.content_mc,this.m_contest,this.m_isOnboarding && initialFrame == FRAME_ITEMS)) as GrowableContestBaseFrame;
         this.m_prizedItemMarketFrame = addWidget(new GrowableContestMarketFrame(this,m_window.buyPigs_mc,this.m_contest,this.m_isOnboarding && initialFrame == FRAME_MARKET)) as GrowableContestMarketFrame;
         addWidget(new ZwFrame(m_window.capacity_mc));
         var capacityText:String = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Capacity",{
            "capacity":this.m_contest.getCapacity(),
            "active":this.m_contest.participatingList.length
         });
         this.m_capacityTextField = new ZwTextField(m_window.capacity_tf,capacityText);
         addWidget(this.m_capacityTextField);
         addWidget(new ZwFrame(m_window.consumeable_mc));
         var replace:Object = {
            "chow":this.getConsumableCount(),
            "chowCapacity":this.m_contest.getChowCapacity()
         };
         var chowText:String = ZLocUtils.t("Dialogs","Growable_ConsumableProgress",replace);
         this.m_feedTextField = new ZwTextField(m_window.chow_tf,chowText);
         addWidget(this.m_feedTextField);
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_window.ask_bt,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Ask"),this.handleAskButtonClicked)) as FarmAnimatedTextButton;
         if(!this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_GENERAL))
         {
            this.disableAskButton();
         }
         this.m_makeButton = addWidget(new FarmAnimatedTextButton(m_window.make_bt,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Make"),this.handleMakeButtonClicked)) as FarmAnimatedTextButton;
         this.m_pigUpgradeAnnounce = addWidget(new ZwFrame(m_window.upgraded_mc),false) as ZwFrame;
         switch(initialFrame)
         {
            case FRAME_ITEMS:
               this.showMyItemFrame();
               break;
            case FRAME_REQUESTS:
               this.showRequestsFrame();
               break;
            case FRAME_MARKET:
               this.showMarketFrame();
         }
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.contestDataChanged);
      }
      
      public function showLoadingIndicator() : void
      {
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         if(this.m_loadingMc)
         {
            this.m_loadingMc.visible = true;
         }
         this.enableInput = false;
         this.hideAllFrames();
      }
      
      public function hideLoadingIndicator() : void
      {
         if(m_closeButton)
         {
            m_closeButton.visible = true;
         }
         if(this.m_loadingMc)
         {
            this.m_loadingMc.visible = false;
         }
         this.enableInput = true;
      }
      
      override protected function release() : void
      {
         FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.contestDataChanged);
         this.m_loadingMc = null;
         this.m_requestsTab = null;
         this.m_marketTab = null;
         this.m_myItemTab = null;
         this.m_numNewInvites = null;
         this.m_prizedItemBaseFrame = null;
         this.m_prizedItemMarketFrame = null;
         this.m_capacityTextField = null;
         this.m_feedTextField = null;
         if(this.m_askButton)
         {
            this.m_askButton.detachTooltip();
         }
         this.m_askButton = null;
         this.m_makeButton = null;
         this.m_pigUpgradeAnnounce = null;
         super.release();
      }
      
      private function contestDataChanged(e:Event) : void
      {
         this.m_capacityTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Capacity",{
            "capacity":this.m_contest.getCapacity(),
            "active":this.m_contest.participatingList.length
         });
         this.refreshRequestsTab();
      }
      
      private function onWhatIsThisClick(e:Event) : void
      {
         var tutorial:GrowableContestTutorial = this.m_contest.getTutorial();
         if(tutorial != null)
         {
            tutorial.showWhatIsThis();
            this.statCount("what_is_this");
         }
      }
      
      public function showMyItemFrame(e:Event = null) : void
      {
         this.m_prizedItemBaseFrame.setSlotData(this.m_contest.getActiveObjects());
         this.setActiveFrame(this.m_prizedItemBaseFrame,this.m_myItemTab);
         this.statCount("participating_tab");
      }
      
      public function showRequestsFrame(e:Event = null) : void
      {
         this.m_prizedItemBaseFrame.setSlotData(this.m_contest.getPendingList());
         this.setActiveFrame(this.m_prizedItemBaseFrame,this.m_requestsTab);
         this.m_contest.setLastInviteViewTime();
         this.statCount("requests_tab");
      }
      
      public function showMarketFrame(e:Event = null) : void
      {
         this.setActiveFrame(this.m_prizedItemMarketFrame,this.m_marketTab);
         this.statCount("market_tab");
      }
      
      public function hideAllFrames() : void
      {
         this.setActiveFrame(null,null);
      }
      
      private function setActiveFrame(selectedFrame:FarmSlotContainerFrame, selectedTab:FarmAnimatedTextButton) : void
      {
         var frame:ZwFrame = null;
         var tab:FarmAnimatedTextButton = null;
         for each(frame in [this.m_prizedItemBaseFrame,this.m_prizedItemMarketFrame])
         {
            if(frame)
            {
               if(frame == selectedFrame)
               {
                  frame.visible = true;
               }
               else
               {
                  frame.visible = false;
               }
            }
         }
         for each(tab in [this.m_myItemTab,this.m_requestsTab,this.m_marketTab])
         {
            if(tab)
            {
               if(tab == selectedTab)
               {
                  tab.setToggleMode(ZwToggleMode.SINGLE_SELECT);
                  tab.setToggleState(ZwToggleState.SELECTED);
               }
               else
               {
                  tab.setToggleMode(ZwToggleMode.SINGLE_SELECT);
                  tab.setToggleState(ZwToggleState.DESELECTED);
               }
            }
         }
         this.refreshRequestsTab();
         visible = false;
         visible = true;
      }
      
      private function refreshRequestsTab() : void
      {
         var newInvites:int = this.m_contest.getNumNewInvites();
         if(newInvites > 0)
         {
            this.m_numNewInvites.visible = true;
            this.m_numNewInvites.element.count_tf.text = String(newInvites);
         }
         else
         {
            this.m_numNewInvites.visible = false;
         }
         if(this.m_contest.hasPendingRequests())
         {
            this.m_requestsTab.toggleClickableButton(true);
         }
         else
         {
            this.m_requestsTab.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_requestsTab.setToggleState(ZwToggleState.DESELECTED);
            this.m_requestsTab.toggleClickableButton(false,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "NoRequestsTooltip"));
         }
      }
      
      public function enterPlacementMode(itemName:String, storageKey:String, showDialog:Boolean = true) : void
      {
         var prompt:GenericXMLDialog = null;
         this.close();
         if(showDialog)
         {
            prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(itemName,"icon",false),100,100,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "PlaceDialog"),null,false,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "PlaceDialogButton"),function(event:Event):void
            {
               m_contest.placeEntry(storageKey);
            });
            UI.displayPopup(prompt,false);
         }
         else
         {
            this.m_contest.placeEntry(storageKey);
         }
      }
      
      private function handleAskButtonClicked(e:MouseEvent) : void
      {
         if(this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_GENERAL))
         {
            this.m_contest.postGeneralFeed(GrowableContest.FEED_TYPE_GENERAL,this.handleAskButtonCallback);
            this.toggleButton(this.m_askButton,false);
            this.statCount("ask_for_chow");
         }
      }
      
      private function handleAskButtonCallback(result:Boolean) : void
      {
         if(this.m_askButton)
         {
            this.disableAskButton();
         }
      }
      
      private function handleMakeButtonClicked(e:MouseEvent) : void
      {
         this.m_contest.openMakeRecipeWindow();
         this.close();
         this.statCount("make_chow");
      }
      
      override public function refreshWindow() : void
      {
         var replace:Object = {
            "chow":this.getConsumableCount(),
            "chowCapacity":this.m_contest.getChowCapacity()
         };
         var chowText:String = ZLocUtils.t("Dialogs","Growable_ConsumableProgress",replace);
         if(m_window)
         {
            this.m_feedTextField = new ZwTextField(m_window.chow_tf,chowText);
            if(this.m_prizedItemBaseFrame != null)
            {
               this.m_prizedItemBaseFrame.refreshSlotButtons();
            }
         }
         super.refreshWindow();
      }
      
      private function disableAskButton() : void
      {
         var hoursRemaining:int = 0;
         if(!this.m_askButtonDisabled)
         {
            this.m_askButtonDisabled = true;
            this.m_askButton.enabled = true;
            this.m_askButton.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_askButton.setToggleState(ZwToggleState.SELECTED);
            this.m_askButton.applyGrayOut = true;
            this.m_askButton.element.buttonMode = false;
            hoursRemaining = Math.ceil(this.m_contest.getTimeUntilPostFeedEnabled(GrowableContest.FEED_TYPE_GENERAL) / FarmGameUtil.NUM_SECS_IN_HOUR);
            this.m_askButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","Growable_ConsumableAskWithTimer",{"timeLeft":hoursRemaining})));
         }
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("main_dialog",phylum,zclass,family,genus,value);
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      public function checkCachedConsumableCountGate() : Boolean
      {
         return Global.flashHotParams["GROWABLE_CONTEST_CONSUMABLE_GETGIFTS_FIX"];
      }
      
      public function decrementConsumableCount(amount:int = 1) : void
      {
         if(this.checkCachedConsumableCountGate() && amount > 0)
         {
            this.m_consumableCount -= amount;
         }
      }
      
      public function getConsumableCount() : int
      {
         var value:int = 0;
         if(this.checkCachedConsumableCountGate())
         {
            value = this.m_consumableCount;
         }
         else
         {
            value = this.m_contest.getConsumableCount();
         }
         return value;
      }
   }
}

