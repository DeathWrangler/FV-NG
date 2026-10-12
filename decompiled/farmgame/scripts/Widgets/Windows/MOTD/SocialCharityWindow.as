package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSocialCharityAction;
   import Widgets.Buttons.FarmAnimatedAdjustableCashButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.ProgressBars.ZwAbstractProgressBar;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.SocialCharity.SocialCharityThankYouWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   
   public class SocialCharityWindow extends FarmWindow
   {
      
      protected static const DEFAULT_PREFIX:String = "LemonAidStand";
      
      public static const FEATURE_NAME:String = "socialCharity";
      
      protected var m_assets:Dictionary;
      
      private const SOCIAL_CHARITY_SHARE_THROTTLE:String = "socialCharityShareThrottle";
      
      private var m_campaignName:String;
      
      protected var m_tutorialSeenFlag:String;
      
      private var m_shareSourceName:String;
      
      private var m_statsCounter:String;
      
      private const GOAL:int = 120000;
      
      private const SHARE_THROTTLE:int = 14400;
      
      private var m_items:Array;
      
      protected var m_reward:Object;
      
      protected var m_introFrame:ZwFrame;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      protected var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_sparkle:ZwBaseWidget;
      
      private var m_cooldownTF:ZwTextField;
      
      private var m_progress:int;
      
      private var m_interacted:Boolean;
      
      private var m_redeemedPrize:Boolean;
      
      private var m_variant:int;
      
      private var m_lastShared:int;
      
      private var m_featureInteractionFlag:String;
      
      private var m_redeemedPrizeFlag:String;
      
      protected var m_dialogPrefix:String;
      
      protected var m_buyButtons:Dictionary;
      
      private var m_currentItem:FarmItem;
      
      private var m_variablePricing:Boolean;
      
      protected var m_anchorConfig:Dictionary;
      
      protected var m_adjustedPricing:Dictionary;
      
      private var m_anchorPricingExperiment:String;
      
      protected var m_pricingExperiment:String;
      
      protected var m_showFlexibleContributionButton:Boolean;
      
      public function SocialCharityWindow(buildingName:String = "", source:String = "feed", overrideAssetPath:String = "", overrideDialogPrefix:String = "")
      {
         var mainWindowAsset:String = null;
         var items:XMLList = null;
         var reward:XMLList = null;
         var itemData:Object = null;
         var itemsLength:int = 0;
         var i:int = 0;
         var assetXML:XML = null;
         var anchorConfig:XMLList = null;
         var k:int = 0;
         var variantName:String = null;
         var itemConfigData:Dictionary = null;
         var itemConfig:XML = null;
         this.m_assets = new Dictionary();
         var campaignConfig:XML = getCampaignConfigFromBuildingName(FEATURE_NAME,buildingName);
         if(campaignConfig)
         {
            this.m_items = [];
            items = campaignConfig.itemConfig.socialItem;
            reward = campaignConfig.itemConfig.socialCharityReward;
            itemsLength = items.length();
            for(i = 0; i < itemsLength; i++)
            {
               itemData = {
                  "item":Global.farmGameSettingsManager.getFarmItemByName(items[i].@name),
                  "price":items[i].@price,
                  "checkVariablePricing":items[i].@checkVariablePricing == "true"
               };
               this.m_items[i] = itemData;
            }
            if(reward.length() > 0)
            {
               itemData = {
                  "item":Global.farmGameSettingsManager.getFarmItemByName(reward[0].@name),
                  "price":reward[0].@price,
                  "checkVariablePricing":reward[0].@checkVariablePricing == "true"
               };
               this.m_reward = itemData;
            }
            this.m_featureInteractionFlag = campaignConfig.interactionConfig.flags[0].@interactionFlag;
            this.m_interacted = Global.player.getSeenFlag(this.m_featureInteractionFlag);
            this.m_redeemedPrizeFlag = campaignConfig.interactionConfig.flags[0].@redeemedPrizeFlag;
            this.m_redeemedPrize = Global.player.getSeenFlag(this.m_redeemedPrizeFlag);
            this.m_variant = Global.experimentManager.getExperimentVariant(campaignConfig.@experiment);
            this.m_pricingExperiment = campaignConfig.@pricingExperiment;
            this.m_campaignName = campaignConfig.@name;
            this.m_tutorialSeenFlag = campaignConfig.@name + FEATURE_NAME;
            this.m_shareSourceName = campaignConfig.@shareSource;
            this.m_statsCounter = campaignConfig.@statsCounter + "_from" + source;
            this.m_dialogPrefix = overrideDialogPrefix != "" ? overrideDialogPrefix : campaignConfig.@dialogPrefix;
            for each(assetXML in campaignConfig.assetConfig.asset)
            {
               this.m_assets[String(assetXML.@name)] = String(assetXML.@path);
            }
            mainWindowAsset = overrideAssetPath == "" ? this.m_assets["mainWindow"] : overrideAssetPath;
            this.m_anchorPricingExperiment = campaignConfig.@anchorExperiment;
            this.m_anchorConfig = new Dictionary();
            anchorConfig = campaignConfig.anchorPriceConfig.variantVersion;
            for(k = 0; k < anchorConfig.length(); k++)
            {
               variantName = anchorConfig[k].@name;
               itemConfigData = new Dictionary();
               for each(itemConfig in anchorConfig[k].socialItem)
               {
                  itemConfigData[String(itemConfig.@name)] = {
                     "anchorPrice":int(itemConfig.@anchorPrice),
                     "displayedPrice":itemConfig.@displayedPrice
                  };
               }
               this.m_anchorConfig[variantName] = itemConfigData;
            }
            this.loadAnchorPricingConfigFlags();
         }
         this.m_progress = Global.flashHotParams["LEMONAID_STAND_PROGRESS"];
         this.m_lastShared = Global.player.getFeatureLastShown(this.SOCIAL_CHARITY_SHARE_THROTTLE);
         this.m_buyButtons = new Dictionary();
         super(mainWindowAsset);
      }
      
      public static function getCampaignConfigFromBuildingName(featureName:String, buildingName:String) : XML
      {
         var campaignConfigs:XMLList = null;
         var j:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         var campaignConfig:XML = null;
         if(feature)
         {
            campaignConfigs = feature["campaigns"].campaign;
            if(campaignConfigs)
            {
               for(j = 0; j < campaignConfigs.length(); j++)
               {
                  if(campaignConfigs[j].@building == buildingName)
                  {
                     campaignConfig = campaignConfigs[j];
                     break;
                  }
               }
            }
         }
         return campaignConfig;
      }
      
      private function loadAnchorPricingConfigFlags() : void
      {
         var anchorPriceVariant:String = null;
         var pricingVariant:int = Global.experimentManager.getExperimentVariant(this.m_pricingExperiment);
         switch(pricingVariant)
         {
            case 1:
               this.m_showFlexibleContributionButton = false;
               break;
            case 2:
            case 3:
               this.m_showFlexibleContributionButton = true;
               break;
            default:
               this.m_showFlexibleContributionButton = false;
         }
         if(this.m_showFlexibleContributionButton)
         {
            anchorPriceVariant = String(Global.experimentManager.getExperimentVariant(this.m_anchorPricingExperiment));
            this.m_adjustedPricing = this.m_anchorConfig[anchorPriceVariant];
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var subtitleText:String = null;
         var frame:ZwFrame = null;
         var slotIcon:ObjectPreviewFrame = null;
         var contributeFrame:FarmAnimatedAdjustableCashButton = null;
         var buyButton:FarmAnimatedCashButton = null;
         super.onLoadComplete(event);
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"title")));
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            if(this.m_variant == 3)
            {
               subtitleText = ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"cash_subtitle");
            }
            else
            {
               subtitleText = ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"subtitle");
            }
            addWidget(new ZwTextField(m_window.generic2_tf,subtitleText));
         }
         if(m_window.hasOwnProperty("legal_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.legal_mc,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"legal"),this.onLegalClick));
         }
         if(m_window.hasOwnProperty("share_tf"))
         {
            addWidget(new ZwTextField(m_window.share_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"share_title")));
         }
         if(m_window.hasOwnProperty("share2_tf"))
         {
            addWidget(new ZwTextField(m_window.share2_tf,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"share_subtitle")));
         }
         var shareEnabled:Boolean = this.checkShareEnabled();
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"share_button"),this.onShareLemonaidClick));
            if(!shareEnabled)
            {
               this.disableShareButton();
            }
         }
         if(m_window.hasOwnProperty("cooldown_tf"))
         {
            addWidget(this.m_cooldownTF = new ZwTextField(m_window.cooldown_tf,""));
            this.setCooldownText();
            this.m_cooldownTF.visible = !shareEnabled;
         }
         if(m_window.hasOwnProperty("accept2_bt"))
         {
            addWidget(this.m_redeemButton = new FarmAnimatedTextButton(m_window.accept2_bt,ZLocUtils.t("Dialogs","Redeem"),this.onRedeemPrize));
         }
         this.setRedeemVisibility();
         if(m_window.hasOwnProperty("sparkles_mc"))
         {
            addWidget(this.m_sparkle = new ZwBaseWidget(m_window.sparkles_mc));
            this.m_sparkle.visible = false;
         }
         if(m_window.hasOwnProperty("whatisthis_bt"))
         {
            addWidget(new FarmButton(m_window.whatisthis_bt,this.onWhatIsThisClick),true);
         }
         this.addBuyableItems();
         if(m_window.hasOwnProperty("goal_mc"))
         {
            frame = new ZwFrame(m_window.goal_mc);
            if(frame.element.hasOwnProperty("icon_mc"))
            {
               slotIcon = new ObjectPreviewFrame(frame.element.icon_mc,this.m_reward.item);
               frame.addWidget(slotIcon);
            }
            if(Boolean(this.m_redeemButton && !this.m_redeemButton.visible) && Boolean(this.m_showFlexibleContributionButton) && Boolean(this.m_reward.checkVariablePricing) && frame.element.hasOwnProperty("contribute_mc"))
            {
               contributeFrame = new FarmAnimatedAdjustableCashButton(frame.element.contribute_mc,this.m_adjustedPricing[this.m_reward.item.name].anchorPrice,2,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),this.m_adjustedPricing[this.m_reward.item.name].displayedPrice,this.getBuyCallback(this.m_reward.item,this.m_reward.checkVariablePricing));
               this.m_buyButtons[this.m_reward.item.name] = contributeFrame;
               frame.addWidget(contributeFrame);
            }
            else if(Boolean(this.m_redeemButton) && Boolean(!this.m_redeemButton.visible) && frame.element.hasOwnProperty("buy_bt"))
            {
               buyButton = new FarmAnimatedCashButton(frame.element.buy_bt,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),this.m_reward.price.toString(),this.getBuyCallback(this.m_reward.item,this.m_reward.checkVariablePricing));
               this.m_buyButtons[this.m_reward.item.name] = buyButton;
               frame.addWidget(buyButton);
            }
            addWidget(frame);
         }
         this.addIntro();
         this.addProgressBar();
         FarmStatsManager.count(this.m_statsCounter,"main_dialog","impressions");
      }
      
      protected function addRewardItemWithoutProgressBar() : void
      {
      }
      
      public function addBuyableItems() : void
      {
         var frame:ZwFrame = null;
         for(var i:int = 0; i < this.m_items.length; i++)
         {
            if(m_window["slot_" + i + "_mc"] != null)
            {
               frame = new ZwFrame(m_window["slot_" + i + "_mc"]);
               this.addSlotElements(frame,i);
               addWidget(frame);
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_cooldownTF = null;
         this.m_introFrame = null;
         this.m_items = null;
         this.m_redeemButton = null;
         this.m_reward = null;
         this.m_shareButton = null;
         this.m_sparkle = null;
         super.release();
      }
      
      protected function addIntro() : void
      {
         if(m_window.intro_mc != null)
         {
            this.m_introFrame = new ZwFrame(m_window.intro_mc);
            if(this.m_introFrame.element.hasOwnProperty("accept_bt"))
            {
               this.m_introFrame.addWidget(new FarmAnimatedTextButton(this.m_introFrame.element.accept_bt,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"intro_accept"),this.onHideIntroClick));
            }
            addWidget(this.m_introFrame);
            this.m_introFrame.visible = false;
            if(!Global.player.getSeenFlag(this.m_tutorialSeenFlag))
            {
               this.showIntroClip();
            }
         }
      }
      
      private function addProgressBar() : void
      {
         var frame:ZwFrame = null;
         var percentField:ZwTextField = null;
         var progressBar:FarmProgressBar = null;
         if(m_window.hasOwnProperty("meter_mc"))
         {
            frame = new ZwFrame(m_window.meter_mc);
            if(frame.element.hasOwnProperty("percent_tf"))
            {
               percentField = new ZwTextField(frame.element.percent_tf);
               percentField.text = this.m_progress.toString() + "%";
               frame.addWidget(percentField);
            }
            if(frame.element.hasOwnProperty("stack_mc"))
            {
               progressBar = new FarmProgressBar(frame.element.stack_mc);
               progressBar.direction = ZwAbstractProgressBar.DIRECTION_UP;
               progressBar.progress = this.m_progress;
               frame.addWidget(progressBar);
            }
            addWidget(frame);
         }
         else
         {
            this.addRewardItemWithoutProgressBar();
         }
      }
      
      private function setRedeemVisibility() : void
      {
         var isRedeemVisible:Boolean = this.m_progress == 100 && this.m_interacted && !this.m_redeemedPrize;
         if(this.m_redeemButton)
         {
            this.m_redeemButton.visible = isRedeemVisible;
            this.m_redeemButton.applyGrayOut = false;
         }
      }
      
      protected function addSlotElements(frame:ZwFrame, index:int) : void
      {
         var item:FarmItem = null;
         var slotIcon:ObjectPreviewFrame = null;
         var contributeFrame:FarmAnimatedAdjustableCashButton = null;
         var buyButton:FarmAnimatedCashButton = null;
         if(frame.element.icon_mc != null)
         {
            item = this.m_items[index].item;
            slotIcon = new ObjectPreviewFrame(frame.element.icon_mc,item,null,null,[100]);
            frame.addWidget(slotIcon);
         }
         switch(this.m_items[index].checkVariablePricing && this.m_showFlexibleContributionButton)
         {
            case true:
               if(frame.element.hasOwnProperty("contribute_mc"))
               {
                  contributeFrame = new FarmAnimatedAdjustableCashButton(frame.element.contribute_mc,this.m_adjustedPricing[this.m_items[index].item.name].anchorPrice,2,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),this.m_adjustedPricing[this.m_items[index].item.name].displayedPrice,this.getBuyCallback(this.m_items[index].item,this.m_items[index].checkVariablePricing));
                  this.m_buyButtons[this.m_items[index].item.name] = contributeFrame;
                  frame.addWidget(contributeFrame);
               }
               break;
            case false:
               if(frame.element.hasOwnProperty("buy_bt"))
               {
                  buyButton = new FarmAnimatedCashButton(frame.element.buy_bt,ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"donateButton"),this.m_items[index].price.toString(),this.getBuyCallback(this.m_items[index].item,this.m_items[index].checkVariablePricing));
                  this.m_buyButtons[this.m_items[index].item.name] = buyButton;
                  frame.addWidget(buyButton);
               }
         }
      }
      
      private function onRedeemPrize(event:Event) : void
      {
         this.m_redeemButton.enabled = false;
         TransactionManager.addTransaction(new TGenericTransaction("SocialCharityService","redeemParticipationPrize",this.redeemCallback,[this.m_campaignName]));
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         FarmStatsManager.count(this.m_statsCounter,"main_dialog","what_is_this");
         this.showIntroClip();
      }
      
      public function redeemCallback(result:Object) : void
      {
         if(result.hasOwnProperty("redeemed"))
         {
            Global.player.setSeenFlag(this.m_redeemedPrizeFlag,false,true);
            this.m_redeemedPrize = true;
            Global.player.addGift(result.redeemed);
            UI.displayPopup(new SocialCharityThankYouWindow(result.redeemed,this.m_campaignName,this.m_statsCounter,this.m_assets["thankYouWindow"],this.m_dialogPrefix),false,"LemonAidStand",true);
         }
         this.setRedeemVisibility();
      }
      
      protected function showIntroClip() : void
      {
         this.m_introFrame.visible = true;
         (this.m_introFrame.element as MovieClip).gotoAndPlay(0);
      }
      
      private function hideIntroClip() : void
      {
         this.m_introFrame.visible = false;
         (this.m_introFrame.element as MovieClip).stop();
         FarmStatsManager.count(this.m_statsCounter,"main_dialog","finish_FTUE");
      }
      
      protected function getBuyCallback(item:FarmItem, checkVariablePricing:Boolean, skipFrictionBuy:Boolean = false) : Function
      {
         return function():void
         {
            slotBuy(item,checkVariablePricing);
         };
      }
      
      private function slotBuy(item:FarmItem, checkVariablePricing:Boolean, skipFrictionBuy:Boolean = false) : void
      {
         FarmStatsManager.count(this.m_statsCounter,"click_buy",item.name);
         var buySuccess:Boolean = false;
         var price:int = checkVariablePricing ? int(this.m_buyButtons[item.name].getAmountText()) : item.realCashCost;
         this.m_currentItem = item;
         this.m_variablePricing = checkVariablePricing;
         if(!skipFrictionBuy && (price >= 10 || this.m_variablePricing))
         {
            UI.displayMessage(ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"paymentConfirmation",{"price":price.toString()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptBuyConfirmation,"socialCharityConfirmation",true,true);
         }
         else
         {
            switch(checkVariablePricing && this.m_showFlexibleContributionButton)
            {
               case true:
                  if(Global.player.canBuyCash(price))
                  {
                     Global.player.cash -= price;
                     Global.player.addGift(item.name);
                     buySuccess = true;
                     TransactionManager.addTransaction(new TGenericTransaction("SocialCharityService","buyVariableItem",null,[this.m_campaignName,item.name,price,this.m_statsCounter]));
                  }
                  break;
               case false:
                  buySuccess = Global.player.buyFarmItem(item,Currency.CASH,1,true,false,true,null,true);
                  if(buySuccess)
                  {
                     FarmStatsManager.count(this.m_statsCounter,"bought",item.name);
                  }
            }
            if(buySuccess)
            {
               Global.player.setSeenFlag(this.m_featureInteractionFlag,true);
               UI.displayPopup(new SocialCharityThankYouWindow(item.name,this.m_campaignName,this.m_statsCounter,this.m_assets["thankYouWindow"],this.m_dialogPrefix),false,"LemonAidStand",true);
            }
            else
            {
               FarmStatsManager.count(this.m_statsCounter,"buyFail",item.name);
            }
         }
      }
      
      private function onAcceptBuyConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.slotBuy(this.m_currentItem,this.m_variablePricing,true);
         }
      }
      
      protected function onHideIntroClick(event:Event = null) : void
      {
         Global.player.setSeenFlag(this.m_tutorialSeenFlag);
         this.hideIntroClip();
      }
      
      private function onShareLemonaidClick(event:Event = null) : void
      {
         this.shareFeed(this.m_shareSourceName);
         FarmStatsManager.count(this.m_statsCounter,"click_share");
         this.showSparkleClip();
         this.m_shareButton.enabled = false;
      }
      
      private function onLegalClick(event:Event) : void
      {
         var url:String = ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"ClickHereUrl");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function shareFeed(source:String) : void
      {
         FarmStatsManager.count("feed",this.m_statsCounter,source);
         TransactionManager.addTransaction(new TSocialCharityAction(this.postComplete,this.m_campaignName,source),true);
      }
      
      private function postComplete(result:Object) : void
      {
         var currentTime:int = 0;
         if(result.hasOwnProperty("postSuccessful") && result.postSuccessful == true)
         {
            Global.player.setSeenFlag(this.m_featureInteractionFlag);
            TransactionManager.addTransaction(new TGenericTransaction("SocialCharityService","applyFeedInteraction",null,[this.m_campaignName]));
            this.m_interacted = true;
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_lastShared = currentTime;
            Global.player.setFeatureLastShown(this.SOCIAL_CHARITY_SHARE_THROTTLE,currentTime,true);
            this.disableShareButton();
            FarmStatsManager.count(this.m_statsCounter,"shared_feed");
         }
         else if(this.m_shareButton)
         {
            this.m_shareButton.enabled = true;
         }
      }
      
      private function checkShareEnabled() : Boolean
      {
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return currentTime > this.m_lastShared + this.SHARE_THROTTLE;
      }
      
      private function showSparkleClip() : void
      {
         if(this.m_sparkle)
         {
            this.m_sparkle.visible = true;
            (this.m_sparkle.element as MovieClip).play();
         }
      }
      
      private function disableShareButton() : void
      {
         if(this.m_shareButton != null)
         {
            this.m_shareButton.text = ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"share_button2");
            this.m_shareButton.applyGrayOut = true;
            this.m_shareButton.enabled = false;
         }
         if(this.m_cooldownTF != null)
         {
            this.m_cooldownTF.visible = true;
            this.setCooldownText();
         }
      }
      
      private function setCooldownText() : void
      {
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var cooldown:int = (this.SHARE_THROTTLE - (currentTime - this.m_lastShared)) / FarmGameUtil.NUM_SECS_IN_HOUR;
         this.m_cooldownTF.text = ZLocUtils.getZLocString("Dialogs",this.m_dialogPrefix,DEFAULT_PREFIX,"share_cooldown",{"time":cooldown});
      }
      
      override public function close() : void
      {
         FarmStatsManager.count(this.m_statsCounter,"main_dialog","close");
         super.close();
      }
   }
}

