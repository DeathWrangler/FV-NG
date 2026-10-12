package Display.Quests
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.QuestToolConstant;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.CellController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ProgressBarController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.interfaces.ICellController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class QuestProgressDialog extends QuestDialog implements ICellController
   {
      
      public static const QUEST_PROGRESS_UNIQUE_NAME:String = "questProgressDialog";
      
      private var m_completeCell:BaseWidgetController = null;
      
      private var m_taskSkipDialog:GenericDialog = null;
      
      private var m_tasks:Array = null;
      
      private var m_taskProgress:Array = null;
      
      private var m_selectedTaskIndex:int = -1;
      
      private var m_buttonController:ButtonController = null;
      
      private var m_statsSampleRate:int = 100;
      
      private var m_skipTaskTimer:Timer = null;
      
      private var m_skipTaskTimerStarted:Boolean = false;
      
      private var m_skipAllPriceController:BaseWidgetController = null;
      
      public function QuestProgressDialog(view:BaseWidgetView)
      {
         super(view);
         this.m_statsSampleRate = parseInt(GlobalEngine.getFlashVar("QUEST_FEED_STATS_SAMPLE") as String);
      }
      
      public function onCellCreate(controllerName:String, index:int, newCell:BaseWidgetController) : BaseWidgetController
      {
         var finalCost:int = 0;
         var textController:BaseWidgetController = null;
         var items:Array = null;
         var helpMessage:String = null;
         var friendlies:Array = null;
         var item:FarmItem = null;
         var lastName:String = null;
         var taskFriendlyName:String = null;
         var prevName:String = null;
         var count:int = 0;
         var friendlyName:String = null;
         var childController:BaseWidgetController = null;
         var originalCost:int = 0;
         var originalTextController:BaseWidgetController = null;
         var currentCount:int = int(this.m_taskProgress[index]);
         var currentTask:FarmTask = this.m_tasks[index];
         var totalCount:int = currentTask.total;
         var completePercent:Number = currentCount / totalCount;
         var isComplete:Boolean = completePercent >= 1;
         var controller:BaseWidgetController = null;
         if(isComplete == false)
         {
            controller = newCell.getChildController("description");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,currentTask.getFlavorText());
            }
            controller = newCell.getChildController("askButton");
            if(controller != null)
            {
               if(!currentTask.hasHelper())
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
               }
               else
               {
                  textController = controller.getChildController("base.text");
                  if(textController != null)
                  {
                     textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,currentTask.helperText);
                  }
                  if(currentTask.canAskForHelp())
                  {
                     controller.index = index;
                     controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onAskButtonPress);
                  }
                  else
                  {
                     controller.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
                  }
               }
            }
            controller = newCell.getChildController("whatIsThisButton");
            if(controller != null)
            {
               controller.index = index;
               items = currentTask.getItemsList();
               helpMessage = "";
               if(items.length > 1 && Global.experimentManager.getExperimentVariant("fv_quest_whatisthis") > 1 && ZLocUtils.hasString("Dialogs",currentTask.action + "ActionTitle"))
               {
                  friendlies = new Array();
                  for each(item in items)
                  {
                     taskFriendlyName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
                     if(taskFriendlyName != "")
                     {
                        friendlies.push(taskFriendlyName);
                     }
                  }
                  friendlies.sort();
                  lastName = friendlies[friendlies.length - 1];
                  if(friendlies[0] != lastName)
                  {
                     helpMessage = ZLocUtils.t("Dialogs","QuestWhatIsThis",{"action":ZLocUtils.t("Dialogs",currentTask.action + "ActionTitle")}) + " ";
                     prevName = "";
                     count = 0;
                     for each(friendlyName in friendlies)
                     {
                        if(friendlyName != prevName)
                        {
                           if(friendlyName == lastName)
                           {
                              helpMessage += "and " + friendlyName + ".";
                              prevName = friendlyName;
                           }
                           else
                           {
                              if(count > Global.flashHotParams["QUEST_WHATISTHIS_MAXITEMS"])
                              {
                                 helpMessage += "etc...";
                                 break;
                              }
                              helpMessage += friendlyName + ", ";
                              prevName = friendlyName;
                              count++;
                           }
                        }
                     }
                  }
               }
               if(helpMessage != "")
               {
                  controller.listen(WidgetControllerEvent.BUTTON_PRESSED,ZCacheUtil.applyPartial(this.onHelpPressed,this,[helpMessage]));
               }
               else
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
               }
            }
            controller = newCell.getChildController("finishButton");
            finalCost = currentTask.cashValue;
            if(controller != null)
            {
               if(!this.canTaskBeSkipped(currentTask) || Boolean(this.m_skipTaskTimer))
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
               }
               controller.index = index;
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onSkipTaskButtonPress);
               childController = null;
               childController = controller.getChildController("base.pos.text");
               if(childController != null)
               {
                  childController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Skip"));
               }
               childController = controller.getChildController("base.pos.costText");
               if(childController != null)
               {
                  childController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,Utilities.formatNumber(finalCost));
               }
            }
            controller = newCell.getChildController("originalCostContainer");
            if(controller != null)
            {
               originalCost = currentTask.getStandardTaskSkipCost();
               if(finalCost == originalCost)
               {
                  controller.getView().alpha = 0;
                  controller.getView().visible = false;
                  controller.getView().parent.removeChild(controller.getView());
               }
               else
               {
                  originalTextController = controller.getChildController("originalCost.costText");
                  if(originalTextController != null)
                  {
                     originalTextController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,Utilities.formatNumber(originalCost));
                  }
               }
            }
         }
         else
         {
            newCell = this.m_completeCell.clone();
            controller = newCell.getChildController("vert.text");
            if(controller != null)
            {
               controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Done"));
            }
         }
         controller = newCell.getChildController("box.pos.left.title");
         if(controller != null)
         {
            controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,currentTask.titleText);
         }
         controller = newCell.getChildController("box.pos.right.progressText");
         if(controller != null)
         {
            controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","TaskComplete",{
               "quantity":currentCount,
               "total":totalCount
            }));
         }
         controller = newCell.getChildController("vert.bar");
         if(controller != null)
         {
            controller.setAttribute(ProgressBarController.ATTRIBUTE_PERCENT,completePercent);
         }
         controller = newCell.getChildController("vert.image");
         if(controller != null)
         {
            controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,currentTask.iconUrl);
         }
         return newCell;
      }
      
      override public function setup() : void
      {
         var numHalfSecondsToDelay:int = 0;
         var controller:BaseWidgetController = null;
         var skipAllController:BaseWidgetController = null;
         var discountTextController:BaseWidgetController = null;
         var skipAllTextController:BaseWidgetController = null;
         var discount:int = 0;
         super.setup();
         if(m_questProgress != null || QuestToolConstant.questToolOn)
         {
            this.m_completeCell = (this.getImport("questCompleteCell") as BaseWidgetView).getController();
            this.setUpHeader();
            numHalfSecondsToDelay = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_SKIP_TASK_DELAY);
            if(numHalfSecondsToDelay > 0)
            {
               this.m_skipTaskTimer = new Timer(numHalfSecondsToDelay * FarmGameUtil.NUM_MSECS_IN_SECOND / 2,1);
               this.m_skipTaskTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onSkipTaskShow);
               if(m_loaded)
               {
                  this.startSkipTaskTimer();
               }
            }
            this.refreshTaskCells();
            controller = null;
            controller = this.getChildController("okayButton");
            if(controller != null)
            {
               controller.setAttribute(ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("FarmGame","Close"));
            }
            controller = this.getChildController("skipButton");
            if(controller != null)
            {
               controller.setAttribute(ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Skip"));
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onSkipQuestButtonPress);
               if(m_questObject.skippable == false)
               {
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                  controller.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               }
            }
            skipAllController = this.getChildController("skipAllButton");
            discountTextController = this.getChildController("discountText");
            if(m_questObject.canBeSkipped())
            {
               if(skipAllController != null)
               {
                  skipAllController.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onSkipEntireQuestButtonPress);
                  skipAllTextController = skipAllController.getChildController("base.pos.text");
                  if(skipAllTextController != null)
                  {
                     skipAllTextController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","SkipAll"));
                  }
                  this.m_skipAllPriceController = skipAllController.getChildController("base.pos.costText");
                  this.setSkipAllPrice();
                  discount = m_questObject.getCashSkipDiscount();
                  if(discountTextController != null && discount > 0)
                  {
                     discountTextController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","SkipEntireQuestDiscount",{"discount":discount}));
                  }
               }
            }
            else
            {
               if(skipAllController != null)
               {
                  skipAllController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                  skipAllController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               }
               if(discountTextController != null)
               {
                  discountTextController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
                  discountTextController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               }
            }
         }
      }
      
      public function setSkipAllPrice() : void
      {
         if(m_questObject.canBeSkipped())
         {
            if(this.m_skipAllPriceController != null)
            {
               this.m_skipAllPriceController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,Utilities.formatNumber(m_questObject.getSkipQuestCashCost()));
            }
         }
      }
      
      private function startSkipTaskTimer() : void
      {
         if(Boolean(this.m_skipTaskTimer) && !this.m_skipTaskTimerStarted)
         {
            this.m_skipTaskTimerStarted = true;
            this.m_skipTaskTimer.start();
         }
      }
      
      override public function onDialogLoaded(event:Event) : void
      {
         super.onDialogLoaded(event);
         this.startSkipTaskTimer();
      }
      
      private function canTaskBeSkipped(farmTask:FarmTask) : Boolean
      {
         return farmTask.cashValue != 0;
      }
      
      private function onSkipTaskShow(timerEvent:TimerEvent) : void
      {
         var gridController:BaseWidgetController = null;
         var arrChildren:Array = null;
         var childView:BaseWidgetView = null;
         var childController:BaseWidgetController = null;
         var finishButtonController:BaseWidgetController = null;
         var iTask:int = 0;
         var nTask:int = 0;
         var farmTask:FarmTask = null;
         this.removeSkipTaskTimer();
         var controller:BaseWidgetController = this.getChildController("taskContent");
         if(controller)
         {
            gridController = controller.getChildController("grid");
            if(gridController)
            {
               arrChildren = gridController.getViewChildren();
               for each(childView in arrChildren)
               {
                  childController = childView.getController();
                  if(childController)
                  {
                     finishButtonController = childController.getChildController("finishButton");
                     if(finishButtonController)
                     {
                        iTask = finishButtonController.index;
                        nTask = int(this.m_tasks.length);
                        if(iTask >= 0 && iTask < nTask)
                        {
                           farmTask = this.m_tasks[iTask];
                           if(Boolean(farmTask) && this.canTaskBeSkipped(farmTask))
                           {
                              finishButtonController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function removeSkipTaskTimer() : void
      {
         if(this.m_skipTaskTimer)
         {
            this.m_skipTaskTimer.stop();
            this.m_skipTaskTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onSkipTaskShow);
            this.m_skipTaskTimer = null;
         }
      }
      
      private function generateValidTasks() : void
      {
         this.m_tasks = [];
         this.m_taskProgress = [];
         var numTasks:int = int(m_questObject.farmTasks.length);
         var farmTask:FarmTask = null;
         for(var taskIndex:int = 0; taskIndex < numTasks; taskIndex++)
         {
            farmTask = m_questObject.farmTasks[taskIndex];
            if(farmTask.shouldIgnore() == false)
            {
               this.m_tasks.push(farmTask);
               if(!QuestToolConstant.questToolOn)
               {
                  this.m_taskProgress.push(m_questProgress.progress[taskIndex]);
               }
            }
         }
      }
      
      private function setUpHeader() : void
      {
         var iconUrl:String = null;
         var circularProgressBarIconUrl:String = null;
         var expirationTimeSec:Number = NaN;
         var expirationText:String = null;
         var controller:BaseWidgetController = null;
         var iconController:BaseWidgetController = this.getChildController("optionalImage");
         if(iconController)
         {
            iconUrl = m_questObject.icon;
            if(iconUrl == FarmQuest.ICON_NONE)
            {
               iconController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
               iconController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            }
            else
            {
               circularProgressBarIconUrl = m_questObject.circularProgressBarIconUrl;
               if(circularProgressBarIconUrl)
               {
                  iconController.setAttribute(ImageController.ATTRIBUTE_SOURCE,circularProgressBarIconUrl);
                  iconController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
                  iconController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
               }
               else
               {
                  iconController.setAttribute(ImageController.ATTRIBUTE_SOURCE,iconUrl);
                  iconController.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,true);
                  iconController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,true);
               }
            }
         }
         var textController:BaseWidgetController = this.getChildController("expirationText");
         if(textController)
         {
            expirationTimeSec = m_questObject.expirationTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(expirationTimeSec != FarmQuest.QUEST_TIME_DO_NOT_EXPIRE)
            {
               expirationText = FarmGameUtil.getTimeLeftText(expirationTimeSec);
               textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,expirationText);
            }
         }
         controller = this.getChildController("avatarImage");
         if(controller != null)
         {
            controller.setAttribute(ImageController.ATTRIBUTE_SOURCE,m_questObject.avatarHeadImage);
         }
         controller = this.getChildController("titleText");
         if(controller != null)
         {
            controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_questObject.titleText);
         }
         controller = this.getChildController("description");
         if(controller != null)
         {
            controller.setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_questObject.bodyText);
         }
      }
      
      public function setSkipConfirmationDialog(dialog:GenericDialog) : void
      {
         if(this.m_taskSkipDialog != null)
         {
            this.m_taskSkipDialog.destroy();
         }
         this.m_taskSkipDialog = dialog;
      }
      
      override public function destroy() : void
      {
         if(this.m_taskSkipDialog != null)
         {
            this.m_taskSkipDialog.destroy();
            this.m_taskSkipDialog = null;
         }
         this.removeSkipTaskTimer();
         super.destroy();
      }
      
      private function onAskButtonPress(event:WidgetControllerEvent) : void
      {
         var isButtonDisabled:Boolean = false;
         var textController:BaseWidgetController = null;
         var buttonController:ButtonController = event.getController() as ButtonController;
         var index:int = buttonController.index;
         var farmTask:FarmTask = this.m_tasks[index];
         this.m_selectedTaskIndex = index;
         this.m_buttonController = buttonController;
         if(farmTask)
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","ask_button","button_press",farmTask.questName);
            isButtonDisabled = false;
            if(farmTask.canAskForHelp() == false)
            {
               isButtonDisabled = true;
               buttonController.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
               FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","ask_button","button_disabled",farmTask.questName);
            }
            else
            {
               farmTask.performHelperAction(this);
            }
            textController = null;
            if(isButtonDisabled == false && (farmTask.canAskForHelp() == false || farmTask.action == QuestConstants.TASK_USE_ITEM_BY_CODE))
            {
               buttonController.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
               textController = buttonController.getChildController("base.text");
               if(textController != null)
               {
                  textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Helper_AskForHelp_InProgress"));
               }
            }
            else
            {
               textController = buttonController.getChildController("base.text");
               if(textController != null)
               {
                  textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Helper_AskForHelp_CantAsk"));
               }
            }
         }
         else
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","ask_button","invalid_farmtask");
         }
      }
      
      private function onHelpPressed(helpMessage:String, event:WidgetControllerEvent) : void
      {
         UI.displayMessage(helpMessage,0,null,"",true);
      }
      
      public function setAskButtonState() : void
      {
         var farmTask:FarmTask = null;
         var textController:BaseWidgetController = null;
         if(this.m_selectedTaskIndex >= 0 && this.m_selectedTaskIndex < this.m_tasks.length && Boolean(this.m_buttonController))
         {
            farmTask = this.m_tasks[this.m_selectedTaskIndex];
            textController = this.m_buttonController.getChildController("base.text");
            if(farmTask.canAskForHelp())
            {
               this.m_buttonController.setAttribute(ButtonController.ATTRIBUTE_DISABLED,false);
               if(textController != null)
               {
                  textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Helper_AskForHelp_Button"));
               }
            }
            else
            {
               this.m_buttonController.setAttribute(ButtonController.ATTRIBUTE_DISABLED,true);
               if(textController != null)
               {
                  textController.setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Quests","Helper_AskForHelp_Sent"));
               }
            }
         }
         this.m_buttonController = null;
         this.m_selectedTaskIndex = -1;
      }
      
      private function onSkipTaskButtonPress(event:WidgetControllerEvent) : void
      {
         var index:int = event.getController().index;
         this.m_tasks[index].skip(this);
      }
      
      private function onSkipEntireQuestButtonPress(event:WidgetControllerEvent) : void
      {
         FarmQuestManager.showSkipQuestConfirmation(m_questObject.getSkipQuestCashCost(),QUEST_PROGRESS_UNIQUE_NAME,this.onAcceptSkipEntireQuest);
      }
      
      private function onAcceptSkipEntireQuest(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            m_questObject.skipQuest();
            this.destroy();
         }
      }
      
      private function onSkipQuestButtonPress(event:WidgetControllerEvent) : void
      {
         FarmQuestManager.getInstance().onSkipQuest(m_questObject);
         this.destroy();
      }
      
      public function refreshTaskCells() : void
      {
         var controller:BaseWidgetController = null;
         controller = this.getChildController("taskContent");
         if(controller != null)
         {
            controller.setAttribute(CellController.ATTRIBUTE_CREATE,this);
            this.generateValidTasks();
            controller.setAttribute(CellController.ATTRIBUTE_CELL_COUNT,this.m_tasks.length);
         }
      }
   }
}

