package Widgets.Windows.FeedTrough
{
   import Classes.Animal;
   import Classes.FeedTroughBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TGetMissedAnimalFriendReward;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeedTrough.FeedTroughMeterFrame;
   import Widgets.Frames.FeedTrough.FeedTroughSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FeedTroughWindow extends FarmWindow
   {
      
      private static const ANIMAL_FEED_TROUGH_WINDOW_KINGDOM:String = "home_dialog";
      
      private static const ASSET_URL:String = "assets/dialogs/FV_feedTrough.swf";
      
      public static const FAIL_FEED_URL:String = "gifts_send.php?action=singleGiftRecipient&ref=animalFeedTroughMissedAnimal&gift=animalfeedtrough_feed&titlePrefix=animalFeedTrough&giftRecipient=";
      
      public static const FAIL_FEED_IMG:String = "assets/newsfeed/feedtrough_fail.png";
      
      private static const ASK_FOR_FEED_AC_KEY:String = "animalFeedTroughAskForMore";
      
      private static const ASK_FOR_FEED_DAILY_LIMIT:int = 3;
      
      private static const ZOOM_LEVEL:int = 4;
      
      private static var m_askForFeedDailyCount:int = Global.player.getIntervalActionCount(ASK_FOR_FEED_AC_KEY);
      
      private const PROPERTIES_FILE:String = "Dialogs";
      
      private const ANIMAL_BOX_WIDTH:Number = 182.5;
      
      private const ANIMAL_BOX_HEIGHT:Number = 187.5;
      
      private const ANIMAL_SCALE:Number = 2.7;
      
      private var m_type:int;
      
      private var m_askFeedButton:FarmAnimatedTextButton = null;
      
      private var m_buyFeedButton:FarmAnimatedTextButton = null;
      
      private var m_askButtonEnabled:Boolean = true;
      
      private var m_animal:FarmItem;
      
      private var m_building:FeedTroughBuilding;
      
      private var m_animalLoader:Loader = null;
      
      private var m_meterFrame:FeedTroughMeterFrame = null;
      
      public function FeedTroughWindow(building:FeedTroughBuilding, windowType:int = 0, animal:FarmItem = null)
      {
         super(ASSET_URL);
         this.m_building = building;
         this.m_type = windowType;
         this.m_animal = animal;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(this.PROPERTIES_FILE,"TroughDialogTitle")));
         addWidget(new ZwFrame(m_window.titleBar_mc));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(this.PROPERTIES_FILE,"HowDoesThisWork"),this.onWhatIsThis));
         addWidget(new ZwFrame(m_window.bgInterior_mc));
         switch(this.m_type)
         {
            case FeedTroughBuilding.TYPE_ANIMAL_SUCCESS:
               this.setUpSuccess();
               break;
            case FeedTroughBuilding.TYPE_ANIMAL_FAILURE:
               this.setUpFailure();
               break;
            case FeedTroughBuilding.TYPE_ANIMAL_NOT_PRESENT:
            default:
               this.setUpMeterBulletin();
         }
         FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_WINDOW_KINGDOM,"open");
      }
      
      override protected function release() : void
      {
         if(this.m_animalLoader != null)
         {
            this.m_animalLoader.unload();
            this.m_animalLoader = null;
         }
         this.m_meterFrame = null;
         super.release();
      }
      
      private function setUpMeterBulletin() : void
      {
         addWidget(new ZwFrame(m_window.darken_mc));
         this.m_askFeedButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t(this.PROPERTIES_FILE,"AskFeed"),this.onAskForFeed);
         if(m_askForFeedDailyCount >= ASK_FOR_FEED_DAILY_LIMIT)
         {
            this.m_askFeedButton.enabled = false;
         }
         addWidget(this.m_askFeedButton);
         this.m_buyFeedButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t(this.PROPERTIES_FILE,"BuyFeed"),this.onBuyFeed);
         if(this.m_building.isFull() == true)
         {
            this.m_buyFeedButton.enabled = false;
         }
         addWidget(this.m_buyFeedButton);
         this.m_meterFrame = new FeedTroughMeterFrame(m_window.siloMeter_mc,this.m_building,this.m_building.getCreditsFeatureName());
         if(this.m_building.getCurrentCredits() == this.m_building.capacity)
         {
            this.addReadyOverlay();
         }
         else
         {
            addWidget(this.m_meterFrame);
         }
         addWidget(new FeedTroughSlotContainerFrame(m_window.bulletinBoard_mc,this.m_building));
      }
      
      private function addReadyOverlay() : void
      {
         var overlay:ZwFrame = new ZwFrame(m_window.readyTakeover_mc);
         overlay.addWidget(new ZwTextField(m_window.readyTakeover_mc.ready_tf,ZLocUtils.t("Dialogs","FeedTroughReady")));
         overlay.addWidget(new ZwTextField(m_window.readyTakeover_mc.generic_tf,ZLocUtils.t("Dialogs","FeedTroughReadyText")));
         addWidget(overlay);
      }
      
      private function setUpSuccess() : void
      {
         var animalDisplayObject:ObjectPreviewFrame = null;
         animalDisplayObject = new ObjectPreviewFrame(m_window.animal_mc,this.m_animal,null,[ZOOM_LEVEL],[this.ANIMAL_BOX_WIDTH],Animal.STATE_FRONT_IDLE,"");
         animalDisplayObject.y += this.ANIMAL_BOX_HEIGHT / 2;
         addWidget(animalDisplayObject);
         m_window.animal_mc.visible = true;
         this.setUpPopup(m_window.successPopup_mc);
      }
      
      private function setUpFailure() : void
      {
         addWidget(new ZwFrame(m_window.pawPrints_mc));
         this.setUpPopup(m_window.failPopup_mc);
      }
      
      private function setUpPopup(element:MovieClip) : void
      {
         var bodyText:String = "";
         var shareCallback:Function = null;
         switch(this.m_type)
         {
            case FeedTroughBuilding.TYPE_ANIMAL_FAILURE:
               bodyText = ZLocUtils.t(this.PROPERTIES_FILE,"MissedAnimal",{"quantity":Global.farmGameSettingsManager.getInt("animalFeedTroughPenalty",2)});
               shareCallback = this.onShareFailure;
               FarmStatsManager.count("dialog","animal_trough-missed_animal","View");
               break;
            case FeedTroughBuilding.TYPE_ANIMAL_SUCCESS:
               bodyText = ZLocUtils.t(this.PROPERTIES_FILE,"FoundAnimal",{"hungryitem":ZLocUtils.tk_pk(this.m_animal.friendlyName)});
               shareCallback = this.onShare;
               FarmStatsManager.count("dialog","animal_trough-found_animal","View");
         }
         var popupFrame:ZwFrame = new ZwFrame(element);
         popupFrame.addWidget(new ZwTextField(element.generic_tf,bodyText));
         popupFrame.addWidget(new FarmAnimatedTextButton(element.share_bt,ZLocUtils.t(this.PROPERTIES_FILE,"ShareButton"),shareCallback));
         popupFrame.addWidget(new FarmAnimatedTextButton(element.cancel_bt,ZLocUtils.t(this.PROPERTIES_FILE,"NoThanks"),this.onNoThanks));
         addWidget(popupFrame);
      }
      
      private function onWhatIsThis(event:Event) : void
      {
         this.displayWhatIsThis();
      }
      
      private function onShare(event:Event) : void
      {
         FarmStatsManager.count("dialog","animal_trough-found_animal","Share");
         var params:Object = {};
         params.animalName = this.m_animal.friendlyName;
         params.images = [{
            "src":this.m_animal.icon,
            "href":"{SN_APP_URL}" + this.m_building.rewardLink
         }];
         params.reward_link = this.m_building.rewardLink;
         GlobalEngine.socialNetwork.publishFeedStory("FeedTroughBuildingShareAnimal",params,[],false);
         this.onClose(event);
      }
      
      private function onShareFailure(event:Event) : void
      {
         FarmStatsManager.count("dialog","animal_trough-missed_animal","Share");
         TransactionManager.addTransaction(new TGetMissedAnimalFriendReward(this.m_building),true);
         this.onClose(event);
      }
      
      private function onNoThanks(event:Event) : void
      {
         switch(this.m_type)
         {
            case FeedTroughBuilding.TYPE_ANIMAL_SUCCESS:
               FarmStatsManager.count("dialog","animal_trough-found_animal","No Thanks");
               break;
            case FeedTroughBuilding.TYPE_ANIMAL_FAILURE:
               FarmStatsManager.count("dialog","animal_trough-missed_animal","No Thanks");
         }
         if(this.m_building.rewardLink != null)
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_building.rewardLink]),true);
         }
         this.onClose(event);
      }
      
      private function onBuyFeed(event:Event) : void
      {
         FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_WINDOW_KINGDOM,"buy_feed");
         UI.displayMiniMarketDialog(FeedTroughBuilding.MINI_MARKET_ITEMS,"feedTroughWindowBuyFeed","animal",this.onCloseMiniMarket,false);
      }
      
      private function onAskForFeed(event:Event) : void
      {
         FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_WINDOW_KINGDOM,"ask_for_feed");
         this.m_building.askForAnimalFeed();
         ++m_askForFeedDailyCount;
         if(m_askForFeedDailyCount >= ASK_FOR_FEED_DAILY_LIMIT)
         {
            this.m_askFeedButton.enabled = false;
         }
      }
      
      private function onCloseMiniMarket(isBuy:Boolean) : void
      {
         if(this.m_building.isFull() == true)
         {
            this.addReadyOverlay();
            this.m_meterFrame.visible = false;
            this.m_buyFeedButton.enabled = false;
         }
         else
         {
            this.m_meterFrame.refreshMeter();
         }
      }
      
      public function displayWhatIsThis() : void
      {
         var dialog:FeedTroughOnboardingWindow = new FeedTroughOnboardingWindow();
         UI.displayPopup(dialog,false,"whatIsThisPopup",true);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_WINDOW_KINGDOM,"close");
         super.onClose(event);
      }
   }
}

