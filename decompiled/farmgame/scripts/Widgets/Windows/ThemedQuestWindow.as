package Widgets.Windows
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.Quests.QuestProgressDialog;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.ThemedQuestManager;
   import Transactions.Quests.TUserTaskSeen;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Frames.ThemedQuestPieceSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.ThemedQuest.ThemedQuestSelectorSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class ThemedQuestWindow extends FarmWindow
   {
      
      public static const PUZZLE_FEATURE:String = "puzzleFeature";
      
      public static const PUZZLE_BUILDING:String = "PuzzleThemedQuestBuilding";
      
      private var m_featureName:String;
      
      private var m_currentQuest:FarmQuest;
      
      private var m_quests:Array = ThemedQuestManager.instance.getQuestsForFeature(this.m_featureName);
      
      private var m_pieceSlotFrames:Object;
      
      private var m_questSelectorSlot:ThemedQuestSelectorSlot;
      
      private var m_completePuzzleButton:FarmAnimatedCashButton;
      
      private var m_playAgain:FarmAnimatedTextButton;
      
      private var m_claimUberPrize:FarmAnimatedTextButton;
      
      private var m_backgroundImage:FarmIcon;
      
      private var m_holdOffShowingPlayAgain:Boolean = false;
      
      private var m_uberQuest:FarmQuest = ThemedQuestManager.instance.getUberQuestForFeature(this.m_featureName);
      
      private const BG_WIDTH:Number = 494.95;
      
      private const BG_HEIGHT:Number = 361.75;
      
      public function ThemedQuestWindow(featureName:String)
      {
         this.m_featureName = featureName;
         var asset:String = ThemedQuestManager.instance.getWindowAssetforFeatureName(this.m_featureName);
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("header_tf"))
         {
            addWidget(new FarmTextField(m_window.header_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_header")));
         }
         if(m_window.hasOwnProperty("subHeader_mc"))
         {
            addWidget(new FarmTextField(m_window.subHeader_mc,ZLocUtils.t("Dialogs",this.m_featureName + "_subHeader")));
         }
         if(m_window.hasOwnProperty("moreInfo_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("quests_mc"))
         {
            addWidget(new GenericSlotContainerFrame(m_window.quests_mc,ThemedQuestSelectorSlot,this.m_quests,this));
         }
         if(m_window.hasOwnProperty("completeNow_bt"))
         {
            addWidget(this.m_completePuzzleButton = new FarmAnimatedCashButton(m_window.completeNow_bt,ZLocUtils.t("Dialogs","CompleteNowCamel"),"0",this.onSkipEntireQuestButtonPress));
            this.setCompleteNowButtonVisibility();
         }
         if(m_window.hasOwnProperty("playagain_bt"))
         {
            addWidget(this.m_playAgain = new FarmAnimatedTextButton(m_window.playagain_bt,ZLocUtils.t("Dialogs","PlayAgain"),this.onPlayAgain));
            this.m_playAgain.visible = false;
         }
         if(m_window.hasOwnProperty("claimBonus_bt"))
         {
            addWidget(this.m_claimUberPrize = new FarmAnimatedTextButton(m_window.claimBonus_bt,ZLocUtils.t("Dialogs","Claim"),this.onClaimUberPrize));
            this.m_claimUberPrize.visible = false;
         }
         this.m_pieceSlotFrames = {};
         var taskIndex:int = 1;
         var taskWidgetName:String = ThemedQuestManager.INSTANCE_PREFIX + taskIndex + ThemedQuestManager.INSTANCE_POSTFIX;
         while(m_window[taskWidgetName])
         {
            this.m_pieceSlotFrames[taskWidgetName] = addWidget(new ThemedQuestPieceSlotFrame(m_window[taskWidgetName],this),false);
            taskIndex++;
            taskWidgetName = ThemedQuestManager.INSTANCE_PREFIX + taskIndex + ThemedQuestManager.INSTANCE_POSTFIX;
         }
         if(m_window.hasOwnProperty("background_mc"))
         {
            addWidget(this.m_backgroundImage = new FarmIcon(m_window.background_mc));
         }
         if(this.m_quests.length > 0)
         {
            this.m_currentQuest = this.m_quests[0];
            this.setQuest(this.m_currentQuest);
         }
         var lastClickedTimeStamp:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         Global.player.setFeatureLastShown(PUZZLE_FEATURE,lastClickedTimeStamp,true);
         Global.player.setSeenSessionFlag(PUZZLE_FEATURE);
         var firstTimeSeenFlag:String = this.m_featureName + "_themedQuestWIT";
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.howDoesThisWorkClick(null);
            Global.player.setSeenFlag(firstTimeSeenFlag);
         }
         StatsManager.count("fv_puzz_house","puzzle_house_building","look_inside");
      }
      
      private function setCompleteNowButtonVisibility(visible:Boolean = false) : void
      {
         if(this.m_completePuzzleButton)
         {
            this.m_completePuzzleButton.visible = visible;
         }
      }
      
      private function onSkipEntireQuestButtonPress(event:Event) : void
      {
         FarmQuestManager.showSkipQuestConfirmation(this.m_currentQuest.getSkipQuestCashCost(),QuestProgressDialog.QUEST_PROGRESS_UNIQUE_NAME,this.onAcceptSkipEntireQuest);
      }
      
      private function onAcceptSkipEntireQuest(event:GenericPopupEvent) : void
      {
         var skipQuestCash:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            skipQuestCash = this.m_currentQuest.getSkipQuestCashCost().toString();
            if(this.m_currentQuest.skipQuest())
            {
               this.refreshPieces();
               this.showQuestCompleteDialog();
               StatsManager.count("fv_cash_buy","fv_puzz_house","prize_puzzhouse",skipQuestCash,"entire_puzzle");
            }
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         TutorialUI.displayBundleTutorialWindow("Dialogs",this.m_featureName,"assets/dialogs/FV_Support/FV_themedQuest_puzzle/" + this.m_featureName);
      }
      
      public function setQuest(quest:FarmQuest, selectorSlot:ThemedQuestSelectorSlot = null) : void
      {
         this.m_currentQuest = quest;
         if(this.m_questSelectorSlot)
         {
            this.m_questSelectorSlot.deselect();
         }
         this.m_questSelectorSlot = selectorSlot;
         this.refreshPieces();
         StatsManager.count("fv_puzz_house","dialog","view",this.m_currentQuest.name);
      }
      
      private function refreshPieces() : void
      {
         var slotFrame:ThemedQuestPieceSlotFrame = null;
         var backgroundImageUrl:String = null;
         var slotFrame2:ThemedQuestPieceSlotFrame = null;
         this.conditionallyShowClaimUberButton();
         if(this.m_playAgain)
         {
            this.m_playAgain.visible = false;
         }
         this.setCompleteNowButtonVisibility(false);
         for each(slotFrame in this.m_pieceSlotFrames)
         {
            slotFrame.visible = false;
         }
         backgroundImageUrl = ThemedQuestManager.instance.getBackgroundForFeatureQuest(this.m_featureName,this.m_currentQuest.name);
         if(Boolean(this.m_backgroundImage) && Boolean(backgroundImageUrl))
         {
            this.m_backgroundImage.loadIcon(Global.getAssetURL(backgroundImageUrl));
            this.m_backgroundImage.setIconHeight(this.BG_HEIGHT);
            this.m_backgroundImage.setIconWidth(this.BG_WIDTH);
         }
         var instanceName:String = ThemedQuestManager.getInstanceNameForActiveQuest(this.m_currentQuest.name);
         var isQuestActive:Boolean = FarmQuestManager.getInstance().isQuestActive(this.m_currentQuest.name);
         if(Boolean(instanceName) && isQuestActive)
         {
            slotFrame2 = this.m_pieceSlotFrames[instanceName] as ThemedQuestPieceSlotFrame;
            if(slotFrame2)
            {
               slotFrame2.setQuest(this.m_currentQuest);
               slotFrame2.visible = true;
            }
            if(this.m_completePuzzleButton)
            {
               this.setCompleteNowButtonVisibility(true);
               this.m_completePuzzleButton.setAmountText(this.m_currentQuest.getSkipQuestCashCost().toString());
            }
         }
         else
         {
            this.m_playAgain.visible = !this.m_holdOffShowingPlayAgain && this.hasCurrentThemedQuestBeenCompleted();
         }
      }
      
      override public function close() : void
      {
         super.close();
         StatsManager.count("fv_puzz_house","toaster_puzzhouse","close");
         Global.player.setSeenSessionFlag(PUZZLE_FEATURE,false);
      }
      
      public function hasCurrentThemedQuestBeenCompleted(farmQuest:FarmQuest = null) : Boolean
      {
         var questToCheck:FarmQuest = farmQuest ? farmQuest : this.m_currentQuest;
         return FarmQuestManager.getInstance().hasReplayableQuestBeenCompleted(questToCheck.name) || FarmQuestManager.getInstance().isQuestComplete(questToCheck.name);
      }
      
      private function conditionallyShowClaimUberButton() : void
      {
         if(FarmQuestManager.getInstance().isQuestActive(this.m_uberQuest.name))
         {
            this.m_claimUberPrize.visible = true;
         }
      }
      
      public function refreshSkipPrice() : void
      {
         if(Boolean(this.m_completePuzzleButton) && this.m_completePuzzleButton.visible)
         {
            this.m_completePuzzleButton.setAmountText(this.m_currentQuest.getSkipQuestCashCost().toString());
         }
      }
      
      private function onPlayAgain(event:Event) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("FarmQuestService","userResetQuestChapter",this.generateOnServerReply(this.m_currentQuest),[this.m_currentQuest.name]),true);
         this.m_playAgain.visible = false;
         this.m_holdOffShowingPlayAgain = true;
      }
      
      private function onClaimUberPrize(event:Event) : void
      {
         if(this.m_uberQuest.isViewDialogQuest())
         {
            TransactionManager.addTransaction(new TUserTaskSeen(this.m_uberQuest.name));
            this.showQuestCompleteDialog(this.m_uberQuest);
         }
      }
      
      private function generateOnServerReply(quest:FarmQuest) : Function
      {
         return function(result:Object):void
         {
            FarmQuestManager.getInstance().onResetLastCompletedQuestChapter(quest);
            m_holdOffShowingPlayAgain = false;
            setQuest(quest);
         };
      }
      
      public function conditionallyShowQuestCompleteDialog() : void
      {
         if(this.m_currentQuest.progress == 1)
         {
            this.showQuestCompleteDialog();
         }
      }
      
      private function showQuestCompleteDialog(farmQuest:FarmQuest = null) : void
      {
         this.setCompleteNowButtonVisibility(false);
         if(this.m_claimUberPrize)
         {
            this.m_claimUberPrize.visible = false;
         }
         if(this.m_questSelectorSlot)
         {
            this.m_questSelectorSlot.showQuestReward();
         }
         var questToShowRewardFor:FarmQuest = farmQuest ? farmQuest : this.m_currentQuest;
         var rewardPopup:ThemedQuestRewardWindow = new ThemedQuestRewardWindow(this.m_featureName,questToShowRewardFor);
         UI.displayPopup(rewardPopup,false);
         this.m_playAgain.visible = true;
      }
      
      public function getCurrentFeatureName() : String
      {
         return this.m_featureName;
      }
   }
}

