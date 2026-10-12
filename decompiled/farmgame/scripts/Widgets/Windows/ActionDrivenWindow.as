package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureMessagingDefinition;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.ActionDrivenManager;
   import Managers.BaseFeatureManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FeatureMessagingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   
   public class ActionDrivenWindow extends PrereqDrivenWindow
   {
      
      private static const UPDATE_LOOP_DELAY:Number = 50;
      
      public static const SERVICE_CLASS:String = "ActionDrivenService";
      
      public static const FRIEND_HELP_ASK_KEY:String = "AskFriendHelp";
      
      public static const HELPER_COUNT:int = 1;
      
      public static const ACTIONCOUNT_METER_HOVER_TEXT:int = 0;
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private static const MAX_TUTORIAL_STATE:int = 4;
      
      private static const GLOBAL_METER_COUNT_MAX:int = 7;
      
      private static var s_map:Object = {};
      
      private var m_uiDupKeyPrefix:String;
      
      private var m_scoreTF:ZwTextField;
      
      private var m_meterScoreTF:ZwTextField;
      
      private var m_tooltipMC:MovieClip;
      
      private var m_harvestButton:FarmAnimatedTextButton;
      
      private var m_timerTF:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_craftButton:FarmAnimatedTextButton;
      
      private var m_tutorialClip:MovieClip;
      
      private var m_currentTutorialState:int = 1;
      
      private var m_updateTimer:Timer = null;
      
      private var m_harvestThrottleSeconds:int;
      
      private var m_purchasePrice:int;
      
      private var m_manager:ActionDrivenManager;
      
      private var m_cachedActionCount:int;
      
      private var m_disclaimerLink:ZwButton;
      
      private var m_helpCounterArray:Array;
      
      private var m_helperButton:FarmAnimatedTextButton;
      
      private var m_helpCounter:ZwWidget;
      
      private var m_globalMeter:ZwWidget = null;
      
      private var m_globalMeterCounterArray:Array;
      
      private var m_collectReady:MovieClip;
      
      private var m_collectButton:FarmAnimatedTextButton;
      
      public function ActionDrivenWindow(featureParams:Object)
      {
         if(Boolean(featureParams) && Boolean(featureParams.featureName))
         {
            super(featureParams.featureName);
            this.m_manager = m_baseFeatureManager as ActionDrivenManager;
            this.m_uiDupKeyPrefix = getQualifiedClassName(this);
            this.m_harvestThrottleSeconds = this.m_manager.getConstantsIntWithKey("harvestThrottleSeconds");
            this.m_purchasePrice = this.m_manager.getConstantsIntWithKey("purchasePrice");
            this.m_cachedActionCount = this.m_manager.getActionCount();
            s_map[m_featureName] = this;
            return;
         }
         throw new Error("Missing feature name");
      }
      
      public static function uiDupKey(featureName:String) : String
      {
         return getQualifiedClassName(ActionDrivenWindow) + featureName;
      }
      
      public static function showStatic(featureName:String) : void
      {
         UI.displayPopup(new ActionDrivenWindow({"featureName":featureName}),true,uiDupKey(featureName),true);
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(featureName);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
      
      public static function refreshStatic(featureName:String) : void
      {
         var window:ActionDrivenWindow = null;
         if(s_map.hasOwnProperty(featureName))
         {
            window = s_map[featureName];
            if(window)
            {
               window.refreshWindow();
            }
         }
      }
      
      override protected function get manager() : BaseFeatureManager
      {
         return ActionDrivenManager.getInstance(m_featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         var buyButtonText:String = null;
         var i:int = 0;
         var harvestButtonText:String = null;
         var harvestButtonTextKey:String = null;
         var j:int = 0;
         super.postLoadComplete();
         this.m_manager.grantExtraReward();
         if(m_window)
         {
            if(m_window.title_tf)
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_title")));
            }
            if(m_window.subtitle_tf)
            {
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_subtitle")));
            }
            if(m_window.recipeName_tf)
            {
               addWidget(new ZwTextField(m_window.recipeName_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_recipeName")));
            }
            if(m_window.timeleft_tf)
            {
               addWidget(new ZwTextField(m_window.timeleft_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_footer")));
            }
            if(m_window.youhave_tf)
            {
               addWidget(new ZwTextField(m_window.youhave_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_countTop")));
            }
            if(m_window.giftcount_tf)
            {
               this.m_scoreTF = new ZwTextField(m_window.giftcount_tf);
               addWidget(this.m_scoreTF);
            }
            if(m_window.gifts_tf)
            {
               addWidget(new ZwTextField(m_window.gifts_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_countBottom")));
            }
            if(m_window.whatisthis_bt)
            {
               addWidget(new ZwButton(m_window.whatisthis_bt,this.onQuestionMarkButtonClicked));
            }
            if(m_window.craft_bt)
            {
               this.m_craftButton = new FarmAnimatedTextButton(m_window.craft_bt,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_buttonTop"),this.onCraftButtonClicked) as FarmAnimatedTextButton;
               addWidget(this.m_craftButton);
               this.attachTooltipToButton(this.m_craftButton,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_craftToolTip"));
            }
            if(m_window.buy_bt)
            {
               buyButtonText = ZLocUtils.t("FarmGame","Buy");
               this.m_buyButton = new FarmAnimatedCashButton(m_window.buy_bt,buyButtonText,this.m_purchasePrice.toString(),this.onBuyButtonClicked,false,false,true,"",this.m_purchasePrice) as FarmAnimatedCashButton;
               addWidget(this.m_buyButton);
            }
            if(m_window.timer_tf)
            {
               this.m_timerTF = new ZwTextField(m_window.timer_tf);
               addWidget(this.m_timerTF);
            }
            if(m_window.tutorial_mc)
            {
               this.m_tutorialClip = m_window.tutorial_mc;
               if(this.m_tutorialClip.okay_bt)
               {
                  addWidget(new FarmAnimatedTextButton(this.m_tutorialClip.okay_bt,ZLocUtils.t("FarmGame","Okay"),this.onTutorialOkButtonClicked));
               }
            }
            if(m_window.askkit_bt)
            {
               this.m_helperButton = addWidget(new FarmAnimatedTextButton(m_window.askkit_bt,"",this.onHelperButtonClick)) as FarmAnimatedTextButton;
            }
            else if(m_window.askFor_mc)
            {
               this.m_helperButton = addWidget(new FarmAnimatedTextButton(m_window.askFor_mc,"Ask",this.onHelperButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.hasOwnProperty("helpcounter_mc"))
            {
               this.m_helpCounterArray = new Array();
               this.m_helpCounter = addWidget(new ZwWidget(m_window.helpcounter_mc)) as ZwWidget;
               for(i = 0; i < HELPER_COUNT; i++)
               {
                  if(m_window.helpcounter_mc["helpcount_mc_" + i])
                  {
                     this.m_helpCounterArray.push(addWidget(new ZwWidget(m_window.helpcounter_mc["helpcount_mc_" + i]) as ZwWidget));
                     this.m_helpCounterArray[i].element.on_mc.visible = false;
                  }
               }
            }
            this.setupHelperButton();
            if(m_window.hasOwnProperty("disclaimer_tf"))
            {
               this.m_disclaimerLink = addWidget(new ZwButton(m_window.disclaimer_tf,this.onDisclaimerLinkClick)) as ZwButton;
               this.m_disclaimerLink.element.useHandCursor = true;
               this.m_disclaimerLink.element.buttonMode = true;
               this.m_disclaimerLink.element.mouseChildren = false;
            }
            if(m_window.subheader_tf)
            {
               addWidget(new ZwTextField(m_window.subheader_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_tooltipSubheader")));
            }
            if(m_window.tooltipReadyHarvest_mc)
            {
               this.m_tooltipMC = m_window.tooltipReadyHarvest_mc;
               if(Boolean(this.m_harvestButton) && Boolean(m_window.ovenready_mc))
               {
                  this.m_tooltipMC.visible = false;
               }
               if(Boolean(this.m_tooltipMC.header_tf) && ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_tooltipHeader") != "")
               {
                  addWidget(new ZwTextField(this.m_tooltipMC.header_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_tooltipHeader")));
               }
               if(this.m_tooltipMC.bt_harvest)
               {
                  harvestButtonTextKey = m_featureName + "_harvestButton";
                  if(ZLocUtils.hasString(ZLOC_PACKAGE_DIALOGS,harvestButtonTextKey))
                  {
                     harvestButtonText = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,harvestButtonTextKey);
                  }
                  else
                  {
                     harvestButtonText = ZLocUtils.t("FarmGame","Harvest");
                  }
                  this.m_harvestButton = new FarmAnimatedTextButton(this.m_tooltipMC.bt_harvest,harvestButtonText,this.onHarvestButtonClicked);
                  addWidget(this.m_harvestButton);
               }
            }
            if(m_window.collectready_mc)
            {
               this.m_collectReady = m_window.collectready_mc;
               if(this.m_collectReady.bt_collectfriends)
               {
                  this.m_collectButton = new FarmAnimatedTextButton(this.m_collectReady.bt_collectfriends,"",this.onCollectButtonClicked);
                  addWidget(this.m_collectButton);
                  this.setupCollectButton();
               }
            }
            else
            {
               this.m_collectButton = null;
            }
            if(m_window.counter_mc)
            {
               this.m_globalMeterCounterArray = new Array();
               this.m_globalMeter = addWidget(new ZwWidget(m_window.counter_mc)) as ZwWidget;
               for(j = 0; j < GLOBAL_METER_COUNT_MAX; j++)
               {
                  if(m_window.counter_mc["helpcount_mc_" + j])
                  {
                     this.m_globalMeterCounterArray.push(addWidget(new ZwWidget(m_window.counter_mc["helpcount_mc_" + j]) as ZwWidget));
                     this.m_globalMeterCounterArray[j].element.on_mc.visible = false;
                  }
               }
            }
            if(m_window.count_tf)
            {
               this.m_meterScoreTF = new ZwTextField(m_window.count_tf);
               addWidget(this.m_meterScoreTF);
            }
            this.refreshWindow();
            this.count(StatsTrackingConstants.IMPRESSIONS,this.m_manager ? this.m_manager.getActionCount().toString() : "0");
         }
         if(!Global.player.getSeenFlag(uiDupKey(m_featureName)))
         {
            this.setupFtue();
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.onCollectButtonClicked(null);
         this.setUpGlobalMeter();
         if(this.m_scoreTF)
         {
            this.m_scoreTF.text = this.getScoreText();
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.enabled = true;
         }
         this.handleHarvestableResourceLogic();
         this.conditionallyShowCongratsAnimation();
         this.conditionallyShowCompletedState();
      }
      
      private function conditionallyShowCompletedState() : void
      {
         var i:int = 0;
         var j:int = 0;
         if(this.m_manager.hasReachedMaxActionCount())
         {
            if(this.m_harvestButton)
            {
               this.m_harvestButton.enabled = false;
            }
            if(Boolean(this.m_buyButton) && Boolean(this.m_craftButton))
            {
               this.m_buyButton.enabled = false;
               this.m_craftButton.enabled = false;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_helperButton,ZLocUtils.t("Dialogs","GenericExpansion_button_posting"));
               this.m_globalMeter.enabled = false;
               if(this.m_helpCounterArray)
               {
                  for(i = 0; i < HELPER_COUNT; i++)
                  {
                     this.m_helpCounterArray[i].element.on_mc.visible = false;
                     this.m_helpCounter.detachTooltip();
                  }
               }
               if(this.m_globalMeterCounterArray)
               {
                  for(j = 0; j < GLOBAL_METER_COUNT_MAX; j++)
                  {
                     this.m_globalMeterCounterArray[j].element.on_mc.visible = false;
                  }
               }
            }
            if(Boolean(m_window) && Boolean(m_window.checkmark_mc))
            {
               m_window.checkmark_mc.visible = true;
            }
            if(Boolean(m_window) && Boolean(m_window.wait_mc))
            {
               m_window.wait_mc.visible = true;
            }
         }
      }
      
      private function onDisclaimerLinkClick(event:Event) : void
      {
         navigateToURL(new URLRequest("http://zynga.org/campaigns/farmville-donorschoose"),"_blank");
      }
      
      private function setupFtue() : void
      {
         this.m_tutorialClip.gotoAndStop(1);
         this.m_tutorialClip.visible = true;
      }
      
      private function getScoreText() : String
      {
         return this.m_manager.getActionCount() + ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_countMiddle");
      }
      
      private function onQuestionMarkButtonClicked(event:Event) : void
      {
         this.setupFtue();
      }
      
      private function onHelperButtonClick(event:Event) : void
      {
         if(this.m_helperButton.enabled)
         {
            this.m_helperButton.enabled = false;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"onAskForMore",this.onCompleteAskForTransaction,[m_featureName]));
            this.count("ask_bt","click");
         }
      }
      
      private function setupHelperCountStars() : void
      {
         var i:int = 0;
         var j:int = 0;
         var key:String = m_featureName + FRIEND_HELP_ASK_KEY;
         var friendsWhoHelpedCount:int = Global.player.getActionCount(key);
         if(Boolean(this.m_helpCounter) && Boolean(this.m_helpCounterArray))
         {
            for(i = 0; i < HELPER_COUNT; i++)
            {
               this.m_helpCounterArray[i].element.on_mc.visible = false;
            }
            for(j = 0; j < Math.min(HELPER_COUNT,friendsWhoHelpedCount); j++)
            {
               this.m_helpCounterArray[j].element.on_mc.visible = true;
            }
            this.m_helpCounter.detachTooltip();
            this.m_helpCounter.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_helpstars_tooltip",{
               "count":friendsWhoHelpedCount,
               "total":HELPER_COUNT
            })));
         }
      }
      
      private function onCompleteAskForTransaction(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         var currentTimeSec:int = 0;
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         if(success)
         {
            currentTimeSec = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(ActionDrivenManager.VIRAL_POST_FREQUENCY_FLAG,currentTimeSec,true);
            this.count("feed_post","success");
         }
         else
         {
            this.count("feed_post","failed");
         }
         this.setupHelperButton();
      }
      
      private function onCollectButtonClicked(event:Event) : void
      {
         var rewardFromFeedPost:int = this.m_manager.canCollectFromFeed();
         if(rewardFromFeedPost > 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"updateActionCount",null,[m_featureName]),true);
         }
         var item:FarmItem = this.m_manager.consumable;
         for(var i:int = 1; i <= rewardFromFeedPost; i++)
         {
            this.m_manager.incrementActionCountWithOrder(item.code);
         }
         if(this.m_collectButton)
         {
            this.refreshWindow();
         }
         var key:String = m_featureName + ActionDrivenWindow.FRIEND_HELP_ASK_KEY;
         var friendsWhoHelpedCount:int = Global.player.getActionCount(key);
         var friendsWhoseHelpRemain:int = friendsWhoHelpedCount % HELPER_COUNT;
         Global.player.setActionCount(key,friendsWhoseHelpRemain);
         this.setupCollectButton();
         this.count("collect",rewardFromFeedPost.toString());
      }
      
      private function setupCollectButton() : void
      {
         var rewardFromFeedPost:int = this.m_manager.canCollectFromFeed();
         if(Boolean(m_window.collectready_mc) && Boolean(m_window.collectready_mc["bt_collectfriends"]))
         {
            if(rewardFromFeedPost > 0)
            {
               this.m_collectButton.text = "Collect (x" + rewardFromFeedPost + ")";
               this.m_collectReady.visible = true;
            }
            else
            {
               this.m_collectReady.visible = false;
            }
            this.setupHelperCountStars();
         }
      }
      
      private function setUpGlobalMeter() : void
      {
         var i:int = 0;
         var j:int = 0;
         var itemCode:String = this.getItemCode();
         var globalMeterCount:int = this.m_manager.getConsumableItemCount(itemCode);
         if(Boolean(this.m_globalMeter) && Boolean(this.m_globalMeterCounterArray))
         {
            for(i = 0; i < GLOBAL_METER_COUNT_MAX; i++)
            {
               this.m_globalMeterCounterArray[i].element.on_mc.visible = false;
            }
            for(j = 0; j < globalMeterCount; j++)
            {
               this.m_globalMeterCounterArray[j].element.on_mc.visible = true;
            }
         }
         if(this.m_meterScoreTF)
         {
            this.m_meterScoreTF.text = globalMeterCount.toString() + ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_consumableMaxCount");
         }
      }
      
      private function setupHelperButton() : void
      {
         var currentTime:int = 0;
         var lastViralSent:int = 0;
         var timeCanPostAgain:int = 0;
         var msg:String = null;
         if(Boolean(this.m_helperButton) && !this.m_manager.hasReachedMaxActionCount())
         {
            this.m_helperButton.detachTooltip();
            if(this.m_manager.canPost())
            {
               this.m_helperButton.enabled = true;
               this.attachTooltipToButton(this.m_helperButton,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,m_featureName + "_ask_button_tooltip",{"count":HELPER_COUNT}));
            }
            else
            {
               this.m_helperButton.enabled = false;
               currentTime = GlobalEngine.serverTime / 1000;
               lastViralSent = Global.player.getFeatureLastShown(ActionDrivenManager.VIRAL_POST_FREQUENCY_FLAG);
               timeCanPostAgain = Math.ceil((ActionDrivenManager.COOLDOWN_HOURS * FarmGameUtil.NUM_SECS_IN_HOUR - currentTime + lastViralSent) / FarmGameUtil.NUM_SECS_IN_HOUR);
               msg = "Post in " + (timeCanPostAgain == 1 ? "1 hour" : timeCanPostAgain + " hours");
               FarmGameUtil.disableButtonAndShowTooltip(this.m_helperButton,msg);
            }
         }
      }
      
      private function onTutorialOkButtonClicked(event:Event) : void
      {
         if(this.m_currentTutorialState < this.getNumberOfStates())
         {
            if(this.m_currentTutorialState == 0)
            {
               StatsManager.count(m_featureName,StatsTrackingConstants.FTUE,StatsTrackingConstants.START);
            }
            (this.m_tutorialClip as MovieClip).play();
            ++this.m_currentTutorialState;
         }
         else
         {
            StatsManager.count(m_featureName,StatsTrackingConstants.FTUE,StatsTrackingConstants.FINISHED);
            this.m_currentTutorialState = 1;
            this.m_tutorialClip.visible = false;
            if(!Global.player.getSeenFlag(uiDupKey(m_featureName)))
            {
               Global.player.setSeenFlag(uiDupKey(m_featureName));
            }
         }
      }
      
      private function getNumberOfStates() : int
      {
         var result:int = MAX_TUTORIAL_STATE;
         if(!Global.player.getSeenFlag(uiDupKey(m_featureName)))
         {
            result++;
         }
         return result;
      }
      
      private function getItemCode() : String
      {
         var recipeId:String = null;
         var recipe:RecipeItem = null;
         var itemCode:String = "";
         var recipeIdConstantValue:String = this.m_manager.getConstantsStringWithKey("recipeId");
         if(recipeIdConstantValue)
         {
            recipeId = recipeIdConstantValue;
            if(recipeId)
            {
               recipe = Global.craftConfigSettings.getRecipeById(recipeId);
               itemCode = recipe.onUseItemCode;
            }
         }
         return itemCode;
      }
      
      private function onCraftButtonClicked(event:Event) : void
      {
         var recipeId:String = null;
         var recipeVariantIds:Array = null;
         var recipeVariantId:String = null;
         var recipe:RecipeItem = null;
         var craftShop:String = null;
         var craftshops:Array = null;
         var recipeIdConstantValue:String = this.m_manager.getConstantsStringWithKey("recipeId");
         if(recipeIdConstantValue)
         {
            if(recipeIdConstantValue.indexOf(",") > 0)
            {
               recipeVariantIds = recipeIdConstantValue.split(",");
               for each(recipeVariantId in recipeVariantIds)
               {
                  recipe = Global.craftConfigSettings.getRecipeById(recipeVariantId);
                  if(Boolean(recipe) && recipe.isPlayerEligible())
                  {
                     recipeId = recipeVariantId;
                     break;
                  }
               }
            }
            else
            {
               recipeId = recipeIdConstantValue;
            }
            if(recipeId)
            {
               craftShop = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
               if(craftShop)
               {
                  CraftingManager.getInstance().openCraftingUiForRecipe(recipeId,craftShop);
                  craftshops = Global.world.getObjectsByName(craftShop);
                  if(Boolean(craftshops) && craftshops.length == 0)
                  {
                     this.close();
                  }
               }
            }
         }
         this.count(StatsTrackingConstants.CLICK_CRAFT);
      }
      
      private function onHarvestButtonClicked(event:Event) : void
      {
         this.m_manager.incrementActionCount();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"harvestForActionCount",this.m_manager.onHarvestFinished,[m_featureName]));
         this.m_manager.setFeatureLastShown();
         this.refreshWindow();
         this.m_manager.addToasterIdleTask();
         this.count(StatsTrackingConstants.HARVEST);
      }
      
      private function onBuyButtonClicked(event:Event) : void
      {
         var item:FarmItem = null;
         var buyResult:Boolean = false;
         if(Global.player.canBuyCash(this.m_purchasePrice))
         {
            item = this.m_manager.consumable;
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               this.m_buyButton.showPaymentConfirmation = false;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyForActionCount",null,[m_featureName]));
               this.m_manager.incrementActionCountWithOrder(item.code);
               this.refreshWindow();
               this.count("buy_bt","click");
            }
         }
      }
      
      private function conditionallyShowCongratsAnimation() : void
      {
         m_window.giftfireworks_mc.visible = false;
         if(this.m_cachedActionCount < this.m_manager.getActionCount())
         {
            this.m_cachedActionCount = this.m_manager.getActionCount();
            if(m_window.giftfireworks_mc)
            {
               m_window.giftfireworks_mc.visible = true;
               m_window.giftfireworks_mc.gotoAndPlay(2);
            }
         }
      }
      
      private function handleHarvestableResourceLogic() : void
      {
         var canHarvest:Boolean = this.m_manager.canHarvest();
         this.toggleHarvestableResource(canHarvest);
         if(!canHarvest)
         {
            this.startUpdateTimer();
         }
      }
      
      private function toggleHarvestableResource(canHarvest:Boolean) : void
      {
         if(m_window.ovenbaking_mc)
         {
            m_window.ovenbaking_mc.visible = !canHarvest;
         }
         if(m_window.ovenready_mc)
         {
            m_window.ovenready_mc.visible = canHarvest;
         }
         if(m_window.oven_highlight_mc)
         {
            m_window.oven_highlight_mc.visible = canHarvest;
         }
         if(Boolean(this.m_tooltipMC) && Boolean(this.m_tooltipMC.bt_harvest))
         {
            this.m_tooltipMC.visible = canHarvest;
         }
         if(this.m_harvestButton)
         {
            this.m_harvestButton.visible = canHarvest;
         }
         if(Boolean(this.m_timerTF) && canHarvest)
         {
            this.m_timerTF.text = "Ready!";
         }
      }
      
      private function startUpdateTimer() : void
      {
         if(this.m_updateTimer == null)
         {
            this.m_updateTimer = new Timer(UPDATE_LOOP_DELAY);
            this.m_updateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimer);
         }
         if(!this.m_updateTimer.running)
         {
            this.m_updateTimer.start();
         }
      }
      
      private function onUpdateTimer(event:Event) : void
      {
         if(this.m_manager.canHarvest())
         {
            this.m_updateTimer.stop();
            this.toggleHarvestableResource(true);
         }
         else
         {
            this.updateTimeLeft();
         }
      }
      
      private function updateTimeLeft() : void
      {
         var timeLastHarvested:int = 0;
         var currentTime:int = 0;
         var timeSinceLastHarvest:int = 0;
         var timeLeft:int = 0;
         var timeLeftArray:Array = null;
         var hours:String = null;
         var minutes:String = null;
         var seconds:String = null;
         if(Boolean(this.m_manager) && Boolean(this.m_timerTF))
         {
            timeLastHarvested = this.m_manager.getFeatureLastShown();
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timeSinceLastHarvest = currentTime - timeLastHarvested;
            timeLeft = this.m_harvestThrottleSeconds - timeSinceLastHarvest;
            if(timeLeft < 0)
            {
               timeLeft = 0;
            }
            timeLeftArray = FarmGameUtil.parseTimeLeft(timeLeft);
            if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
            {
               hours = int(timeLeftArray[1]).toString();
               if(hours.length == 1)
               {
                  hours = "0" + hours;
               }
               minutes = int(timeLeftArray[2]).toString();
               if(minutes.length == 1)
               {
                  minutes = "0" + minutes;
               }
               seconds = int(timeLeftArray[3]).toString();
               if(seconds.length == 1)
               {
                  seconds = "0" + seconds;
               }
               this.m_timerTF.text = hours + ":" + minutes + ":" + seconds;
            }
         }
      }
      
      override public function close() : void
      {
         delete s_map[m_featureName];
         super.close();
         this.count(StatsTrackingConstants.CLOSE);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_uiDupKeyPrefix = null;
         this.m_scoreTF = null;
         this.m_tooltipMC = null;
         this.m_harvestButton = null;
         this.m_timerTF = null;
         this.m_buyButton = null;
         this.m_helpCounter = null;
         this.m_helpCounterArray = null;
         this.m_helperButton = null;
         this.m_disclaimerLink = null;
         if(this.m_updateTimer)
         {
            this.m_updateTimer.removeEventListener(TimerEvent.TIMER,this.onUpdateTimer);
            this.m_updateTimer = null;
         }
         this.m_manager = null;
      }
      
      private function count(phylum:String, zclass:String = "") : void
      {
         StatsManager.count(m_featureName,StatsTrackingConstants.MAIN_UI,phylum,zclass);
      }
      
      private function attachTooltipToButton(button:ZwWidget, message:String = "") : void
      {
         var infoTooltip:FarmTextTooltip = new FarmTextTooltip(message);
         button.attachTooltip(infoTooltip);
      }
   }
}

