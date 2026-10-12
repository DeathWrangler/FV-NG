package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotItemTimerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmersMarketInnovationGenericOrderboardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmersMarketInnovationOrderboardTaskSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TASK_BT:String = "task_bt";
      
      private const TASK1_BT:String = "task1_bt";
      
      private const DUMP_BT:String = "dump_bt";
      
      private const DUMPBG_MC:String = "dumpBG_mc";
      
      private const TASKBG_MC:String = "taskBG_mc";
      
      private const REDEEMBG_MC:String = "redeemBG_mc";
      
      private const SKIP_BT:String = "skip_bt";
      
      private const SKIP1_BT:String = "skip1_bt";
      
      private const TITLE_TF:String = "questtitle_tf";
      
      private const COUNT_TF:String = "questdone_tf";
      
      private const TRASH_TF:String = "trash_tf";
      
      private const POINTS_MC:String = "points_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const ADDPOINTS_TF:String = "addpoints_tf";
      
      private const ANIMATION_MC:String = "animation_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const EXPIRATION_MC:String = "expiration_mc";
      
      private var m_titelTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_produce_icon:FarmIcon;
      
      private var m_trashTf:ZwTextField;
      
      private var m_addpointsTf:ZwTextField;
      
      private var m_iconMc:FarmIcon;
      
      private var m_pointsMc:ZwFrame;
      
      private var m_animationMc:MovieClip;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_task1Bt:FarmAnimatedTextButton;
      
      private var m_skip1Bt:FarmAnimatedCashButton;
      
      private var m_dumpBt:FarmAnimatedTextButton;
      
      private var m_dumpBG:ZwFrame;
      
      private var m_taskBG:ZwFrame;
      
      private var m_redeemBG:MovieClip;
      
      private var m_expirationFrame:MarketSlotItemTimerFrame;
      
      private var m_TaskButtonClick:Boolean = false;
      
      public var m_slotnumber:int;
      
      private var m_checkmark:MovieClip;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_owner:FarmersMarketInnovationGenericOrderboardWindow;
      
      private var FIRST_TIME_DUMP_SEEN:String = "InnovationFirstTimeDump";
      
      private var BIG_BUILDABLE_ITEM_CODE:String = "2hpm";
      
      private var HARVEST_BUILDABLE_ITEM_CODE:String = "2gyy";
      
      public function FarmersMarketInnovationOrderboardTaskSlot(featureName:String, element:DisplayObject, window:FarmersMarketInnovationGenericOrderboardWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
         }
         if(m_element.hasOwnProperty(this.TASK_BT))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[this.TASK_BT],"Task",this.onClickTaskButton));
         }
         if(m_element.hasOwnProperty(this.TASK1_BT))
         {
            addWidget(this.m_task1Bt = new FarmAnimatedTextButton(m_element[this.TASK1_BT],"Show me!",this.onClickTask1ButtonGetNewTask));
         }
         if(m_element.hasOwnProperty(this.SKIP_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[this.SKIP_BT],"Complete","3",this.onClickSkipButton));
         }
         if(m_element.hasOwnProperty(this.SKIP1_BT))
         {
            addWidget(this.m_skip1Bt = new FarmAnimatedCashButton(m_element[this.SKIP1_BT],"Skip","1",this.onClickSkip1ButtonDumpedTask));
         }
         if(m_element.hasOwnProperty(this.DUMP_BT))
         {
            addWidget(this.m_dumpBt = new FarmAnimatedTextButton(m_element[this.DUMP_BT],"Trash",this.onClickDumpButton));
         }
         if(m_element.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titelTf = new ZwTextField(m_element[this.TITLE_TF]);
         }
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[this.COUNT_TF]);
         }
         if(m_element.hasOwnProperty(this.TRASH_TF))
         {
            this.m_trashTf = new ZwTextField(m_element[this.TRASH_TF]);
         }
         if(m_element.hasOwnProperty(this.POINTS_MC))
         {
            this.m_pointsMc = new ZwFrame(m_element[this.POINTS_MC]);
            if(m_element[this.POINTS_MC].hasOwnProperty(this.POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[this.POINTS_MC][this.POINTS_TF]);
            }
         }
         if(m_element.hasOwnProperty("produce_icon_mc"))
         {
            this.m_produce_icon = new FarmIcon(m_element["produce_icon_mc"]);
            this.updateWeeklyProduceIcon();
         }
         if(m_element.hasOwnProperty(this.ADDPOINTS_TF))
         {
            this.m_addpointsTf = new ZwTextField(m_element[this.ADDPOINTS_TF]);
         }
         if(m_element.hasOwnProperty(this.ANIMATION_MC))
         {
            this.m_animationMc = m_element[this.ANIMATION_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.DUMPBG_MC))
         {
            this.m_dumpBG = new ZwFrame(m_element[this.DUMPBG_MC]);
         }
         if(m_element.hasOwnProperty(this.TASKBG_MC))
         {
            this.m_taskBG = new ZwFrame(m_element[this.TASKBG_MC]);
         }
         if(m_element.hasOwnProperty(this.REDEEMBG_MC))
         {
            this.m_redeemBG = m_element[this.REDEEMBG_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkmark = m_element[this.CHECKMARK_MC] as MovieClip;
         }
      }
      
      private static function toggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      override public function populate(data:Object) : void
      {
         var tooltipText:String = null;
         var bushelQty:int = 0;
         super.populate(data);
         this.m_data = data;
         this.m_trashTf.visible = false;
         this.m_task1Bt.visible = false;
         this.m_skip1Bt.visible = false;
         this.m_checkmark.visible = false;
         this.m_animationMc.visible = false;
         this.m_addpointsTf.visible = false;
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(Boolean(data) && data.hasOwnProperty("questTask"))
         {
            this.m_task = data.questTask;
         }
         if(this.m_task.iconUrl)
         {
            this.m_iconMc.visible = true;
            this.m_iconMc.loadIcon(this.getIconUrl());
         }
         if(Boolean(data) && data.hasOwnProperty("questText"))
         {
            this.m_titelTf.text = this.getQuestTitleText(data.questText);
            this.m_titelTf.visible = true;
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
         {
            this.setHelperText(data.helperText);
            this.setSkipButton(data.skipCashValue);
         }
         if(Boolean(this.m_data) && this.m_data.hasOwnProperty("progress"))
         {
            this.m_countTf.text = this.m_data.progress + "/" + this.m_task.total;
            this.m_countTf.visible = true;
         }
         if(this.manager.isTaskDumped(this.m_slotnumber))
         {
            this.m_dumpBG.visible = true;
            this.m_taskBG.visible = false;
            this.m_redeemBG.visible = false;
            this.m_dumpBt.visible = false;
            this.m_countTf.visible = false;
            this.m_iconMc.visible = false;
            this.m_taskBt.visible = false;
            this.m_skipBt.visible = false;
            this.m_titelTf.visible = false;
            this.m_trashTf.visible = true;
            if(this.manager.canDumpTask(this.m_slotnumber))
            {
               this.m_trashTf.text = "A New task is now available";
               this.m_task1Bt.enabled = true;
               this.m_task1Bt.visible = true;
               this.m_skip1Bt.visible = false;
            }
            else
            {
               this.m_trashTf.text = "Next task appears in " + FarmGameUtil.toFriendlyTime(this.manager.getTimeRemainingForDumpedTask(this.m_slotnumber));
               this.m_task1Bt.visible = false;
               this.m_skip1Bt.enabled = true;
               this.m_skip1Bt.visible = true;
            }
         }
         else
         {
            this.m_dumpBG.visible = false;
            this.m_taskBG.visible = true;
            this.m_redeemBG.visible = false;
            this.m_taskBt.callback = this.onClickTaskButton;
            this.m_dumpBt.visible = true;
            this.m_dumpBt.enabled = true;
            this.m_pointsMc.visible = true;
            this.m_pointsTf.visible = true;
            this.m_pointsTf.text = this.m_task.questPoints.toString();
         }
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            this.m_taskBt.enabled = this.m_task.canAskForHelp();
         }
         if(this.m_task.action == QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC || this.m_task.action == QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE)
         {
            this.m_countTf.visible = false;
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("completed")) && Boolean(data.completed))
         {
            this.m_checkmark.visible = true;
            this.m_dumpBt.visible = false;
            this.m_skipBt.visible = false;
            this.m_taskBt.visible = true;
            this.m_taskBt.enabled = true;
            this.m_taskBt.text = "Redeem";
            this.m_redeemBG.visible = true;
            this.m_taskBG.visible = false;
            this.m_dumpBG.visible = false;
         }
         this.m_taskBt.detachTooltip();
         if(!this.m_taskBt.enabled)
         {
            tooltipText = data.helperText;
            this.m_taskBt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,tooltipText);
         }
         else
         {
            toggleButton(this.m_taskBt,true);
         }
         if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
         {
            this.m_countTf.text = this.m_task.total.toString();
            if(!Global.player.canBuy(this.m_task.total,false))
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,"You don\'t have enough coins!");
            }
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
         {
            bushelQty = CraftingManager.getInstance().getBushelQuantityInInventory(this.m_task.type);
            if(bushelQty < this.m_task.total)
            {
            }
         }
         this.updateWeeklyProduceIcon();
      }
      
      private function setSkipButton(cost:String) : void
      {
         this.m_skipBt.enabled = true;
         this.m_skipBt.visible = true;
         this.m_skipBt.setAmountText(cost);
      }
      
      private function setHelperText(requestText:String) : void
      {
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
            case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
               requestText = "Open";
               break;
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED:
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
               requestText = "Ask";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               requestText = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               requestText = "Craft";
               break;
            case QuestConstants.HELPER_TYPE_SINK_GOLD:
               requestText = ZLocUtils.t("Quests","Helper_Sink_Gold_Button");
               break;
            case QuestConstants.HELPER_TYPE_SINK_BUSHEL:
               if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
               {
                  requestText = "Give";
               }
               else
               {
                  requestText = "Plant";
               }
         }
         if(requestText == "" || requestText == null)
         {
            this.m_taskBt.visible = false;
            return;
         }
         if(Boolean(this.m_taskBt.element) && this.m_taskBt.element.hasOwnProperty("generic_tf"))
         {
            this.m_taskBt.element.generic_tf.text = requestText;
            this.m_taskBt.enabled = true;
            this.m_taskBt.visible = true;
         }
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_task;
         if(Boolean(this.m_taskBt) && Boolean(task) && success)
         {
            if(task.canAskForHelp())
            {
               this.m_taskBt.enabled = true;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
            }
            else
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,task.helperText);
            }
         }
      }
      
      private function onClickTask1ButtonGetNewTask(event:Event) : void
      {
         this.m_taskBt.enabled = false;
         this.m_taskBt.visible = false;
         this.m_titelTf.visible = false;
         this.m_iconMc.visible = false;
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_addpointsTf.visible = true;
         this.m_addpointsTf.text = "Loading...";
         this.m_owner.tintWindow();
         this.m_owner.enableInput = false;
         this.manager.getNewTasks(this.m_slotnumber,this.m_owner.resumeWindow);
         StatsManager.count(this.m_featureName,"GetNewTask","","","TaskSlot" + (this.m_slotnumber + 1).toString());
      }
      
      private function onClickTaskButton(event:Event) : void
      {
         var confirmationText:String = null;
         this.m_TaskButtonClick = true;
         this.m_taskBt.enabled = false;
         if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
         {
            if(this.manager.exceedsStorageCapacity(this.m_task.questPoints))
            {
               this.manager.showLimitedStoragePopup(this.m_slotnumber,false);
            }
            else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               this.manager.sinkBushel(this.m_slotnumber,this.m_owner.refreshTaskFrame);
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               this.m_dumpBt.visible = false;
               this.m_iconMc.visible = false;
               this.m_titelTf.visible = false;
               this.m_countTf.visible = false;
               this.m_pointsMc.visible = false;
               this.m_pointsTf.visible = false;
               if(this.m_iconMc.tooltip)
               {
                  this.m_iconMc.tooltip.release();
               }
               this.m_animationMc.visible = true;
               MovieClipUtils.recursivePlay(this.m_animationMc);
               this.m_addpointsTf.visible = true;
               this.m_addpointsTf.text = this.pointsEarnedString();
            }
            else
            {
               this.manager.redeemRewardPoints(this.m_slotnumber,this.m_owner.refreshTaskFrame,this.m_task.questPoints);
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               this.m_dumpBt.visible = false;
               this.m_iconMc.visible = false;
               this.m_titelTf.visible = false;
               this.m_countTf.visible = false;
               this.m_pointsMc.visible = false;
               this.m_pointsTf.visible = false;
               if(this.m_iconMc.tooltip)
               {
                  this.m_iconMc.tooltip.release();
               }
               this.m_animationMc.visible = true;
               MovieClipUtils.recursivePlay(this.m_animationMc);
               this.m_addpointsTf.visible = true;
               this.m_addpointsTf.text = this.pointsEarnedString();
            }
            StatsManager.count(this.m_featureName,"Redeem",this.getKingdomText() + ":" + this.m_slotnumber.toString(),Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_task.type),this.m_task.questPoints.toString(),this.manager.getOrderboardProgress().toString());
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
         {
            if(this.manager.exceedsStorageCapacity(this.m_task.questPoints))
            {
               this.manager.showLimitedStoragePopup(this.m_slotnumber,false);
            }
            else
            {
               StatsManager.count(this.m_featureName,"Sink Coin","",this.m_task.questPoints.toString(),this.m_slotnumber.toString());
               confirmationText = ZLocUtils.t("Dialogs","SinkGoldTaskConfirmation",{"quantity":this.m_task.total});
               if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSinkGoldConfirmation,"farmAnimatedTextConfirmation",true,true))
               {
                  this.m_taskBt.enabled = false;
                  this.m_owner.tintWindow();
                  this.m_owner.enableInput = false;
               }
            }
         }
         else
         {
            StatsManager.count(this.m_featureName,this.getKingdomText() + ":" + this.m_slotnumber.toString(),Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_task.type),this.m_task.questPoints.toString());
            if(this.m_task)
            {
               this.m_task.performHelperAction(null,this.onAskFeedPosted);
            }
            if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
            }
            else
            {
               this.m_owner.close();
            }
         }
         this.m_TaskButtonClick = false;
      }
      
      public function isTaskButtonClicked() : Boolean
      {
         return this.m_TaskButtonClick;
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_data.skipCashValue});
         if(this.manager.exceedsStorageCapacity(this.m_task.questPoints))
         {
            this.manager.showLimitedStoragePopup(this.m_slotnumber,true);
         }
         else if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickDumpButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TrashTaskConfirmation");
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptDumpConfirmation,"farmAnimatedTextConfirmation",true,true))
         {
            this.m_dumpBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickSkipButtonAfterConfirmation(event:Event) : void
      {
         this.m_skipBt.enabled = false;
         this.m_skipBt.visible = false;
         this.m_taskBt.visible = false;
         this.m_dumpBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.visible = false;
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.visible = false;
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_addpointsTf.visible = true;
         this.m_addpointsTf.text = this.pointsEarnedString();
         this.manager.skipTask(this.m_slotnumber,this.m_task.questPoints,this.m_owner.resumeWindow);
         if(this.manager.getInnovationFeatureName() == "CocowonderlandInnovation")
         {
            this.manager.grantPointsForTask(this.m_task.questPoints);
         }
         StatsManager.count(this.m_featureName,"Complete",this.getKingdomText() + ":" + this.m_slotnumber.toString(),Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_task.type),this.m_task.questPoints.toString(),this.manager.getOrderboardProgress().toString(),this.m_task.skipCashValue);
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSkipButtonAfterConfirmation(event);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickDumpButtonAfterConfirmation(event:Event) : void
      {
         if(!Global.player.getSeenFlag("FIRST_TIME_DUMP_SEEN"))
         {
            Global.player.setSeenFlag("FIRST_TIME_DUMP_SEEN");
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
            this.m_owner.showDumpTutorial();
         }
         this.m_dumpBt.enabled = false;
         this.m_dumpBt.visible = false;
         this.m_skipBt.visible = false;
         this.m_taskBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.visible = false;
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.visible = false;
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_addpointsTf.visible = true;
         this.m_addpointsTf.text = "Loading...";
         this.manager.dumpTask(this.m_slotnumber,this.m_owner.resumeWindow);
         StatsManager.count(this.m_featureName,"Trash",this.getKingdomText(),Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_task.type),"TaskSlot" + (this.m_slotnumber + 1).toString());
      }
      
      private function onAcceptDumpConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickDumpButtonAfterConfirmation(event);
         }
         else
         {
            this.m_dumpBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickSinkGoldButtonAfterConfirmation(event:Event) : void
      {
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
         this.m_taskBt.visible = false;
         this.m_skipBt.visible = false;
         this.m_dumpBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.visible = false;
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.visible = false;
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_addpointsTf.visible = true;
         this.m_addpointsTf.text = this.pointsEarnedString();
         this.manager.sinkGold(this.m_slotnumber,this.m_owner.refreshTaskFrame);
      }
      
      public function updateWeeklyProduceIcon() : void
      {
         if(this.m_produce_icon)
         {
            this.m_produce_icon.visible = true;
            this.m_produce_icon.loadIcon(this.manager.currentWeekSmallIcon);
            this.m_produce_icon.setIconSize(32,32);
         }
      }
      
      private function onAcceptSinkGoldConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSinkGoldButtonAfterConfirmation(event);
         }
         else
         {
            this.m_taskBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickSkip1ButtonDumpedTask(event:Event) : void
      {
         if(this.manager.isTaskDumped(this.m_slotnumber))
         {
            this.m_skip1Bt.enabled = false;
            this.m_skip1Bt.visible = false;
            this.m_trashTf.visible = false;
            this.m_animationMc.visible = true;
            MovieClipUtils.recursivePlay(this.m_animationMc);
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
            this.manager.skipDumpedTask(this.m_slotnumber,this.m_owner.resumeWindow);
            StatsManager.count(this.m_featureName,"SkipTrashedTask","","","","1");
         }
      }
      
      private function pointsEarnedString() : String
      {
         return "+" + this.m_task.questPoints.toString() + " " + this.manager.getWeekProduceName(this.m_task.questPoints) + " earned";
      }
      
      private function get manager() : FarmersMarketInnovationManager
      {
         return FarmersMarketInnovationManager.getInstance();
      }
      
      private function getKingdomText() : String
      {
         var result:String = "";
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
            case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
               result = "Open Reward";
               break;
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
               result = "Ask";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               result = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               result = "Craft";
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               result = "Harvest BB";
               break;
            default:
               if(this.m_task.action == QuestConstants.TASK_HARVEST_BY_CATEGORY)
               {
                  if(this.m_task.type == "AllDreamworldR1Animal")
                  {
                     result = "Harvest Animals";
                  }
                  else if(this.m_task.type == "AllDreamworldR1Trees")
                  {
                     result = "Harvest Trees";
                  }
               }
         }
         return result;
      }
      
      private function getPhylumText() : String
      {
         var item:FarmItem = null;
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "Elite Horse";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               result = "Harvest Buildable";
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
            case QuestConstants.TASK_USE_ITEM_BY_CODE:
               if(this.m_task.helperType == QuestConstants.HELPER_TYPE_PAN_TO_ITEM)
               {
                  result = "Big Buildable";
               }
               else
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
                  result = item.friendlyTitle;
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               result = this.m_task.type;
         }
         return result;
      }
      
      private function getIconUrl() : String
      {
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "assets/buildings/xfs_elitehorses_icon.png";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               if(this.m_task.type == "2gyy")
               {
                  result = "assets/buildings/bldg_xfs_harvestbuildable_built_6_icon.png";
               }
               else
               {
                  result = "assets/buildings/building_xfs_bigbuildable_10_icon.png";
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(this.m_task.type == this.BIG_BUILDABLE_ITEM_CODE)
               {
                  result = "assets/buildings/building_xfs_bigbuildable_10_icon.png";
               }
               else
               {
                  result = this.m_task.iconUrl;
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               if(this.m_task.type == "AllFarmfestAnimals")
               {
                  result = "assets/newsfeed/task_harvestAnimals_icon.png";
               }
               else if(this.m_task.type == "AllFarmfestTrees")
               {
                  result = "assets/newsfeed/task_harvestTrees_icon.png";
               }
               break;
            default:
               result = this.m_task.iconUrl;
         }
         return result;
      }
      
      private function getQuestTitleText(titleText:String) : String
      {
         var item:FarmItem = null;
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "Fill order No. " + this.m_task.level.toString() + " in the Greenhouse Stable";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               if(this.m_task.type == this.HARVEST_BUILDABLE_ITEM_CODE)
               {
                  result = "Earn reward No. " + (this.m_task.level - 1).toString() + " in the Festival Palace";
               }
               else
               {
                  result = "Raise your Valley Fair to Level " + (this.m_task.level - 1).toString();
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               if(this.m_task.type == "AllFarmfestAnimals")
               {
                  result = "Harvest " + this.m_task.total.toString() + " Valley Animals";
               }
               else if(this.m_task.type == "AllFarmfestTrees")
               {
                  result = "Harvest " + this.m_task.total.toString() + " Valley Trees";
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(this.m_task.type == this.BIG_BUILDABLE_ITEM_CODE)
               {
                  result = "Harvest the Valley Fair " + this.m_task.total.toString() + " times";
               }
               else
               {
                  result = titleText;
               }
               break;
            default:
               result = titleText;
         }
         return result;
      }
   }
}

