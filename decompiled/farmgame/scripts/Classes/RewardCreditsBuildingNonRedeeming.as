package Classes
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class RewardCreditsBuildingNonRedeeming extends RewardCreditsBuildingWithPresents
   {
      
      protected static const TOKEN_FILLED_METER:String = "FilledMeter";
      
      protected static const TOKEN_REDEEM:String = "redeem";
      
      private static const ARROW_X_OFFSET:int = 69;
      
      private static const ARROW_Y_OFFSET:int = -120;
      
      private static const DATE_NOT_SET:int = 0;
      
      private static const BEFORE_DATE:int = 1;
      
      private static const AFTER_DATE:int = 2;
      
      private var m_latestReward:String;
      
      private var m_rewardLink:String;
      
      private var m_isPlaced:Boolean = false;
      
      private var m_cacheBeforeOffboardDate:int = 0;
      
      public function RewardCreditsBuildingNonRedeeming(buildingType:String = null, featureName:String = null)
      {
         super(buildingType,featureName);
         m_displayDialogOnMeterBroken = false;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         this.m_isPlaced = true;
      }
      
      override protected function checkArrowIndicator() : void
      {
         var spr:Sprite = null;
         if(Boolean(this.isBeforeOffboardDate() && !m_showingArrow && !m_usingLoadingGraphic && !UI.isShowingPopup()) && Boolean(m_attachPosition) && !Global.worldManager.isVisiting())
         {
            spr = m_displayObject as Sprite;
            if(m_arrow == null && spr.numChildren > 0)
            {
               this.m_hideArrow = false;
               m_arrow = this.generateArrowIndicator();
               this.showStoragePresentsTabOnLoad = true;
               m_nullArrow = false;
               if(m_arrow != null)
               {
                  m_arrow.visible = true;
                  (m_displayObject as Sprite).addChild(m_arrow);
                  this.setArrowPosition();
                  m_showingArrow = true;
               }
            }
         }
      }
      
      override protected function setArrowPosition() : void
      {
         if(m_arrowPositionSet == false)
         {
            m_arrow.x = ARROW_X_OFFSET;
            m_arrow.y = ARROW_Y_OFFSET;
            m_arrowPositionSet = true;
         }
      }
      
      override protected function generateArrowIndicator() : DisplayObject
      {
         var result:DisplayObject = null;
         var openDate:String = null;
         var afterOpenGiftDate:Boolean = false;
         var offboardData:Array = null;
         var title:String = null;
         var text:String = null;
         var time:Number = NaN;
         var timeLeft:String = null;
         var iconPath:String = null;
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(getItemName());
         if(rawXML != null)
         {
            openDate = rawXML.elements("giftOpen").toString();
            afterOpenGiftDate = FarmGameUtil.checkStartDateGate(openDate);
            offboardData = getOffBoardingData();
            if(this.isBeforeOffboardDate())
            {
               title = "";
               text = "";
               if(afterOpenGiftDate)
               {
                  if(Boolean(offboardData) && Boolean(offboardData["date"]))
                  {
                     time = FarmGameUtil.synchronizedDateToNumber(offboardData["date"]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                     timeLeft = FarmGameUtil.getTimeLeftText(time);
                     text = timeLeft.split("left")[0] + ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_CollectGiftsBouncyText");
                  }
                  else
                  {
                     text = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_CollectGiftsBouncyText");
                  }
                  title = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_CollectGiftsBouncyTitle");
               }
               else
               {
                  time = FarmGameUtil.synchronizedDateToNumber(openDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  timeLeft = FarmGameUtil.getTimeLeftText(time);
                  text = timeLeft.split("left")[0] + ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_GatherGiftsBouncyText");
                  title = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_GatherGiftsBouncyTitle");
               }
               iconPath = Global.getAssetURL(getPresentIndicatorIconUrl());
               result = new ArrowIndicatorWindow(iconPath,title,text);
            }
         }
         return result;
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var count:int = 0;
         var localizedTotal:String = null;
         var maxCredits:int = 0;
         var delta:int = 0;
         var tooltip:String = "";
         if(this.isBeforeOffboardDate())
         {
            if(this.isGiftOpenMode())
            {
               tooltip = ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_TooltipGiftOpen");
            }
            else
            {
               count = int(this.getCurrentCredits());
               localizedTotal = this.m_creditsFeatureName + "_TooltipTotalGifts_Plural";
               if(count == 1)
               {
                  localizedTotal = this.m_creditsFeatureName + "_TooltipTotalGifts_Single";
               }
               tooltip += ZLocUtils.t("Dialogs",localizedTotal,{"quantity":count}) + "\n";
               maxCredits = int(m_creditsBuildingXml.@meterMaxCredits);
               delta = Math.max(0,maxCredits - count);
               tooltip += ZLocUtils.t("Dialogs",this.m_creditsFeatureName + "_TooltipMoreToEarn",{"quantity":delta});
            }
         }
         return tooltip;
      }
      
      override public function processCreditsGainedResult(result:Object) : Boolean
      {
         var isFeedPrompted:Boolean = false;
         if(Boolean(result != null) && Boolean(result.rewardUrl) && result.rewardType == TOKEN_FILLED_METER)
         {
            this.m_latestReward = result.rewardCode;
            this.m_rewardLink = result.rewardUrl;
            this.showMeterFilledFeedPrompt();
            isFeedPrompted = true;
         }
         else
         {
            isFeedPrompted = super.processCreditsGainedResult(result);
         }
         return isFeedPrompted;
      }
      
      override public function getShowWhatIsThis() : Boolean
      {
         return false;
      }
      
      protected function showMeterFilledFeedPrompt() : void
      {
         var farmItem:FarmItem = null;
         var message:String = null;
         var popup:GenericIconPopup = null;
         if(this.m_latestReward != null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_latestReward);
            message = ZLocUtils.t("Dialogs",m_creditsFeatureName + TOKEN_FILLED_METER);
            popup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,farmItem.icon);
            UI.displayPopup(popup,false);
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         }
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var farmItem:FarmItem = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT && this.m_latestReward != null)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_latestReward);
            bundleData = {
               "reward_link":this.m_rewardLink,
               "rewardItem":farmItem.friendlyTitle,
               "prize":farmItem.friendlyTitle,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardLink,
                  "src":farmItem.icon
               }]
            };
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_SHARE_CLICK_PHYLUM);
            GlobalEngine.socialNetwork.publishFeedStory(m_creditsFeatureName + TOKEN_FILLED_METER,bundleData,[],false);
         }
         else
         {
            FarmStatsManager.count("dialog",m_creditsFeatureName + "-" + TOKEN_REDEEM,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
         }
      }
      
      private function isGiftOpenMode() : Boolean
      {
         var openDate:String = null;
         var rawXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_creditsFeatureName);
         var isOpen:Boolean = false;
         if(rawXML != null)
         {
            openDate = rawXML.elements("giftOpen").toString();
            isOpen = FarmGameUtil.checkStartDateGate(openDate);
         }
         return isOpen;
      }
      
      private function isBeforeOffboardDate() : Boolean
      {
         var offboardData:Array = getOffBoardingData();
         if(Boolean(offboardData) && Boolean(offboardData["date"]))
         {
            return !FarmGameUtil.checkStartDateGate(offboardData["date"]);
         }
         return false;
      }
   }
}

