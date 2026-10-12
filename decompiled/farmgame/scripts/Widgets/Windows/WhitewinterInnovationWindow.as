package Widgets.Windows
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.WhitewinterInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WhitewinterInnovationQuestTaskFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class WhitewinterInnovationWindow extends FarmWindowWithTutorial
   {
      
      protected var m_title:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private var m_npc:MovieClip = new MovieClip();
      
      private var m_collectMc:MovieClip;
      
      private var m_timer:MovieClip;
      
      private var m_tree:MovieClip;
      
      private var m_gift:MovieClip;
      
      protected var m_remainingTimeTf:ZwTextField;
      
      private var m_giftBt:FarmAnimatedTextButton;
      
      private var m_progress:MovieClip;
      
      private var m_consumableMc:MovieClip;
      
      private var m_collectConsumable:FarmAnimatedTextButton;
      
      private var m_buyConsumable:FarmAnimatedTextButton;
      
      private var m_askConsumable:FarmAnimatedTextButton;
      
      private var m_consumableCount:ZwTextField;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_Tutorial:MovieClip = new MovieClip();
      
      private var m_nextTutorialStage:uint = 1;
      
      private var m_isTutorialActive:Boolean = false;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Next","Next","Cool!"];
      
      private var m_whitewinterInnovationTaskFrame:WhitewinterInnovationQuestTaskFrame = null;
      
      private var m_quest:MovieClip = new MovieClip();
      
      private var m_featureName:String;
      
      private const TOTAL_NUM_OF_TUTORIAL_PAGES:int = 5;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private var m_levelNumText:ZwTextField;
      
      private var m_finish_mc:MovieClip;
      
      private var m_counter1_mc:MovieClip;
      
      private var m_counter2_mc:MovieClip;
      
      private var m_counter3_mc:MovieClip;
      
      private var m_next_mc:MovieClip;
      
      private var m_stageIndicator1:Array = new Array();
      
      private var m_stageIndicator2:Array = new Array();
      
      private var m_stageIndicator3:Array = new Array();
      
      private var m_bonus_mc:MovieClip;
      
      private var m_reward_mc:MovieClip;
      
      private var m_date_tf:ZwTextField;
      
      private var m_giftElement:MovieClip;
      
      private var m_gitCount_tf:ZwTextField;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      private var m_progressTitle_tf:ZwTextField;
      
      private var m_progress_tf:ZwTextField;
      
      private var m_tileUnlockMc:MovieClip;
      
      private var m_tileunlocktf:ZwTextField;
      
      private var m_tileunlockmcbt:FarmAnimatedTextButton;
      
      private var m_tileunlockdesctf:ZwTextField;
      
      public function WhitewinterInnovationWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         var numOfTutorialPage:int = this.TOTAL_NUM_OF_TUTORIAL_PAGES;
         super(featureName,assetPath,numOfTutorialPage);
      }
      
      override protected function postLoadComplete() : void
      {
         var tileCount:int = 0;
         var stageNum:int = 0;
         var giftLevel:int = 0;
         var treeLevel1:int = 0;
         var treeLevel2:int = 0;
         var treeLevel3:int = 0;
         var currentBonus:Object = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_Title")));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedButton(m_window[this.WHATISTHIS_MC],this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty("finish_mc"))
         {
            (this.m_finish_mc = m_window["finish_mc"] as MovieClip).visible = false;
         }
         if(m_window.hasOwnProperty("tileUnlock_mc"))
         {
            (this.m_tileUnlockMc = m_window["tileUnlock_mc"] as MovieClip).visible = false;
            addWidget(this.m_tileunlocktf = new ZwTextField(m_window["tileUnlock_mc"]["overlay_tf"],""),false);
            addWidget(this.m_tileunlockdesctf = new ZwTextField(m_window["tileUnlock_mc"]["description_tf"],""),false);
            addWidget(this.m_tileunlockmcbt = new FarmAnimatedTextButton(m_window["tileUnlock_mc"]["overlay_bt"],"OK",this.onClickTileUnlock));
            tileCount = this.manager.getTileUnlockCount();
            if(tileCount > 0)
            {
               this.m_tileUnlockMc.visible = true;
               this.m_tileunlocktf.visible = true;
               this.m_tileunlocktf.text = "CONGRATULATIONS!";
               this.m_tileunlockmcbt.visible = true;
               this.m_tileunlockdesctf.text = "You will get " + 5 * tileCount + " more Letters to Santa every 6 hours for purchasing " + tileCount + (tileCount == 1 ? " tile!" : " tiles!");
               this.m_tileunlockdesctf.visible = true;
            }
         }
         if(this.manager.getCurrentStage() >= 20)
         {
            this.m_finish_mc.visible = true;
            this.m_tileUnlockMc.visible = false;
            this.m_whatIsThis_mc.visible = false;
            if(this.m_finish_mc.hasOwnProperty("finish1_tf"))
            {
               addWidget(new ZwTextField(this.m_finish_mc["finish1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_collection_finish_text1")));
            }
            if(this.m_finish_mc.hasOwnProperty("finish2_tf"))
            {
               addWidget(new ZwTextField(this.m_finish_mc["finish2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_collection_finish_text2",{"date":this.manager.getnextMilestoneDateAfterFeatureCompletion()})));
            }
         }
         else
         {
            if(m_window.hasOwnProperty("body_tf"))
            {
               addWidget(new ZwTextField(m_window["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_body")));
            }
            if(m_window.hasOwnProperty("taskTitle_tf"))
            {
               addWidget(new ZwTextField(m_window["taskTitle_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_taskTitle")));
            }
            stageNum = this.manager.getTreeProgressLevel();
            if(m_window.hasOwnProperty("level_tf"))
            {
               addWidget(this.m_levelNumText = new ZwTextField(m_window["level_tf"],"Level " + stageNum.toString() + "/5"));
            }
            if(m_window.hasOwnProperty("tasks_mc"))
            {
               this.m_quest = m_window.tasks_mc;
            }
            this.m_whitewinterInnovationTaskFrame = new WhitewinterInnovationQuestTaskFrame(this.m_quest,this,this.m_featureName);
            addWidget(this.m_whitewinterInnovationTaskFrame);
            if(m_window.hasOwnProperty("timer_mc"))
            {
               this.m_timer = m_window.timer_mc;
               addWidget(this.m_remainingTimeTf = new ZwTextField(m_window["timer_mc"]["timer_tf"],this.getFeatureEndDaysLeftText()));
               this.m_timer.visible = true;
            }
            if(m_window.hasOwnProperty("tree_mc"))
            {
               this.m_tree = m_window.tree_mc;
               this.m_tree.visible = true;
            }
            giftLevel = this.manager.getCurrentStage() % 10 + 1;
            if(m_window.hasOwnProperty("gift_mc"))
            {
               this.m_gift = m_window.gift_mc;
               this.m_gift.gotoAndStop(giftLevel);
               this.m_gift.visible = true;
            }
            if(m_window.hasOwnProperty("progress_mc"))
            {
               (this.m_progress = m_window["progress_mc"] as MovieClip).visible = true;
               this.m_next_mc = this.m_progress["next_mc"] as MovieClip;
               this.m_next_mc.visible = true;
               addWidget(this.m_date_tf = new ZwTextField(this.m_progress["date_tf"],""));
               addWidget(this.m_progressTitle_tf = new ZwTextField(this.m_progress["progressTitle_tf"],this.manager.getCurrentCollectionName()));
               addWidget(this.m_progress_tf = new ZwTextField(this.m_progress["progress_tf"],""));
               (this.m_counter1_mc = this.m_progress["counter1_mc"] as MovieClip).visible = false;
               for(treeLevel1 = 0; treeLevel1 <= 5; treeLevel1++)
               {
                  this.m_stageIndicator1[treeLevel1] = this.m_counter1_mc["helpcount_mc_" + treeLevel1.toString()]["on_mc"] as MovieClip;
                  this.m_stageIndicator1[treeLevel1].visible = false;
               }
               (this.m_counter2_mc = this.m_progress["counter2_mc"] as MovieClip).visible = false;
               for(treeLevel2 = 0; treeLevel2 <= 4; treeLevel2++)
               {
                  this.m_stageIndicator2[treeLevel2] = this.m_counter2_mc["helpcount_mc_" + treeLevel2.toString()]["on_mc"] as MovieClip;
                  this.m_stageIndicator2[treeLevel2].visible = false;
               }
               (this.m_counter3_mc = this.m_progress["counter3_mc"] as MovieClip).visible = false;
               for(treeLevel3 = 0; treeLevel3 <= 2; treeLevel3++)
               {
                  this.m_stageIndicator3[treeLevel3] = this.m_counter3_mc["helpcount_mc_" + treeLevel3.toString()]["on_mc"] as MovieClip;
                  this.m_stageIndicator3[treeLevel3].visible = false;
               }
            }
            this.populateConsumables();
            this.refreshCollectButton();
            this.setProgress();
         }
         if(m_window.hasOwnProperty("gifts_bt"))
         {
            addWidget(this.m_giftBt = new FarmAnimatedTextButton(m_window["gifts_bt"],"",this.openGiftDialog));
            this.m_giftElement = m_window["gifts_bt"] as MovieClip;
            addWidget(this.m_gitCount_tf = new ZwTextField(this.m_giftElement["giftcount_tf"],this.manager.getCurrentStage().toString() + "/" + this.manager.rewardsArray.length.toString()));
         }
         if(m_window.hasOwnProperty("bonus_mc") && this.manager.getCurrentStage() < 20)
         {
            this.m_bonus_mc = m_window["bonus_mc"] as MovieClip;
            currentBonus = this.manager.getProgressMeterLevelCounter();
            this.m_bonus_mc.visible = !this.manager.hasDatePassedForSlot(this.manager.getCurrentStage());
            this.m_reward_mc = this.m_bonus_mc["reward_mc"] as MovieClip;
            this.m_reward_mc.gotoAndStop(currentBonus.counter);
         }
      }
      
      private function setProgress() : void
      {
         var index:int = 0;
         var currentStage:int = this.manager.getCurrentStage();
         var currentprogressMeterLevel:Object = this.manager.getProgressMeterLevelCounter();
         switch(currentprogressMeterLevel.counter)
         {
            case 1:
               this.m_counter1_mc.visible = true;
               this.m_progress_tf.text = "Get 6 presents to evolve your tree";
               this.m_date_tf.text = "Complete the Festive Collection before 25th December to get the bonus reward!";
               for(index = 0; index < currentprogressMeterLevel.stage; index++)
               {
                  this.m_stageIndicator1[index].visible = true;
               }
               break;
            case 2:
               this.m_counter2_mc.visible = true;
               this.m_progress_tf.text = "Get 5 presents to evolve your tree";
               this.m_date_tf.text = "Complete the New Year\'s Collection before 1st Jan to get the bonus reward!";
               for(index = 0; index < currentprogressMeterLevel.stage; index++)
               {
                  this.m_stageIndicator2[index].visible = true;
               }
               break;
            case 3:
               this.m_counter3_mc.visible = true;
               this.m_progress_tf.text = "Get 3 presents to evolve your tree";
               this.m_date_tf.text = "Complete the Season\'s Collection before 5th Jan to get the bonus reward!";
               for(index = 0; index < currentprogressMeterLevel.stage; index++)
               {
                  this.m_stageIndicator3[index].visible = true;
               }
               break;
            default:
               this.m_counter1_mc.visible = true;
               this.m_progress_tf.text = "Get 6 presents to evolve your tree";
               this.m_date_tf.text = "Evolve your tree on or before 1st Jan to get the bonus reward!";
         }
         var currentTreeLevel:int = this.manager.getTreeProgressLevel();
         this.m_tree.gotoAndStop(currentTreeLevel);
         this.m_next_mc.gotoAndStop(currentTreeLevel + 1);
      }
      
      private function get manager() : WhitewinterInnovationManager
      {
         return WhitewinterInnovationManager.getInstance();
      }
      
      private function populateConsumables() : void
      {
         var consumableCount:int = this.manager.consumableCount;
         var ConsumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.ConsumableCode);
         this.m_consumableMc = m_window["consumable_mc"] as MovieClip;
         (m_window["consumable_mc"] as MovieClip).visible = true;
         addWidget(new ZwTextField(m_window["consumable_mc"]["name_tf"],ConsumableItem.friendlyTitle));
         addWidget(this.m_collectConsumable = new FarmAnimatedTextButton(m_window["consumable_mc"]["collect_bt"],"Collect",this.collectConsumableCallback));
         addWidget(this.m_consumableCount = new ZwTextField(m_window["consumable_mc"]["count_tf"],"x" + consumableCount.toString()));
         addWidget(this.m_buyConsumable = new FarmAnimatedTextButton(m_window["consumable_mc"]["buy_bt"],"Buy",this.buyCallback));
         addWidget(this.m_tileUnlock_bt = new FarmAnimatedTextButton(m_window["consumable_mc"]["unlock_bt"],"View Tile",this.openTileDialog));
         if(this.manager.lockedTilesArray.length <= 0)
         {
            this.m_tileUnlock_bt.enabled = false;
            this.m_tileUnlock_bt.callback = null;
            this.m_tileUnlock_bt.applyGrayOut = true;
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_WHITEWINTER)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText2"));
            }
            else
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText3"));
            }
         }
      }
      
      public function collectConsumableCallback(e:MouseEvent) : void
      {
         FarmStatsManager.count("whitewinter","Main_UI","collect_cons");
         this.manager.collectConsumables();
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         this.refreshAskButton();
         this.refreshCollectButton();
         this.m_whitewinterInnovationTaskFrame.refresh();
      }
      
      private function buyCallback(event:Event) : void
      {
         FarmStatsManager.count("WhitewinterInnovation","BuyLetters_Click");
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_askConsumable)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(this.manager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askConsumable,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askConsumable,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_askConsumable.enabled = true;
               this.m_askConsumable.detachTooltip();
            }
         }
      }
      
      public function refreshCollectButton() : void
      {
         var key:String = null;
         if(this.manager.canCollectConsumables() == false)
         {
            this.m_collectConsumable.enabled = false;
            this.m_collectConsumable.callback = null;
            key = WhitewinterInnovationManager.WHITEWINTER_COLLECT_CONSUMABLE_KEY;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_collectConsumable,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CollectHoverText",{"time":HUD.getformattedTimeLeft(this.manager.getTimeLeft(key,WhitewinterInnovationManager.DEFAULT_COLLECT_THROTTLE_TIME))}));
         }
         else
         {
            this.m_collectConsumable.enabled = true;
            this.m_collectConsumable.callback = this.collectConsumableCallback;
            this.m_collectConsumable.detachTooltip();
         }
         this.m_consumableCount.text = "x" + this.manager.getConsumableItemCount(this.manager.ConsumableCode).toString();
      }
      
      private function openTileDialog(e:Event) : void
      {
         FarmStatsManager.count("WhitewinterInnovation","View Tile");
         this.close();
         UI.displayPopup(new WhitewinterInnovationTileWindow(this.m_featureName,this.manager.tileUnlockDialogURL));
      }
      
      private function openGiftDialog(e:Event) : void
      {
         FarmStatsManager.count("WhitewinterInnovation","ViewGifts_Click");
         this.manager.openGiftWindow();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      private function onClickTileUnlock(event:Event) : void
      {
         if(this.m_tileUnlockMc)
         {
            this.m_tileUnlockMc.visible = false;
            this.manager.resetTileUnlock();
         }
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTimeText:String = null;
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var requirement:Object = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("Whitewinter_feature_enabled");
         var requirementsArray:Array = prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         for each(requirement in requirementsArray)
         {
            if(requirement.type == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               endTimeText = requirement.value;
               break;
            }
         }
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(endTimeText);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         super.onTutorialOkayButtonClick(event);
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
   }
}

