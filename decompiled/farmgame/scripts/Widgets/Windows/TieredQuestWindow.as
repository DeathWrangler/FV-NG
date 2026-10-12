package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Frames.TieredQuestStageIndicator;
   import Widgets.Frames.TieredQuestTaskFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TieredQuestWindow extends FarmWindow
   {
      
      public static const QUEST_PROGRESS_UNIQUE_NAME:String = "tieredQuestWindow";
      
      private static const TUTORIAL_PREFIX_URL:String = "assets/dialogs/FV_TieredQuestFall_2014/FV_TieredQuestFall_2014";
      
      private static const MAPTRIGGER_ITEM_NAME:String = "tieredquest2014";
      
      private var m_currentStageQuest:FarmQuest;
      
      private var m_chainOrder:Array;
      
      private var m_stageNumber:int;
      
      private var m_title:FarmTextField = null;
      
      private var m_description:FarmTextField = null;
      
      private var m_timeLeft:FarmTextField = null;
      
      private var m_whatIsThisButton:FarmAnimatedButton;
      
      private var m_completeNowBt:FarmAnimatedCashButton;
      
      private var m_taskPanelVector:Vector.<TieredQuestTaskFrame> = new Vector.<TieredQuestTaskFrame>();
      
      private var m_finalrewardIcon:FarmIcon;
      
      private var m_finalRewardTf:FarmTextField;
      
      private var m_finalRewardItemName:String;
      
      private var m_questRewardsItemCodes:Array;
      
      private var m_stageIndicators:Vector.<TieredQuestStageIndicator> = new Vector.<TieredQuestStageIndicator>();
      
      public function TieredQuestWindow(chainOrder:Array, currentStageQuest:FarmQuest, stage:int, windowAssetRelUrl:String, itemName:String, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         this.m_currentStageQuest = currentStageQuest;
         this.m_stageNumber = stage;
         this.m_chainOrder = chainOrder;
         this.m_finalRewardItemName = itemName;
      }
      
      override protected function postLoadComplete() : void
      {
         var buildableMC:MovieClip = null;
         var questTaskFrame:TieredQuestTaskFrame = null;
         var rewardMC:MovieClip = null;
         var rewardItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.title_tf)
         {
            this.m_title = addWidget(new FarmTextField(m_window.title_tf)) as FarmTextField;
         }
         if(m_window.description_tf)
         {
            this.m_description = addWidget(new FarmTextField(m_window.description_tf)) as FarmTextField;
         }
         if(m_window.timer_tf)
         {
            this.m_timeLeft = addWidget(new FarmTextField(m_window.timer_tf)) as FarmTextField;
         }
         if(m_window.whatisthis_mc)
         {
            this.m_whatIsThisButton = addWidget(new FarmAnimatedButton(m_window.getChildByName("whatisthis_mc") as MovieClip,this.onWhatIsThisClick)) as FarmAnimatedButton;
         }
         if(m_window.buildable_mc)
         {
            buildableMC = m_window.buildable_mc as MovieClip;
            if(m_window.buildable_mc.buy_bt)
            {
               this.m_completeNowBt = addWidget(new FarmAnimatedCashButton(m_window.buildable_mc.buy_bt,"","",this.onCompleteNow)) as FarmAnimatedCashButton;
            }
            if(m_window.buildable_mc.giftPanel1)
            {
               questTaskFrame = addWidget(new TieredQuestTaskFrame(m_window.buildable_mc.giftPanel1,this.m_currentStageQuest,0,this)) as TieredQuestTaskFrame;
               this.m_taskPanelVector.push(questTaskFrame);
            }
            if(m_window.buildable_mc.giftPanel2)
            {
               questTaskFrame = addWidget(new TieredQuestTaskFrame(m_window.buildable_mc.giftPanel2,this.m_currentStageQuest,1,this)) as TieredQuestTaskFrame;
               this.m_taskPanelVector.push(questTaskFrame);
            }
            if(m_window.buildable_mc.giftPanel3)
            {
               questTaskFrame = addWidget(new TieredQuestTaskFrame(m_window.buildable_mc.giftPanel3,this.m_currentStageQuest,2,this)) as TieredQuestTaskFrame;
               this.m_taskPanelVector.push(questTaskFrame);
            }
            buildableMC.visible = true;
         }
         if(m_window.reward_mc)
         {
            rewardMC = m_window.reward_mc as MovieClip;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_finalRewardItemName);
            if(m_window.reward_mc.icon_mc)
            {
               this.m_finalrewardIcon = addWidget(new FarmIcon(m_window.reward_mc.icon_mc,rewardItem.iconUrl)) as FarmIcon;
            }
            if(m_window.reward_mc.sendMaterials_tf)
            {
               this.m_finalRewardTf = addWidget(new FarmTextField(m_window.reward_mc.sendMaterials_tf,ZLocUtils.t("Dialogs","TieredQuest_finalRewardText"))) as FarmTextField;
            }
            rewardMC.visible = true;
         }
         this.m_questRewardsItemCodes = this.buildQuestRewardItemCodes();
         this.addProgressWidgets();
         this.refreshUI();
      }
      
      private function addProgressWidgets() : void
      {
         var stageItem:FarmItem = null;
         for(var i:int = 0; i < this.m_chainOrder.length; i++)
         {
            stageItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_questRewardsItemCodes[i]);
            if(m_window.hasOwnProperty("stage" + (i + 1) + "_indicator_mc"))
            {
               addWidget(new TieredQuestStageIndicator(m_window.getChildByName("stage" + (i + 1) + "_indicator_mc"),i + 1,stageItem,this));
            }
         }
      }
      
      private function buildQuestRewardItemCodes() : Array
      {
         var questRewards:Vector.<Object> = null;
         var farmReward:Object = null;
         var questRewardsItemCodes:Array = new Array();
         var questName:String = "";
         var quest:FarmQuest = null;
         for(var i:int = 0; i < this.m_chainOrder.length; i++)
         {
            questName = this.m_chainOrder[i];
            quest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
            if(quest)
            {
               questRewards = quest.farmRewards;
               if(questRewards)
               {
                  for each(farmReward in questRewards)
                  {
                     if(farmReward.type == QuestConstants.REWARD_GRANT_ITEM)
                     {
                        questRewardsItemCodes.push(farmReward.value);
                     }
                  }
               }
            }
         }
         return questRewardsItemCodes;
      }
      
      private function refreshStageIndicators() : void
      {
         var stageIndicator:TieredQuestStageIndicator = null;
         for(var currentStageNumber:int = 1; currentStageNumber <= this.m_chainOrder.length; currentStageNumber++)
         {
            stageIndicator = getWidget(m_window["stage" + currentStageNumber + "_indicator_mc"]) as TieredQuestStageIndicator;
            if(stageIndicator)
            {
               stageIndicator.locked = false;
               stageIndicator.complete = false;
               stageIndicator.currentTaskHighlighted = false;
               if(currentStageNumber > this.m_stageNumber)
               {
                  stageIndicator.locked = true;
               }
               else if(currentStageNumber < this.m_stageNumber)
               {
                  stageIndicator.complete = true;
               }
               else
               {
                  stageIndicator.currentTaskHighlighted = true;
               }
            }
         }
      }
      
      private function onWhatIsThisClick(ev:Event = null) : void
      {
         TutorialUI.displayTutorialWindowForItem(MAPTRIGGER_ITEM_NAME,"Items:" + MAPTRIGGER_ITEM_NAME + "_friendlyName",TUTORIAL_PREFIX_URL);
      }
      
      private function onCompleteNow(ev:Event = null) : void
      {
         FarmQuestManager.showSkipQuestConfirmation(this.m_currentStageQuest.getSkipQuestCashCost(),QUEST_PROGRESS_UNIQUE_NAME,this.onAcceptSkipEntireQuest);
      }
      
      private function onAcceptSkipEntireQuest(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.m_currentStageQuest.skipQuest();
            close();
         }
      }
      
      public function refreshUI() : void
      {
         var stageItem:FarmItem = null;
         var timeLeftSeconds:Number = NaN;
         var timeLeftString:String = null;
         var i:int = 0;
         if(m_window != null)
         {
            this.m_title.text = ZLocUtils.t("Quests",this.m_currentStageQuest.chain + "_Title");
            stageItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_questRewardsItemCodes[this.m_stageNumber - 1]);
            this.m_description.text = ZLocUtils.t("Quests","trbquests_Body",{"itemName":stageItem.friendlyTitle});
            timeLeftSeconds = (this.m_currentStageQuest.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeftSeconds < 0)
            {
               timeLeftSeconds = 0;
            }
            timeLeftString = FarmGameUtil.toFriendlyTime(timeLeftSeconds);
            this.m_timeLeft.text = ZLocUtils.t("Dialogs","MultiStageQuestGeneric_TimeLeft",{"timeLeft":timeLeftString});
            this.m_completeNowBt.setGenericText(ZLocUtils.t("Dialogs","FeatureBuildingCompleteNow"));
            this.m_completeNowBt.setAmountText(this.m_currentStageQuest.getSkipQuestCashCost().toString());
            for(i = 0; i < this.m_taskPanelVector.length; i++)
            {
               this.m_taskPanelVector[i].refreshUI();
            }
            this.refreshStageIndicators();
         }
      }
   }
}

