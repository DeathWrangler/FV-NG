package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.ItemMembershipManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Managers.ZwWidgetManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.ItemMembershipBonusSlot;
   import Widgets.Slots.ItemMembershipOptionSlot;
   import Widgets.Slots.ItemMembershipRedeemSlot;
   import Widgets.Slots.TabSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class ItemMembershipWindow extends FarmWindowWithBackground
   {
      
      private static const UI_DUP_KEY:String = "Widgets.Windows.ItemMembershipWindow";
      
      private static const REDEEM_CREDIT_ICON:String = "assets/dialogs/4d_elements/SubscriptionsClub/token_tree_icon_sm.png";
      
      private static const REDEEM_CREDIT_ICON_WIDTH:int = 50;
      
      private static const REDEEM_CREDIT_ICON_HEIGHT:int = 38;
      
      private static const MEMBER_CREDIT_ICON:String = "assets/dialogs/4d_elements/SubscriptionsClub/token_tree_icon_med.png";
      
      private static const MEMBER_CREDIT_ICON_WIDTH:int = 80;
      
      private static const MEMBER_CREDIT_ICON_HEIGHT:int = 60;
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private static const NUM_STANDARD_SUBSCRIPTION_OPTIONS:int = 4;
      
      private var m_featureName:String = "";
      
      private var m_tabFrame:GenericSlotContainerFrame;
      
      private var m_nonMemberMC:MovieClip;
      
      private var m_memberMC:MovieClip;
      
      private var m_redeemMC:MovieClip;
      
      private var m_currentMC:MovieClip;
      
      private var m_nonMemberWidgetManager:ZwWidgetManager = new ZwWidgetManager();
      
      private var m_memberWidgetManager:ZwWidgetManager = new ZwWidgetManager();
      
      private var m_redeemWidgetManager:ZwWidgetManager = new ZwWidgetManager();
      
      private var m_nonMemberFrame:GenericSlotContainerFrame;
      
      private var m_memberFrame:GenericSlotContainerFrame;
      
      private var m_redeemFrame:GenericSlotContainerFrame;
      
      private var m_nonMemberCopy:ZwTextField;
      
      private var m_nonMemberHeadline:ZwTextField;
      
      private var m_memberCopy:ZwTextField;
      
      private var m_memberNumCredits:ZwTextField;
      
      private var m_memberRedeemButton:FarmAnimatedTextButton;
      
      private var m_memberBonusText:ZwTextField;
      
      private var m_memberRenewalText:ZwTextField;
      
      private var m_memberUnsubscribeButton:FarmAnimatedTextButton;
      
      private var m_redeemCopy:ZwTextField;
      
      private var m_redeemCreditIcon:FarmIcon;
      
      private var m_redeemNumCredits:ZwTextField;
      
      private var m_redeemableItems:Array;
      
      private var m_searchTextField:ZwTextField;
      
      private var m_defaultSearchString:String = "search";
      
      private var m_lastRedeemViewFeature:String;
      
      private var m_currentTutorialScene:int = 1;
      
      private var m_tutorialMC:MovieClip;
      
      private var m_currentTab:TabSlot;
      
      public function ItemMembershipWindow(featureParams:Object)
      {
         if(Boolean(featureParams) && "featureName" in featureParams)
         {
            this.m_featureName = featureParams["featureName"];
         }
         super(ItemMembershipManager.MAIN_UI_ASSET_PATH,ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_MAIN_WINDOW_BACKGROUND_IMAGE));
      }
      
      private static function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private static function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
      
      public static function toggleRedeemButton(button:FarmAnimatedTextButton, featureName:String) : void
      {
         var numCredits:Number = ItemMembershipManager.getFeatureOptionWithKeys(featureName,ItemMembershipManager.NUM_CREDITS);
         button.enabled = numCredits is int && numCredits > 0;
      }
      
      public static function showStatic(featureName:String = null) : void
      {
         var featureNames:Array = null;
         var numFeatures:int = 0;
         if(featureName == null)
         {
            featureNames = ItemMembershipManager.getFeatureNames();
            if(featureNames)
            {
               numFeatures = int(featureNames.length);
               if(numFeatures > 0)
               {
                  featureName = featureNames[numFeatures - 1];
               }
            }
         }
         if(featureName)
         {
            UI.displayPopup(new ItemMembershipWindow({"featureName":featureName}),true,UI_DUP_KEY,true);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var tabSlot:TabSlot = null;
         super.postLoadComplete();
         if(m_window is MovieClip)
         {
            if("title_tf" in m_window)
            {
               addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_club_memberships")),true);
            }
            if("tab_mc" in m_window)
            {
               this.m_tabFrame = new GenericSlotContainerFrame(m_window["tab_mc"],TabSlot,this.getTabSlotData(),this);
               this.addWidget(this.m_tabFrame);
               this.m_tabFrame.centerSlots();
               for each(tabSlot in this.m_tabFrame.slots)
               {
                  if(tabSlot.featureNameKey == this.m_featureName)
                  {
                     this.onTabClicked(tabSlot);
                     tabSlot.select();
                     break;
                  }
               }
            }
            if(m_window["whatisthis_mc"])
            {
               addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisButtonClicked),true);
            }
            if(m_window["tutorial_mc"])
            {
               this.m_tutorialMC = m_window.tutorial_mc;
               if(this.m_tutorialMC["okay_bt"])
               {
                  addWidget(new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,"Okay",this.onTutorialOkayButtonClicked),true);
               }
            }
            this.initNonMemberView();
            this.initMemberView();
            this.initRedeemView();
            this.refreshWindow();
            if(!Global.player.getSeenFlag(UI_DUP_KEY))
            {
               Global.player.setSeenFlag(UI_DUP_KEY);
               this.onWhatIsThisButtonClicked();
            }
            StatsManager.count(this.m_featureName,StatsTrackingConstants.MAIN_UI,StatsTrackingConstants.IMPRESSIONS);
         }
      }
      
      private function getTabSlotData() : Array
      {
         var slotDatum:Object = null;
         var slotData:Array = [];
         var featureNames:Array = ItemMembershipManager.getFeatureNames();
         var numFeatureNames:int = int(featureNames.length);
         for(var i:int = 0; i < numFeatureNames; i++)
         {
            slotDatum = {};
            slotDatum.featureName = featureNames[i];
            slotDatum.callback = this.onTabClicked;
            slotData.push(slotDatum);
         }
         return slotData;
      }
      
      private function onWhatIsThisButtonClicked(event:Event = null) : void
      {
         if(this.m_tutorialMC)
         {
            this.m_tabFrame.visible = false;
            this.m_tutorialMC.visible = true;
            this.m_tutorialMC.gotoAndStop(1);
            if(this.m_tutorialMC["animation_mc"])
            {
               this.m_tutorialMC.animation_mc.gotoAndPlay(1);
            }
         }
         StatsManager.count(this.m_featureName,StatsTrackingConstants.FTUE,StatsTrackingConstants.STATS_CLICK);
      }
      
      private function onTutorialOkayButtonClicked(event:Event) : void
      {
         if(this.m_currentTutorialScene < NUM_TUTORIAL_SCENES)
         {
            ++this.m_currentTutorialScene;
            this.m_tutorialMC.play();
         }
         else
         {
            StatsManager.count(this.m_featureName,StatsTrackingConstants.FTUE,StatsTrackingConstants.FINISHED);
            this.m_tabFrame.visible = true;
            this.m_tutorialMC.visible = false;
            this.m_currentTutorialScene = 1;
         }
      }
      
      override public function refreshWindow() : void
      {
         var backgroundImage:String = ItemMembershipManager.getConstantsStringWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_MAIN_WINDOW_BACKGROUND_IMAGE);
         if(backgroundImage)
         {
            m_backgroundImage = backgroundImage;
         }
         super.refreshWindow();
         if(ItemMembershipManager.isSubscribed(this.m_featureName))
         {
            if(this.m_currentMC == this.m_memberMC)
            {
               this.showView(this.m_memberMC,this.populateMemberView);
            }
            else
            {
               this.showView(this.m_redeemMC,this.populateRedeemView);
            }
         }
         else
         {
            this.showView(this.m_nonMemberMC,this.populateNonMemberView);
         }
      }
      
      public function onTabClicked(tab:TabSlot) : *
      {
         if(this.m_currentTab)
         {
            this.m_currentTab.deselect();
         }
         this.m_currentTab = tab;
         var featureName:String = tab.featureNameKey;
         if(this.m_featureName != featureName)
         {
            this.m_featureName = featureName;
            this.refreshWindow();
            StatsManager.count(this.m_featureName,StatsTrackingConstants.MAIN_UI,StatsTrackingConstants.CLICK_TAB);
         }
      }
      
      private function showView(view:MovieClip, populateFunction:Function) : void
      {
         if(this.m_currentMC is MovieClip)
         {
            this.m_currentMC.visible = false;
         }
         this.m_currentMC = view;
         populateFunction();
         if(this.m_currentMC is MovieClip)
         {
            this.m_currentMC.visible = true;
         }
      }
      
      private function initNonMemberView() : void
      {
         if(m_window["subscription_mc"])
         {
            this.m_nonMemberMC = m_window.subscription_mc;
            if(this.m_nonMemberMC.hasOwnProperty("slots_mc"))
            {
               this.m_nonMemberFrame = new GenericSlotContainerFrame(this.m_nonMemberMC["slots_mc"],ItemMembershipOptionSlot,[],this);
               this.m_nonMemberWidgetManager.addWidget(this.m_nonMemberFrame,true);
            }
            if(this.m_nonMemberMC.hasOwnProperty("copy_tf"))
            {
               this.m_nonMemberCopy = new ZwTextField(this.m_nonMemberMC["copy_tf"]);
               this.m_nonMemberWidgetManager.addWidget(this.m_nonMemberCopy,true);
            }
            if(this.m_nonMemberMC["headline_tf"])
            {
               this.m_nonMemberHeadline = new ZwTextField(this.m_nonMemberMC.headline_tf);
               this.m_nonMemberWidgetManager.addWidget(this.m_nonMemberHeadline,true);
            }
         }
      }
      
      private function initMemberView() : void
      {
         var creditIcon:FarmIcon = null;
         if(m_window.hasOwnProperty("memberStatus_mc"))
         {
            this.m_memberMC = m_window["memberStatus_mc"];
            if(ObjectUtil.pathExists(this.m_memberMC,"monthsActive_mc","slots_mc"))
            {
               this.m_memberFrame = new GenericSlotContainerFrame(this.m_memberMC["monthsActive_mc"]["slots_mc"],ItemMembershipBonusSlot,[],this);
               this.m_memberWidgetManager.addWidget(this.m_memberFrame,true);
            }
            if(this.m_memberMC.hasOwnProperty("copy_tf"))
            {
               this.m_memberCopy = new ZwTextField(this.m_memberMC["copy_tf"]);
               this.m_memberWidgetManager.addWidget(this.m_memberCopy,true);
            }
            if(ObjectUtil.pathExists(this.m_memberMC,"token_mc","icon_mc"))
            {
               creditIcon = new FarmIcon(this.m_memberMC["token_mc"]["icon_mc"],MEMBER_CREDIT_ICON);
               creditIcon.setIconSize(MEMBER_CREDIT_ICON_WIDTH,MEMBER_CREDIT_ICON_HEIGHT);
               this.m_memberWidgetManager.addWidget(creditIcon,true);
            }
            if(ObjectUtil.pathExists(this.m_memberMC,"token_mc","count_tf"))
            {
               this.m_memberNumCredits = new ZwTextField(this.m_memberMC["token_mc"]["count_tf"]);
               this.m_memberWidgetManager.addWidget(this.m_memberNumCredits,true);
            }
            if(this.m_memberMC.hasOwnProperty("redeem_bt"))
            {
               this.m_memberRedeemButton = new FarmAnimatedTextButton(this.m_memberMC["redeem_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_redeem"),this.onRedeemButtonClicked);
               this.m_memberWidgetManager.addWidget(this.m_memberRedeemButton,true);
            }
            if(ObjectUtil.pathExists(this.m_memberMC,"monthsActive_mc","value_tf"))
            {
               this.m_memberBonusText = new ZwTextField(this.m_memberMC["monthsActive_mc"]["value_tf"]);
               this.m_memberWidgetManager.addWidget(this.m_memberBonusText,true);
            }
            if(this.m_memberMC.hasOwnProperty("expire_tf"))
            {
               this.m_memberRenewalText = new ZwTextField(this.m_memberMC["expire_tf"]);
               this.m_memberWidgetManager.addWidget(this.m_memberRenewalText,true);
            }
            if(this.m_memberMC.hasOwnProperty("cancel_bt"))
            {
               this.m_memberUnsubscribeButton = new FarmAnimatedTextButton(this.m_memberMC["cancel_bt"],ZLocUtils.t("Dialogs","unsubscribe"),this.onUnsubscribeButtonClicked);
               this.m_memberWidgetManager.addWidget(this.m_memberUnsubscribeButton,true);
            }
         }
      }
      
      private function initRedeemView() : void
      {
         if(m_window.hasOwnProperty("redeemToken_mc"))
         {
            this.m_redeemMC = m_window["redeemToken_mc"];
            if(this.m_redeemMC.hasOwnProperty("slots_mc"))
            {
               this.m_redeemFrame = new GenericSlotContainerFrame(this.m_redeemMC["slots_mc"],ItemMembershipRedeemSlot,[],this);
               this.m_redeemWidgetManager.addWidget(this.m_redeemFrame,true);
            }
            if(this.m_redeemMC.hasOwnProperty("copy_tf"))
            {
               this.m_redeemCopy = new ZwTextField(this.m_redeemMC["copy_tf"]);
               this.m_redeemWidgetManager.addWidget(this.m_redeemCopy,true);
            }
            if(ObjectUtil.pathExists(this.m_redeemMC,"token_mc","icon_mc"))
            {
               this.m_redeemCreditIcon = new FarmIcon(this.m_redeemMC["token_mc"]["icon_mc"],REDEEM_CREDIT_ICON);
               this.m_redeemCreditIcon.setIconSize(REDEEM_CREDIT_ICON_WIDTH,REDEEM_CREDIT_ICON_HEIGHT);
               this.m_redeemWidgetManager.addWidget(this.m_redeemCreditIcon,true);
            }
            if(ObjectUtil.pathExists(this.m_redeemMC,"token_mc","count_tf"))
            {
               this.m_redeemNumCredits = new ZwTextField(this.m_redeemMC["token_mc"]["count_tf"]);
               this.m_redeemWidgetManager.addWidget(this.m_redeemNumCredits,true);
            }
            if("memberStatus_bt" in this.m_redeemMC)
            {
               this.m_redeemWidgetManager.addWidget(new FarmAnimatedTextButton(this.m_redeemMC["memberStatus_bt"],ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_member_status"),this.onMemberStatusButtonClicked),true);
            }
            if(ObjectUtil.pathExists(this.m_redeemMC,"searchBar_mc","searchField_tf"))
            {
               this.m_redeemWidgetManager.addWidget(new ZwWidget(this.m_redeemMC["searchBar_mc"]),true);
               this.m_searchTextField = new ZwTextField(this.m_redeemMC["searchBar_mc"]["searchField_tf"],this.m_defaultSearchString);
               this.m_searchTextField.restrict("0-9 a-zA-Z\\-\'");
               this.m_redeemMC.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,disableShortcut);
               this.m_redeemMC.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,enableShortcut);
               this.m_redeemMC.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchBarClick);
               this.m_redeemMC.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
               this.m_redeemWidgetManager.addWidget(this.m_searchTextField,true);
            }
         }
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         var slotDataObject:Object = null;
         var item:FarmItem = null;
         var searchedRedeemableItems:Array = [];
         if(this.m_searchTextField.text == "")
         {
            searchedRedeemableItems = this.m_redeemableItems;
         }
         else
         {
            this.m_searchTextField.text.toLowerCase();
            for each(slotDataObject in this.m_redeemableItems)
            {
               if("item" in slotDataObject)
               {
                  item = slotDataObject["item"];
                  if(item is FarmItem && item.friendlyTitle.toLowerCase().search(this.m_searchTextField.text.toLowerCase()) != -1)
                  {
                     searchedRedeemableItems.push(slotDataObject);
                  }
               }
            }
         }
         if(this.m_redeemFrame is GenericSlotContainerFrame)
         {
            this.m_redeemFrame.setData(searchedRedeemableItems);
         }
      }
      
      private function onSearchBarClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchTextField.text == this.m_defaultSearchString)
         {
            this.m_searchTextField.text = "";
         }
      }
      
      private function populateNonMemberView() : void
      {
         var numCreditsPerMonth:int = 0;
         var itemNamePlural:String = null;
         var zLocObj:Object = null;
         var slotData:Array = null;
         if(this.m_nonMemberCopy)
         {
            numCreditsPerMonth = ItemMembershipManager.getConstantsIntWithKey(this.m_featureName,ItemMembershipManager.CONSTANTS_KEY_NUM_CREDITS_PER_MONTH);
            if(numCreditsPerMonth > 0)
            {
               itemNamePlural = ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL);
               zLocObj = {
                  "numCreditsPerMonth":numCreditsPerMonth,
                  "itemNamePlural":itemNamePlural
               };
               this.m_nonMemberCopy.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_non_member_copy",zLocObj);
               delete zLocObj.itemNamePlural;
               zLocObj.creditName = ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_CREDITS_NAME);
               zLocObj.itemNameSingular = ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR);
               if(this.m_nonMemberHeadline)
               {
                  this.m_nonMemberHeadline.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_non_member_headline",zLocObj);
               }
            }
         }
         if(this.m_nonMemberFrame is GenericSlotContainerFrame)
         {
            slotData = ItemMembershipManager.getMembershipOptionSlotData(this.m_featureName);
            this.m_nonMemberFrame.setData(slotData);
            this.m_nonMemberFrame.resetSlotPositions();
            if(slotData.length != NUM_STANDARD_SUBSCRIPTION_OPTIONS)
            {
               this.m_nonMemberFrame.centerSlots();
            }
         }
         this.count(StatsTrackingConstants.NON_MEMBER_VIEW);
      }
      
      private function populateMemberView() : void
      {
         var numMonthsSubscribed:int = 0;
         var monthString:String = null;
         var zLocObj:Object = null;
         var numCredits:int = 0;
         if(this.m_memberCopy is ZwTextField)
         {
            numMonthsSubscribed = ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.NUM_MONTHS_SUBSCRIBED);
            if(!isNaN(numMonthsSubscribed))
            {
               monthString = numMonthsSubscribed > 1 ? "months" : "month";
               zLocObj = {
                  "clubName":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_CLUB_NAME),
                  "numMonthsSubscribed":numMonthsSubscribed,
                  "monthKey":monthString
               };
               this.m_memberCopy.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_member_copy",zLocObj);
               StatsManager.count(this.m_featureName,StatsTrackingConstants.MAIN_UI,StatsTrackingConstants.LEVEL,numMonthsSubscribed.toString());
            }
         }
         if(this.m_memberNumCredits is ZwTextField)
         {
            numCredits = ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.NUM_CREDITS);
            if(!isNaN(numCredits))
            {
               this.m_memberNumCredits.text = "x" + numCredits;
            }
         }
         if(this.m_memberRedeemButton is FarmAnimatedTextButton)
         {
            toggleRedeemButton(this.m_memberRedeemButton,this.m_featureName);
         }
         if(this.m_memberBonusText is ZwTextField)
         {
            this.m_memberBonusText.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_bonus_text",{"itemPlural":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL)});
         }
         if(this.m_memberRenewalText is ZwTextField)
         {
            this.m_memberRenewalText.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_renewal");
         }
         if(this.m_memberUnsubscribeButton is FarmAnimatedTextButton)
         {
            this.m_memberUnsubscribeButton.enabled = ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.SHOULD_RENEW) === true;
         }
         if(this.m_memberFrame is GenericSlotContainerFrame)
         {
            this.m_memberFrame.setData(ItemMembershipManager.getBonusSlotData(this.m_featureName));
         }
         this.count(StatsTrackingConstants.MEMBER_VIEW);
      }
      
      private function count(phylum:String, statClass:String = "") : void
      {
         StatsManager.count(this.m_featureName,StatsTrackingConstants.MAIN_UI,phylum,statClass);
      }
      
      public function populateRedeemView(shouldRepopulateSlots:Boolean = false) : void
      {
         var numCredits:int = 0;
         if(this.m_redeemCopy)
         {
            this.m_redeemCopy.text = ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_redeem_window_copy",{"itemNamePlural":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_PLURAL)});
         }
         if(this.m_redeemNumCredits is ZwTextField)
         {
            numCredits = ItemMembershipManager.getFeatureOptionWithKeys(this.m_featureName,ItemMembershipManager.NUM_CREDITS);
            if(!isNaN(numCredits))
            {
               this.m_redeemNumCredits.text = "x" + numCredits;
            }
         }
         if(this.m_redeemCreditIcon)
         {
            if(this.m_redeemCreditIcon.tooltip)
            {
               this.m_redeemCreditIcon.detachTooltip();
            }
            this.m_redeemCreditIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",ItemMembershipManager.FEATURE_TYPE + "_redeem_token_tooltip",{"itemNameSingular":ZLocUtils.t("Dialogs",this.m_featureName + ItemMembershipManager.ZLOC_KEY_ITEM_SINGULAR)})));
         }
         if(this.m_redeemFrame is GenericSlotContainerFrame && (this.m_lastRedeemViewFeature != this.m_featureName || (this.m_searchTextField.text != "" && this.m_searchTextField.text != this.m_defaultSearchString || shouldRepopulateSlots)))
         {
            this.m_lastRedeemViewFeature = this.m_featureName;
            this.m_redeemableItems = ItemMembershipManager.getItemsToRedeem(this.m_featureName);
            this.m_redeemFrame.setData(this.m_redeemableItems);
         }
         if(this.m_searchTextField is ZwTextField)
         {
            this.m_searchTextField.text = this.m_defaultSearchString;
         }
         this.count(StatsTrackingConstants.REDEEM_VIEW);
      }
      
      private function onRedeemButtonClicked(event:Event) : void
      {
         this.count(StatsTrackingConstants.MEMBER_VIEW,StatsTrackingConstants.CLICK_REDEEM);
         this.showView(this.m_redeemMC,this.populateRedeemView);
      }
      
      private function onMemberStatusButtonClicked(event:Event) : void
      {
         StatsManager.count(this.m_featureName,StatsTrackingConstants.REDEEM_VIEW,StatsTrackingConstants.MEMBER_STATUS_BUTTON,StatsTrackingConstants.STATS_CLICK);
         this.showView(this.m_memberMC,this.populateMemberView);
      }
      
      private function onUnsubscribeButtonClicked(event:Event) : void
      {
         ItemMembershipUnsubscribeConfirmationWindow.showStatic(this.m_featureName);
         this.close();
      }
      
      override public function close() : void
      {
         this.count(StatsTrackingConstants.CLOSE);
         super.close();
      }
   }
}

