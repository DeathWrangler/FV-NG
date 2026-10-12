package Widgets.Windows
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.MFSRequestManager;
   import Managers.TrickOrTreatManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CreditsBuilding.LeaderBoardScrollFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TrickOrTreatWindow extends FarmWindow
   {
      
      private static var DIALOG_ASSET:String = "assets/dialogs/FV_trickortreat.swf";
      
      private static var DIALOG_HEIGHT:Number = 623;
      
      private static const EXPIRE_TIMER_DAYS:int = 6;
      
      private static var FEATURE_NAME:String = "trickortreat";
      
      private var m_rewardsFrame:ZwFrame;
      
      private var m_trickCount:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_statsSubcounter:String;
      
      public function TrickOrTreatWindow()
      {
         super(DIALOG_ASSET);
         TrickOrTreatManager.instance.trickOrTreatDialog = this;
         this.m_statsSubcounter = !Global.player.getSeenFlag(TrickOrTreatManager.instance.featureCreditName + LeaderBoardScrollFrame.FIRST_INTERACTION) ? " first_main_dialog" : "return_main_dialog";
      }
      
      override public function getDialogOffset() : Point
      {
         var heightOffset:Number = (this.height - DIALOG_HEIGHT) / 2;
         return new Point(0,heightOffset);
      }
      
      override public function close() : void
      {
         TrickOrTreatManager.instance.trickOrTreatDialog = null;
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"x_button");
         super.onClose(event);
      }
      
      override protected function postLoadComplete() : void
      {
         var totalTricks:Number = NaN;
         var timeRemaining:Array = null;
         var offBoardingTime:Number = NaN;
         var daysLeft:int = 0;
         var reward:String = null;
         var farmItem:FarmItem = null;
         var icon:FarmIcon = null;
         var remainingTricks:Number = NaN;
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"impression");
         var isOffBoarding:Boolean = TrickOrTreatManager.instance.isOffBoarding();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","TrickOrTreatTitle")));
         if(!TrickOrTreatManager.instance.isOffBoarding())
         {
            totalTricks = TrickOrTreatManager.instance.getTotalTricks();
            addWidget(this.m_trickCount = new ZwTextField(m_window.tricks_tf,totalTricks.toString()) as ZwTextField);
            addWidget(new ZwTextField(m_window.trickCountLabel_tf,ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "LicensesLabel")));
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "FeatureMessage")));
            timeRemaining = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getTimeRemaining();
            offBoardingTime = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getNumberConstant("offBoardingTime");
            if(timeRemaining[0] >= offBoardingTime && timeRemaining[0] - offBoardingTime < EXPIRE_TIMER_DAYS)
            {
               daysLeft = timeRemaining[0] - offBoardingTime;
               addWidget(new ZwBaseWidget(m_window.expiretimer_mc));
               addWidget(new ZwTextField(m_window.expiretimer_mc.timer_tf,ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "ExpireTimer",{"daysLeft":daysLeft})));
            }
         }
         else
         {
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "FeatureEndMessage")));
            addWidget(new ZwBaseWidget(m_window.expiretimer_mc));
            addWidget(new ZwTextField(m_window.expiretimer_mc.timer_tf,ZLocUtils.t("Dialogs","TheEnd")));
         }
         var askButton:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.askFor_bt,ZLocUtils.t("Dialogs","wishingwell_AskButton"),this.onAskForMore);
         addWidget(askButton);
         askButton.enabled = !TrickOrTreatManager.instance.isOffBoarding();
         this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","UnwitherClock_Arrow_Days"),this.onBuyMore);
         this.m_buyButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "BuyTooltip")));
         addWidget(this.m_buyButton);
         this.m_buyButton.enabled = !TrickOrTreatManager.instance.isOffBoarding();
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.howDoesThisWorkClick,true));
         var castle1:ZwFrame = new ZwFrame(m_window.castleBackground_mc);
         addWidget(castle1);
         castle1.addWidget(new ZwBaseWidget(m_window.castleBackground_mc.batAnimation_mc));
         (m_window.castleBackground_mc.batAnimation_mc as MovieClip).play();
         this.m_rewardsFrame = new ZwFrame(m_window.mainPage_mc);
         addWidget(this.m_rewardsFrame);
         var rewardsArray:Array = TrickOrTreatManager.instance.getRewards();
         for(var i:Number = 0; i < rewardsArray.length; i++)
         {
            reward = rewardsArray[i]["name"];
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(reward);
            if(farmItem != null)
            {
               if(m_window.mainPage_mc["icon_" + i + "_mc"] != null && m_window.mainPage_mc["buy_" + i + "_mc"] != null && m_window.mainPage_mc["text_" + i + "_tf"] != null && m_window.mainPage_mc["price_" + i + "_tf"] != null)
               {
                  icon = new FarmIcon(m_window.mainPage_mc["icon_" + i + "_mc"],farmItem.icon);
                  icon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)));
                  icon.setIconSize(100,100);
                  this.m_rewardsFrame.addWidget(icon);
                  addWidget(new FarmAnimatedTextButton(m_window.mainPage_mc["buy_" + i + "_mc"],ZLocUtils.t("Dialogs","Buy"),this.onBuyPrize));
                  remainingTricks = Math.max(0,rewardsArray[i]["cost"] - Global.player.getFeatureCreditsReceived(TrickOrTreatManager.instance.featureCreditName));
                  if(remainingTricks > 0)
                  {
                     addWidget(new ZwTextField(m_window.mainPage_mc["text_" + i + "_tf"],ZLocUtils.t("Dialogs","TrickOrTreatBuyRewardText",{"count":remainingTricks})));
                  }
                  else
                  {
                     addWidget(new ZwTextField(m_window.mainPage_mc["text_" + i + "_tf"],"\n" + ZLocUtils.t("Dialogs","BuyNow")));
                  }
                  addWidget(new ZwTextField(m_window.mainPage_mc["price_" + i + "_tf"],rewardsArray[i]["cost"]));
               }
            }
         }
         addWidget(new LeaderBoardScrollFrame(m_window.leaderBoard_mc,m_window.leaderBoard_mc.friendsContainer_mc.leaderBoardSlot_mc,"trickortreat"));
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"what_is_this");
         TutorialUI.displayBundleTutorialWindow("Dialogs",TrickOrTreatManager.instance.featureCreditName,"assets/dialogs/4d_elements/TrickOrTreat/TrickOrTreat",false,null);
      }
      
      private function onImpulseBuyCancel(event:Event) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
         else
         {
            MT4DManager.getInstance().removeEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
         }
      }
      
      private function onBuyPrize(event:Event) : void
      {
         var pattern:String = "\\d+";
         var regExp:RegExp = new RegExp(pattern,event.target.name as String);
         var rewardIndex:int = regExp.exec(event.target.name as String);
         var rewardsArray:Array = TrickOrTreatManager.instance.getRewards();
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardsArray[rewardIndex]["name"]);
         if(Global.player.canBuyCash(farmItem.cash,false))
         {
            FarmStatsManager.count("fv_cash_buy",farmItem.type,farmItem.name,farmItem.cash.toString());
            farmItem.onBuy(farmItem.name);
            this.close();
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",rewardsArray[rewardIndex]["cost"],farmItem.type);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
            }
         }
      }
      
      private function onAskForMore(event:Event) : void
      {
         FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"ask_for_tricks");
         var featureLicenseItemName:String = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicenseItem");
         FarmStatsManager.count("request","request_more",TrickOrTreatManager.instance.featureCreditName,featureLicenseItemName,"",Global.worldManager.currentWorldType);
         MFSRequestManager.getInstance().makeAskItemsRequest(TrickOrTreatManager.instance.featureCreditName,featureLicenseItemName);
      }
      
      public function updateLicensesText() : void
      {
         if(this.m_trickCount)
         {
            this.m_trickCount.text = TrickOrTreatManager.instance.getTotalTricks().toString();
         }
      }
      
      private function onBuyMore(event:Event) : void
      {
         var featureLicenseItemPack:String = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicensePack");
         var packItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(featureLicenseItemPack);
         var mr:MapResource = new MapResource(featureLicenseItemPack);
         if(Global.player.canBuyCash(packItem.cash,false))
         {
            FarmStatsManager.count("fv_cash_buy",packItem.type,packItem.name,packItem.cash.toString());
            this.m_buyButton.enabled = false;
            TransactionManager.addTransaction(new TBuyItemPutGiftbox(packItem,Currency.CASH,1,false,true,function(result:Object):void
            {
               var licenseItem:* = undefined;
               var giftCount:* = undefined;
               var i:* = undefined;
               if(result)
               {
                  licenseItem = Global.farmGameSettingsManager.getFarmItemByName(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getStringConstant("featureCreditLicenseItem"));
                  giftCount = Global.player.getGiftCountForItem(licenseItem.name);
                  for(i = 0; i < giftCount; i++)
                  {
                     licenseItem.onUse(0,{
                        "isGift":false,
                        "allowReshopping":false
                     });
                     Global.player.removeGift(null,licenseItem.name);
                  }
                  if(m_buyButton.element != null)
                  {
                     m_buyButton.enabled = true;
                  }
                  TrickOrTreatManager.instance.updateTotalTrickLicenses();
               }
            }),true);
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",packItem.cash,packItem.type);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
            }
         }
      }
   }
}

