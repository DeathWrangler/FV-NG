package Widgets.Windows
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmRunQuestManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunQuestTaskFrame;
   import Widgets.Frames.FarmRunQuestWorldFrame;
   import Widgets.Frames.FarmRunQuests.FarmRunQuestsLeaderboardUpperFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunQuestWindow extends FarmWindow
   {
      
      public static var m_currentDisplayedWorldNum:int = 1;
      
      protected var m_title:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private var m_npc:MovieClip = new MovieClip();
      
      private var m_Tutorial:MovieClip = new MovieClip();
      
      private var m_nextTutorialStage:uint = 1;
      
      private var m_worldOne:MovieClip = new MovieClip();
      
      private var m_worldTwo:MovieClip = new MovieClip();
      
      private var m_worldThree:MovieClip = new MovieClip();
      
      private var m_farmRunQuestWorld1Frame:FarmRunQuestWorldFrame = null;
      
      private var m_farmRunQuestWorld2Frame:FarmRunQuestWorldFrame = null;
      
      private var m_farmRunQuestWorld3Frame:FarmRunQuestWorldFrame = null;
      
      private var m_LeaderboardWindow:MovieClip = new MovieClip();
      
      private var m_farmRunLeaderboardFrame:FarmRunQuestsLeaderboardUpperFrame = null;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_leaderboardButton:FarmAnimatedTextButton;
      
      private var m_farmRunQuestTaskFrame:FarmRunQuestTaskFrame = null;
      
      private var m_quest:MovieClip = new MovieClip();
      
      private var m_finalReward:MovieClip = new MovieClip();
      
      private var m_completeIcon1:MovieClip;
      
      private var m_completeIcon2:MovieClip;
      
      private var m_featureName:String = "FarmRunQuests";
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DreamCatcherTrail_2015.swf";
      
      public const HAS_TUTORIAL_SEEN:String = "has_tutorial_seen";
      
      private var m_npcText:ZwTextField;
      
      public function FarmRunQuestWindow()
      {
         super(this.ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var rank_tf:String = null;
         var leaderboardFriendList:Array = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","ofquests-01_Title")));
         }
         if(m_window.hasOwnProperty("description_tf"))
         {
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","ofquests-01_SubTitle")));
         }
         this.m_worldOne = m_window.world1_mc;
         this.m_farmRunQuestWorld1Frame = new FarmRunQuestWorldFrame(this.m_worldOne,this,1);
         addWidget(this.m_farmRunQuestWorld1Frame);
         this.m_farmRunQuestWorld1Frame.visible = false;
         this.m_worldTwo = m_window.world2_mc;
         this.m_farmRunQuestWorld2Frame = new FarmRunQuestWorldFrame(this.m_worldTwo,this,2);
         addWidget(this.m_farmRunQuestWorld2Frame);
         this.m_farmRunQuestWorld2Frame.visible = false;
         this.m_worldThree = m_window.world3_mc;
         this.m_farmRunQuestWorld3Frame = new FarmRunQuestWorldFrame(this.m_worldThree,this,3);
         addWidget(this.m_farmRunQuestWorld3Frame);
         this.m_farmRunQuestWorld3Frame.visible = false;
         this.setWorldFrame();
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.showTutorial));
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_Tutorial = m_window.tutorial_mc;
            this.m_Tutorial.visible = false;
            addWidget(new FarmAnimatedButton(this.m_Tutorial.okay_bt,this.okayCallBack));
         }
         if(m_window.hasOwnProperty("finalReward_mc"))
         {
            this.m_finalReward = m_window.finalReward_mc;
            this.m_finalReward.visible = true;
         }
         if(m_window.hasOwnProperty("quest_mc"))
         {
            this.m_quest = m_window.quest_mc;
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npc = m_window.npc_mc;
            this.m_npc.visible = true;
            this.m_npc.gotoAndStop(FarmRunQuestManager.getInstance().getCurrentWorldNum());
            if(this.m_npc.hasOwnProperty("taskTitle_tf"))
            {
               this.m_npcText = addWidget(new ZwTextField(this.m_npc.taskTitle_tf,ZLocUtils.t("Dialogs","ofquests-01-stage" + FarmRunQuestManager.getInstance().getCurrentStage().toString() + "_Body"))) as ZwTextField;
            }
         }
         if(FarmRunQuestManager.getInstance().isFeatureCompleted() == false || FarmRunQuestManager.getInstance().isFeatureCompleted() == true && FarmRunQuestManager.getInstance().isFeatureReplayed() == true)
         {
            this.m_farmRunQuestTaskFrame = new FarmRunQuestTaskFrame(this.m_quest,this,this.m_featureName);
            addWidget(this.m_farmRunQuestTaskFrame);
         }
         else
         {
            if(this.m_npcText)
            {
               this.m_npcText.text = "Well Done Farmer!";
            }
            if(this.m_farmRunQuestTaskFrame)
            {
               this.m_farmRunQuestTaskFrame.visible = false;
            }
         }
         if(Boolean(this.m_finalReward) && this.m_finalReward.hasOwnProperty("completeIcon1_mc"))
         {
            this.m_completeIcon1 = this.m_finalReward.completeIcon1_mc as MovieClip;
            if(this.m_completeIcon1)
            {
               if(FarmRunQuestManager.getInstance().isFeatureCompleted() == true || FarmRunQuestManager.getInstance().isFeatureReplayed() == true)
               {
                  this.m_completeIcon1.visible = true;
               }
               else
               {
                  this.m_completeIcon1.visible = false;
               }
            }
         }
         if(m_window.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_window.timer_tf,FarmRunQuestManager.getInstance().getTimeRemaining() + " Left"));
         }
         if(m_window.hasOwnProperty("leaderboard_mc"))
         {
            this.m_LeaderboardWindow = m_window.leaderboard_mc;
            this.m_farmRunLeaderboardFrame = addWidget(new FarmRunQuestsLeaderboardUpperFrame(this.m_LeaderboardWindow,this.closeLeaderboard,this.m_leaderboard)) as FarmRunQuestsLeaderboardUpperFrame;
            this.m_farmRunLeaderboardFrame.visible = false;
         }
         if(m_window.hasOwnProperty("leaderboard_bt"))
         {
            rank_tf = "Rank : ";
            leaderboardFriendList = FarmRunQuestManager.getFriendList("FarmRunQuests");
            rank_tf += FarmRunQuestManager.getInstance().getUserLeaderboardRank("FarmRunQuests").toString() + "/" + (leaderboardFriendList.length + 1).toString();
            this.m_leaderboardButton = addWidget(new FarmAnimatedTextButton(m_window.leaderboard_bt,rank_tf,this.displayLeaderBoard)) as FarmAnimatedTextButton;
            this.m_leaderboardButton.visible = true;
         }
         if(FarmRunQuestManager.getInstance().getFeatureOptionsKey(this.HAS_TUTORIAL_SEEN) != 1)
         {
            this.m_Tutorial.visible = true;
            FarmRunQuestManager.getInstance().saveFeatureOptionsKey(this.HAS_TUTORIAL_SEEN,1);
            TransactionManager.addTransaction(new TGenericTransaction("FarmRunQuestService","setFeatureOption",null,new Array(this.m_featureName,this.HAS_TUTORIAL_SEEN,"1")),true);
         }
      }
      
      public function displayLeaderBoard(evnt:Event) : void
      {
         this.m_farmRunLeaderboardFrame.visible = true;
         this.m_farmRunLeaderboardFrame.refresh();
         FarmStatsManager.count("farmrun_displayLeaderBoard","open_click");
      }
      
      public function closeLeaderboard() : void
      {
         this.m_farmRunLeaderboardFrame.visible = false;
      }
      
      public function showTutorial(event:Event) : void
      {
         this.m_Tutorial.visible = true;
      }
      
      public function updateTaskFrame() : void
      {
         this.m_farmRunQuestTaskFrame.setSkipAllCost();
      }
      
      public function setWorldFrame(worldNum:int = -1) : void
      {
         var currentStagedNum:int = 0;
         var currentWorldNum:int = 0;
         if(worldNum == -1)
         {
            m_currentDisplayedWorldNum = FarmRunQuestManager.getInstance().getCurrentWorldNum();
         }
         else
         {
            m_currentDisplayedWorldNum = worldNum;
         }
         this.hideWorldFrames();
         switch(m_currentDisplayedWorldNum)
         {
            case 1:
               this.m_farmRunQuestWorld1Frame.visible = true;
               this.m_farmRunQuestWorld1Frame.pageNumber = 0;
               m_currentDisplayedWorldNum = 1;
               break;
            case 2:
               this.m_farmRunQuestWorld2Frame.visible = true;
               this.m_farmRunQuestWorld2Frame.pageNumber = 1;
               m_currentDisplayedWorldNum = 2;
               break;
            case 3:
               this.m_farmRunQuestWorld3Frame.visible = true;
               this.m_farmRunQuestWorld3Frame.pageNumber = 2;
               m_currentDisplayedWorldNum = 3;
         }
         if(this.m_farmRunQuestTaskFrame)
         {
            currentStagedNum = FarmRunQuestManager.getInstance().getCurrentStage();
            currentWorldNum = FarmRunQuestManager.getInstance().getCurrentWorldNum();
            if(m_currentDisplayedWorldNum == currentWorldNum)
            {
               this.m_farmRunQuestTaskFrame.visible = true;
               this.m_npcText.text = ZLocUtils.t("Dialogs","ofquests-01-stage" + currentStagedNum.toString() + "_Body");
            }
            else if(m_currentDisplayedWorldNum < currentWorldNum)
            {
               if(m_currentDisplayedWorldNum == 1)
               {
                  this.m_npcText.text = "Don’t look back farmer!  You’re not going that way.";
               }
               else
               {
                  this.m_npcText.text = "Keep going! Each stage might get harder, but don’t stop!";
               }
               this.m_farmRunQuestTaskFrame.visible = false;
            }
            else
            {
               if(m_currentDisplayedWorldNum == 2)
               {
                  this.m_npcText.text = "There’s lot to finish, Farmer! Hurry!";
               }
               else
               {
                  this.m_npcText.text = "If you can’t fly, then run, but whatever you do, you have to keep going!";
               }
               this.m_farmRunQuestTaskFrame.visible = false;
            }
            if(FarmRunQuestManager.getInstance().isFeatureCompleted() == true)
            {
               this.m_npcText.text = "Well Done Farmer!";
               this.m_farmRunQuestTaskFrame.visible = false;
            }
         }
         if(this.m_npc)
         {
            this.m_npc.gotoAndStop(m_currentDisplayedWorldNum);
         }
         if(FarmRunQuestManager.getInstance().isFeatureCompleted() == true)
         {
            if(this.m_npcText)
            {
               this.m_npcText.text = "Well Done Farmer!";
            }
         }
      }
      
      public function okayCallBack(event:Event) : void
      {
         this.m_nextTutorialStage = (this.m_nextTutorialStage + 1) % 5;
         if(this.m_nextTutorialStage == 0)
         {
            this.m_nextTutorialStage = 1;
            this.m_Tutorial.visible = false;
         }
         (this.m_Tutorial as MovieClip).gotoAndStop(this.m_nextTutorialStage);
      }
      
      public function hideWorldFrames() : void
      {
         this.m_farmRunQuestWorld1Frame.visible = false;
         this.m_farmRunQuestWorld2Frame.visible = false;
         this.m_farmRunQuestWorld3Frame.visible = false;
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

