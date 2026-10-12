package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.WinternordInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.WinternordInnovationMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class WinternordInnovationTaskSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TASK_BT:String = "task_bt";
      
      private const TASK1_BT:String = "task1_bt";
      
      private const DUMP_BT:String = "dump_bt";
      
      private const DUMPBG_MC:String = "dumpBG_mc";
      
      private const REDEEMBG_MC:String = "redeemBG_mc";
      
      private const TASKBG_MC:String = "taskBG_mc";
      
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
      
      private var m_titelTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_trashTf:ZwTextField;
      
      private var m_addpointsTf:ZwTextField;
      
      private var m_iconMc:FarmIcon;
      
      private var m_pointsMc:MovieClip;
      
      private var m_animationMc:MovieClip;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_task1Bt:FarmAnimatedTextButton;
      
      private var m_skip1Bt:FarmAnimatedCashButton;
      
      private var m_dumpBt:FarmAnimatedTextButton;
      
      private var m_dumpBG:ZwFrame;
      
      private var m_redeemBG:ZwFrame;
      
      private var m_taskBG:ZwFrame;
      
      private var m_redeemWidget:ZwFrame;
      
      public var m_slotnumber:int;
      
      private var m_checkmark:MovieClip;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_owner:WinternordInnovationMainWindow;
      
      private var m_isCallbackNull:Boolean = false;
      
      private var FIRST_TIME_DUMP_SEEN:String = "WinternordTaskDumpTutorial";
      
      public function WinternordInnovationTaskSlot(featureName:String, element:DisplayObject, window:WinternordInnovationMainWindow)
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
            this.m_pointsMc = m_element[this.POINTS_MC] as MovieClip;
            if(m_element[this.POINTS_MC].hasOwnProperty(this.POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[this.POINTS_MC][this.POINTS_TF]);
            }
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
         if(m_element.hasOwnProperty(this.REDEEMBG_MC))
         {
            this.m_redeemBG = new ZwFrame(m_element[this.REDEEMBG_MC]);
         }
         if(m_element.hasOwnProperty(this.TASKBG_MC))
         {
            this.m_taskBG = new ZwFrame(m_element[this.TASKBG_MC]);
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
         var modifiedIconUrl:String = null;
         var progress:int = 0;
         var total:int = 0;
         var userState:int = 0;
         var lockReason:String = null;
         var tooltipText:String = null;
         var bushelQty:int = 0;
         var lockedState:int = 0;
         super.populate(data);
         this.resetAllButtonsAndTextFeilds();
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(this.manager.hasActiveDayExpired())
         {
            modifiedIconUrl = "";
            progress = 0;
            total = 0;
            if(Boolean(data) && Boolean(data.hasOwnProperty("completed")) && Boolean(data.completed))
            {
               this.m_data = data;
               this.m_checkmark.visible = true;
               this.m_dumpBt.visible = false;
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = true;
               this.m_taskBt.enabled = true;
               this.m_redeemBG.visible = true;
               this.m_taskBt.text = "Redeem";
               if(Boolean(data) && data.hasOwnProperty("questTask"))
               {
                  this.m_task = data.questTask;
               }
               if(this.m_task.iconUrl)
               {
                  modifiedIconUrl = this.getIconUrl();
                  this.m_iconMc.visible = true;
                  this.m_iconMc.loadIcon(modifiedIconUrl);
               }
               if(Boolean(data) && data.hasOwnProperty("questText"))
               {
                  this.m_titelTf.text = this.getQuestTitleText(data.questText);
                  this.m_titelTf.visible = true;
               }
               if(Boolean(this.m_data) && this.m_data.hasOwnProperty("progress"))
               {
                  progress = int(this.m_data.progress);
                  total = int(this.m_task.total);
                  if(this.m_task.action == "expandStorageBuildingToLevelByCode")
                  {
                     progress--;
                     total--;
                  }
                  this.m_countTf.text = progress.toString() + "/" + total.toString();
                  this.m_countTf.visible = true;
                  if(this.manager.getDayEndMessageShown() == true)
                  {
                     this.m_pointsMc.visible = false;
                     this.m_pointsTf.visible = false;
                  }
                  else
                  {
                     this.m_pointsMc.visible = true;
                     this.m_pointsTf.visible = true;
                     this.m_pointsTf.text = this.m_task.questPoints.toString();
                  }
               }
               this.m_isCallbackNull = false;
               this.m_taskBt.detachTooltip();
            }
            else
            {
               this.m_dumpBt.enabled = false;
               this.m_dumpBt.visible = false;
               this.m_dumpBG.visible = true;
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               this.m_iconMc.visible = false;
               this.m_titelTf.visible = false;
               this.m_countTf.visible = false;
               this.m_pointsMc.visible = false;
               this.m_pointsTf.visible = false;
               this.m_addpointsTf.visible = true;
               this.m_addpointsTf.text = "Expired";
            }
         }
         else if(data.questType == "DummyTask")
         {
            userState = this.manager.getUserState();
            if(userState > this.manager.HARD)
            {
               if(userState == this.manager.LOCK1)
               {
                  lockReason = "Lock 1";
               }
               else if(userState == this.manager.LOCK2)
               {
                  lockReason = "Lock 2";
               }
               else if(userState == this.manager.DONE_FOR_THE_DAY)
               {
                  lockReason = "DONE FOR THE DAY";
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
               this.m_addpointsTf.visible = true;
               this.m_addpointsTf.text = lockReason;
            }
            else
            {
               this.m_dumpBG.visible = true;
               this.m_dumpBt.visible = false;
               this.m_countTf.visible = false;
               this.m_iconMc.visible = false;
               this.m_taskBt.visible = false;
               this.m_skipBt.visible = false;
               this.m_titelTf.visible = false;
               this.m_trashTf.visible = true;
               this.m_trashTf.text = "A New task is now available";
               this.m_task1Bt.enabled = true;
               this.m_task1Bt.visible = true;
               this.m_skip1Bt.visible = false;
            }
         }
         else
         {
            this.m_data = data;
            this.m_trashTf.visible = false;
            this.m_task1Bt.visible = false;
            this.m_skip1Bt.visible = false;
            this.m_checkmark.visible = false;
            this.m_animationMc.visible = false;
            this.m_addpointsTf.visible = false;
            if(Boolean(data) && data.hasOwnProperty("questTask"))
            {
               this.m_task = data.questTask;
            }
            if(this.m_task.iconUrl)
            {
               modifiedIconUrl = this.getIconUrl();
               this.m_iconMc.visible = true;
               this.m_iconMc.loadIcon(modifiedIconUrl);
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
               progress = int(this.m_data.progress);
               total = int(this.m_task.total);
               if(this.m_task.action == "expandStorageBuildingToLevelByCode")
               {
                  progress--;
                  total--;
               }
               this.m_countTf.text = progress.toString() + "/" + total.toString();
               this.m_countTf.visible = true;
            }
            if(this.manager.isTaskDumped(this.m_slotnumber))
            {
               this.m_dumpBG.visible = true;
               this.m_dumpBt.visible = false;
               this.m_redeemBG.visible = false;
               this.m_taskBG.visible = false;
               this.m_countTf.visible = false;
               this.m_iconMc.visible = false;
               this.m_taskBt.visible = false;
               this.m_skipBt.visible = false;
               this.m_titelTf.visible = false;
               this.m_trashTf.visible = true;
               this.m_isCallbackNull = false;
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
               this.m_redeemBG.visible = false;
               this.m_taskBG.visible = true;
               this.m_taskBt.callback = this.onClickTaskButton;
               this.m_isCallbackNull = false;
               this.m_dumpBt.visible = true;
               this.m_dumpBt.enabled = true;
               if(this.manager.getDayEndMessageShown() == true)
               {
                  this.m_pointsMc.visible = false;
                  this.m_pointsTf.visible = false;
               }
               else
               {
                  this.m_pointsMc.visible = true;
                  this.m_pointsTf.visible = true;
                  this.m_pointsTf.text = this.m_task.questPoints.toString();
               }
            }
            if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               this.m_taskBt.enabled = this.m_task.canAskForHelp();
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
               this.m_dumpBG.visible = true;
            }
            if(!this.m_taskBt.enabled)
            {
               tooltipText = data.helperText;
               this.m_taskBt.callback = null;
               this.m_isCallbackNull = true;
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
                  this.m_isCallbackNull = true;
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
            else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
            {
               lockedState = CraftingManager.getInstance().isRecipeLocked(this.m_task.type);
               if(lockedState > 0)
               {
                  this.m_taskBt.callback = null;
                  this.m_isCallbackNull = true;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState));
               }
            }
            if(!this.m_isCallbackNull)
            {
               this.m_taskBt.detachTooltip();
            }
         }
      }
      
      private function setSkipButton(cost:String) : void
      {
         this.m_skipBt.enabled = true;
         this.m_skipBt.visible = true;
         this.m_skipBt.setAmountText(cost);
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
         this.manager.getNewTask(this.m_slotnumber);
      }
      
      private function onClickTaskButton(event:Event) : void
      {
         var confirmationText:String = null;
         this.m_taskBt.enabled = false;
         if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
         {
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               this.manager.sinkBushel(this.m_slotnumber);
            }
            else
            {
               this.manager.redeemSlotTask(this.m_slotnumber);
            }
            this.m_animationMc.visible = true;
            this.m_animationMc.gotoAndPlay(1);
            this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
         {
            confirmationText = ZLocUtils.t("Dialogs","SinkGoldTaskConfirmation",{"quantity":this.m_task.total});
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSinkGoldConfirmation,"farmAnimatedTextConfirmation",true,true))
            {
               this.m_taskBt.enabled = false;
               this.m_owner.tintWindow();
               this.m_owner.enableInput = false;
            }
         }
         else
         {
            StatsManager.count(this.m_featureName,this.getKingdomText(),this.getPhylumText(),this.m_task.total.toString());
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
      }
      
      public function listenForAnimationEnd(e:Event = null) : void
      {
         if(this.m_animationMc.currentFrame == 40)
         {
            this.m_animationMc.gotoAndStop(1);
            this.m_animationMc.visible = false;
            this.m_animationMc.removeEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false);
         }
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_data.skipCashValue});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickDumpButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TrashTaskConfirmation");
         if(this.m_owner)
         {
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptDumpConfirmation,"farmAnimatedTextConfirmation",true,true))
         {
            this.m_dumpBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickSkipButtonAfterConfirmation(event:Event) : void
      {
         this.manager.skipTask(this.m_slotnumber,this.m_owner.resumeWindow);
         if(Global.player.canBuyCash(this.m_task.skipCashValue))
         {
            this.m_animationMc.visible = true;
            this.m_animationMc.gotoAndPlay(1);
            this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         }
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
         StatsManager.count(this.m_featureName,"Trash",this.getKingdomText(),this.getPhylumText(),"TaskSlot" + (this.m_slotnumber + 1).toString());
         this.manager.dumpTask(this.m_slotnumber);
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
         this.m_animationMc.visible = true;
         this.m_animationMc.gotoAndPlay(1);
         this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
         this.manager.sinkGold(this.m_slotnumber);
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
         var confirmationText:String = null;
         if(this.manager.isTaskDumped(this.m_slotnumber))
         {
            if(!this.manager.isTaskDumpTimeOver(this.m_slotnumber))
            {
               this.manager.skipDumpedTask(this.m_slotnumber);
            }
            else
            {
               confirmationText = "Wait time is already elapsed";
               UI.displayMessage(confirmationText,GenericPopup.TYPE_OK,this.manager.mainWindow.refreshTaskFrame,"",true);
            }
         }
      }
      
      private function get manager() : WinternordInnovationManager
      {
         return WinternordInnovationManager.getInstance(this.m_featureName);
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
      
      private function getQuestTitleText(titleText:String) : String
      {
         var item:FarmItem = null;
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "Fill " + this.m_task.level.toString() + " orders in the Yuletide Stable";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               if(this.m_task.type == "2112")
               {
                  result = "Earn reward No. " + (this.m_task.level - 1).toString() + " in the Nisse House";
               }
               else
               {
                  result = "Level up the Viken\'s Stave to " + (this.m_task.level - 1).toString();
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               if(this.m_task.type == "AllWinternordAnimals")
               {
                  result = "Harvest " + this.m_task.total.toString() + " Fable Animals";
               }
               else if(this.m_task.type == "AllWinternordTrees")
               {
                  result = "Harvest " + this.m_task.total.toString() + " Fable Trees";
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(this.m_task.type == "213i")
               {
                  result = "Harvest Hotel Sanctuary 1 time";
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
      
      private function getIconUrl() : String
      {
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "assets/buildings/xwx_elitehorses_icon.png";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               if(this.m_task.type == "2112")
               {
                  result = "assets/buildings/bldg_xwx_harvestbuildable_built_6_icon.png";
               }
               else
               {
                  result = "assets/buildings/building_xwx_bigbuildable_10_icon.png";
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(this.m_task.type == "213i")
               {
                  result = "assets/buildings/building_xwx_bigbuildable_10_icon.png";
               }
               else
               {
                  result = this.m_task.iconUrl;
               }
               break;
            default:
               result = this.m_task.iconUrl;
         }
         return result;
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
      
      private function resetAllButtonsAndTextFeilds() : void
      {
         this.m_dumpBt.enabled = false;
         this.m_dumpBt.visible = false;
         this.m_skipBt.enabled = false;
         this.m_skipBt.visible = false;
         this.m_taskBt.enabled = false;
         this.m_taskBt.visible = false;
         this.m_task1Bt.enabled = false;
         this.m_task1Bt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.text = "";
         this.m_titelTf.visible = false;
         this.m_countTf.text = "";
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.text = "";
         this.m_pointsTf.visible = false;
         this.m_addpointsTf.text = "";
         this.m_addpointsTf.visible = false;
         this.m_checkmark.visible = false;
         this.m_animationMc.visible = false;
         this.m_dumpBG.visible = false;
      }
   }
}

