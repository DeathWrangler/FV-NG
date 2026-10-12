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
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmRunV5OrderBoardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunV5OrderboardSlot extends ZwSlotFrame
   {
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const TASK_BT:String = "task_bt";
      
      private static const TASK1_BT:String = "task1_bt";
      
      private static const DUMP_BT:String = "dump_bt";
      
      private static const DUMPBG_MC:String = "dumpBG_mc";
      
      private static const TASKBG_MC:String = "taskBG_mc";
      
      private static const REDEEMBG_MC:String = "redeemBG_mc";
      
      private static const SKIP_BT:String = "skip_bt";
      
      private static const SKIP1_BT:String = "skip1_bt";
      
      private static const TITLE_TF:String = "questtitle_tf";
      
      private static const COUNT_TF:String = "questdone_tf";
      
      private static const TRASH_TF:String = "trash_tf";
      
      private static const POINTS_MC:String = "points_mc";
      
      private static const POINTS_TF:String = "points_tf";
      
      private static const ADDPOINTS_TF:String = "addpoints_tf";
      
      private static const ANIMATION_MC:String = "animation_mc";
      
      private static const CHECKMARK_MC:String = "checkmark_mc";
      
      private static const COCONUTS_URL:String = "assets/consumables/consume_coconuts_icon.png";
      
      private static const JADE_URL:String = "assets/consumables/consume_jade_icon.png";
      
      public static const FEATURE_TRACKING:String = "GPF_FarmRunV5";
      
      private var m_featureName:String;
      
      private var m_titelTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_pointsTf:ZwTextField;
      
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
      
      private var m_redeemBG:ZwFrame;
      
      public var m_slotnumber:int;
      
      private var m_checkmark:MovieClip;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_owner:FarmRunV5OrderBoardWindow;
      
      private var m_genericPopup:GenericPopup;
      
      private var FIRST_TIME_DUMP_SEEN:String = "InnovationFirstTimeDump";
      
      public function FarmRunV5OrderboardSlot(featureName:String, element:DisplayObject, window:FarmRunV5OrderBoardWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[ICON_MC]));
         }
         if(m_element.hasOwnProperty(TASK_BT))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[TASK_BT],"Task",this.onClickTaskButton));
         }
         if(m_element.hasOwnProperty(TASK1_BT))
         {
            addWidget(this.m_task1Bt = new FarmAnimatedTextButton(m_element[TASK1_BT],"Show me!",this.onClickTask1ButtonGetNewTask));
         }
         if(m_element.hasOwnProperty(SKIP_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[SKIP_BT],"Complete","3",this.onClickSkipButton));
         }
         if(m_element.hasOwnProperty(SKIP1_BT))
         {
            addWidget(this.m_skip1Bt = new FarmAnimatedCashButton(m_element[SKIP1_BT],"Skip","2",this.onClickSkip1ButtonDumpedTask));
         }
         if(m_element.hasOwnProperty(DUMP_BT))
         {
            addWidget(this.m_dumpBt = new FarmAnimatedTextButton(m_element[DUMP_BT],"Trash",this.onClickDumpButton));
         }
         if(m_element.hasOwnProperty(TITLE_TF))
         {
            this.m_titelTf = new ZwTextField(m_element[TITLE_TF]);
         }
         if(m_element.hasOwnProperty(COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[COUNT_TF]);
         }
         if(m_element.hasOwnProperty(TRASH_TF))
         {
            this.m_trashTf = new ZwTextField(m_element[TRASH_TF]);
         }
         if(m_element.hasOwnProperty(POINTS_MC))
         {
            this.m_pointsMc = new ZwFrame(m_element[POINTS_MC]);
            if(m_element[POINTS_MC].hasOwnProperty(POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[POINTS_MC][POINTS_TF]);
            }
         }
         if(m_element.hasOwnProperty(ADDPOINTS_TF))
         {
            this.m_addpointsTf = new ZwTextField(m_element[ADDPOINTS_TF]);
         }
         if(m_element.hasOwnProperty(ANIMATION_MC))
         {
            this.m_animationMc = m_element[ANIMATION_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(DUMPBG_MC))
         {
            this.m_dumpBG = new ZwFrame(m_element[DUMPBG_MC]);
         }
         if(m_element.hasOwnProperty(TASKBG_MC))
         {
            this.m_taskBG = new ZwFrame(m_element[TASKBG_MC]);
         }
         if(m_element.hasOwnProperty(REDEEMBG_MC))
         {
            this.m_redeemBG = new ZwFrame(m_element[REDEEMBG_MC]);
         }
         if(m_element.hasOwnProperty(CHECKMARK_MC))
         {
            this.m_checkmark = m_element[CHECKMARK_MC] as MovieClip;
         }
      }
      
      private static function toggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      protected function get getSpecificSubTypeTitleResource() : String
      {
         return this.m_featureName + "_" + this.m_task.action + "_" + this.m_task.type + "_" + "_Description";
      }
      
      override public function populate(data:Object) : void
      {
         var tooltipText:String = null;
         var bushelQty:int = 0;
         var currType:String = null;
         super.populate(data);
         this.m_data = data;
         this.m_trashTf.visible = false;
         this.m_task1Bt.visible = false;
         this.m_skip1Bt.visible = false;
         this.m_checkmark.visible = false;
         this.m_animationMc.visible = false;
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(Boolean(data) && data.hasOwnProperty("questTask"))
         {
            this.m_task = data.questTask;
         }
         if(Boolean(data) && data.hasOwnProperty("questText"))
         {
            this.m_titelTf.text = data.questText;
            this.m_titelTf.visible = true;
            if(this.m_task.type == Currency.COINS)
            {
               this.m_titelTf.text = "Give 1000000 coins";
            }
         }
         if(this.m_task.iconUrl)
         {
            this.m_iconMc.visible = true;
            if(this.m_task.type == Currency.COCONUTS)
            {
               this.m_iconMc.loadIcon(COCONUTS_URL);
               this.m_titelTf.text = "Give 5000 coconuts";
            }
            else if(this.m_task.type == Currency.JADE)
            {
               this.m_iconMc.loadIcon(JADE_URL);
               this.m_titelTf.text = "Give 5000 Jade coins";
            }
            else
            {
               this.m_iconMc.loadIcon(this.m_task.iconUrl);
            }
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
         }
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            this.m_taskBt.enabled = this.m_task.canAskForHelp();
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("completed")) && Boolean(data.completed))
         {
            this.m_dumpBt.visible = false;
            this.m_skipBt.visible = false;
            this.m_taskBt.visible = true;
            this.m_taskBt.enabled = true;
            this.m_taskBt.text = "Redeem";
            this.m_redeemBG.visible = true;
            this.m_iconMc.visible = true;
            this.m_taskBG.visible = false;
            this.m_dumpBG.visible = false;
            this.m_titelTf.visible = true;
            this.manager.setRedeemCallout(true);
            StatsManager.count(FEATURE_TRACKING,"RedeemTask",this.getKingdomText(),this.m_task.titleText,this.manager.getFeatureProgress().toString(),this.manager.getFarmrunWorldFromPoints());
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
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_CONSUMABLE)
         {
            this.m_countTf.text = this.m_task.total.toString();
            if(!Global.player.canBuyWithCurrency(this.m_task.type,this.m_task.total,false))
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.callback = null;
               currType = this.m_task.type;
               if(currType == "jade")
               {
                  currType = "jade coins";
               }
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,"You don\'t have enough " + currType + "!");
            }
         }
         if(data.hasOwnProperty("isTaskComplete") && data.isTaskComplete == 1 || this.manager.getFarmrunWorldFromPoints() != Global.worldManager.currentWorldType || this.manager.getFeatureProgress() >= FarmRunV5Manager.VAL_FINAL_MILESTONE)
         {
            this.m_checkmark.visible = true;
            this.m_dumpBt.visible = false;
            this.m_skipBt.visible = false;
            this.m_taskBt.visible = false;
            this.m_task1Bt.enabled = false;
            this.m_task1Bt.visible = false;
            this.m_trashTf.visible = false;
            this.m_taskBt.enabled = false;
            this.m_redeemBG.visible = false;
            this.m_taskBG.visible = true;
            this.m_dumpBG.visible = false;
            this.m_iconMc.visible = false;
            this.m_countTf.visible = false;
            this.m_titelTf.visible = false;
         }
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
            case QuestConstants.HELPER_TYPE_SINK_CONSUMABLE:
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
         this.m_animationMc.gotoAndPlay(1);
         this.m_owner.tintWindow();
         this.m_owner.enableInput = false;
         this.manager.getNewTasks(this.m_slotnumber,this.m_owner.resumeWindow);
         StatsManager.count(this.m_featureName,"GetNewTask","","","TaskSlot" + (this.m_slotnumber + 1).toString());
      }
      
      private function onClickTaskButton(event:Event) : void
      {
         var confirmationText:String = null;
         var taskType:String = null;
         var confText:String = null;
         this.m_taskBt.enabled = false;
         if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
         {
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               this.manager.sinkBushel(this.m_slotnumber,this.m_owner.refreshTaskFrame);
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               this.m_dumpBt.visible = false;
               this.m_iconMc.visible = false;
               this.m_titelTf.visible = false;
               this.m_countTf.visible = false;
               if(this.m_iconMc.tooltip)
               {
                  this.m_iconMc.tooltip.release();
               }
               this.m_animationMc.visible = true;
               MovieClipUtils.recursivePlay(this.m_animationMc);
               this.m_animationMc.gotoAndPlay(1);
            }
            else
            {
               this.manager.redeemRewardPoints(this.m_slotnumber,this.m_owner.refreshTaskFrame);
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = false;
               this.m_dumpBt.visible = false;
               this.m_iconMc.visible = false;
               this.m_titelTf.visible = false;
               this.m_countTf.visible = false;
               if(this.m_iconMc.tooltip)
               {
                  this.m_iconMc.tooltip.release();
               }
               this.m_animationMc.visible = true;
               MovieClipUtils.recursivePlay(this.m_animationMc);
               this.m_animationMc.gotoAndPlay(1);
            }
            StatsManager.count(FEATURE_TRACKING,"PerformTask",this.getKingdomText(),this.m_task.titleText,this.manager.getFeatureProgress().toString(),this.manager.getFarmrunWorldFromPoints());
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
         {
            confirmationText = ZLocUtils.t("Dialogs","SinkGoldTaskConfirmation",{"quantity":this.m_task.total});
            this.m_genericPopup = UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSinkGoldConfirmation,"farmAnimatedTextConfirmation",true,true);
            if(this.m_genericPopup)
            {
               this.m_genericPopup.addEventListener("close",this.RedirectInput);
               this.m_taskBt.enabled = false;
               this.m_owner.tintWindow();
               this.m_owner.enableInput = false;
            }
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_CONSUMABLE)
         {
            taskType = this.m_task.type.toString();
            if(taskType == "jade")
            {
               taskType = "jade coins";
            }
            confText = ZLocUtils.t("Dialogs","SinkConsumablesTaskConfirmation",{
               "quantity":this.m_task.total.toString(),
               "unit":taskType
            });
            this.m_genericPopup = UI.displayMessage(confText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSinkConsumableConfirmation,"farmAnimatedTextConfirmation",true,true);
            if(this.m_genericPopup)
            {
               this.m_genericPopup.addEventListener("close",this.RedirectInput);
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
               this.m_owner.closeWindowForTasks();
            }
         }
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_data.skipCashValue});
         this.m_genericPopup = UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true);
         if(this.m_genericPopup)
         {
            this.m_genericPopup.addEventListener("close",this.RedirectInput);
            this.m_skipBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickDumpButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TrashTaskConfirmation");
         this.m_genericPopup = UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptDumpConfirmation,"farmAnimatedTextConfirmation",true,true);
         if(this.m_genericPopup)
         {
            this.m_genericPopup.addEventListener("close",this.RedirectInput);
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
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_animationMc.gotoAndPlay(1);
         this.manager.checkForOrderboardCompletion();
         this.manager.skipTask(this.m_slotnumber,this.m_owner.resumeWindow);
         StatsManager.count(FEATURE_TRACKING,"SkipTask",this.getKingdomText(),this.m_task.titleText,this.manager.getFeatureProgress().toString(),this.manager.getFarmrunWorldFromPoints(),this.m_task.skipCashValue);
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
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_animationMc.gotoAndPlay(1);
         this.manager.dumpTask(this.m_slotnumber,this.m_owner.resumeWindow);
         StatsManager.count(FEATURE_TRACKING,"Trash",this.getKingdomText(),this.m_task.titleText,"",this.manager.getFarmrunWorldFromPoints());
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
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_animationMc.gotoAndPlay(1);
         this.manager.sinkGold(this.m_slotnumber,this.m_owner.refreshTaskFrame);
      }
      
      private function onClickSinkConsumableButtonAfterConfirmation(event:Event) : void
      {
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
         this.m_taskBt.visible = false;
         this.m_skipBt.visible = false;
         this.m_dumpBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.visible = false;
         this.m_countTf.visible = false;
         if(this.m_iconMc.tooltip)
         {
            this.m_iconMc.tooltip.release();
         }
         this.m_animationMc.visible = true;
         MovieClipUtils.recursivePlay(this.m_animationMc);
         this.m_animationMc.gotoAndPlay(1);
         this.manager.sinkWorldCurrency(this.m_slotnumber,this.m_owner.refreshTaskFrame);
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
      
      private function onAcceptSinkConsumableConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSinkConsumableButtonAfterConfirmation(event);
         }
         else
         {
            this.m_taskBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function RedirectInput(event:Event) : void
      {
         if(this.m_genericPopup)
         {
            this.m_genericPopup.removeEventListener("close",this.RedirectInput);
            this.m_genericPopup = null;
         }
         Utilities.toggleInputAndChildren(Global.ui,false);
         Utilities.toggleInputAndChildren(this.manager.m_window,true);
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
            this.m_animationMc.gotoAndPlay(1);
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
            this.manager.skipDumpedTask(this.m_slotnumber,this.m_owner.resumeWindow);
            StatsManager.count(FEATURE_TRACKING,"SkipTrashedTask"," "," ",this.manager.getFeatureProgress().toString()," ",this.m_task.skipCashValue);
         }
      }
      
      private function get manager() : FarmRunV5Manager
      {
         return FarmRunV5Manager.getInstance(this.m_featureName);
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
   }
}

