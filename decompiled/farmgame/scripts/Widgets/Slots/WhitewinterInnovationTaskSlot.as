package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.WhitewinterInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.WhitewinterInnovationWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class WhitewinterInnovationTaskSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TASK_BT:String = "task_bt";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SKIP_BT:String = "skip_bt";
      
      private const TITLE_TF:String = "questtitle_tf";
      
      private const COUNT_TF:String = "questdone_tf";
      
      private var m_titelTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_iconMc:FarmIcon;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      public var m_slotnumber:int;
      
      private var m_checkmark:MovieClip;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_owner:WhitewinterInnovationWindow;
      
      private var m_taskToolTip:FarmTextTooltip;
      
      public function WhitewinterInnovationTaskSlot(featureName:String, element:DisplayObject, window:WhitewinterInnovationWindow)
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
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[this.TASK_BT],"Task",this.doHelper));
         }
         if(m_element.hasOwnProperty(this.SKIP_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[this.SKIP_BT],"Skip","3",this.onClickSkipButton));
         }
         if(m_element.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titelTf = new ZwTextField(m_element[this.TITLE_TF]);
         }
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[this.COUNT_TF]);
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkmark = m_element[this.CHECKMARK_MC] as MovieClip;
            this.m_checkmark.visible = false;
         }
      }
      
      private function doHelper(ev:Event = null) : void
      {
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
         var taskTier:String = "";
         var task:String = "";
         var Cash:String = "";
         var Itemname:String = this.m_task.action.toString();
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            task = "Ask";
            taskTier = "0";
         }
         else if(this.m_task.action == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
         {
            task = "Craft";
            taskTier = "1";
         }
         else if(this.m_task.action == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
         {
            task = "SinkBushel";
            taskTier = "0";
         }
         FarmStatsManager.count("WhitewinterInnovation","PerformTask",Itemname,this.manager.getCurrentStage().toString(),taskTier);
         FarmStatsManager.count("WhitewinterInnovation",task,this.m_task.action.toString(),this.m_task.total.toString(),"",this.manager.getCurrentStage().toString());
      }
      
      override public function populate(data:Object) : void
      {
         var recipeItem:RecipeItem = null;
         var iconUrl:String = null;
         var canAsk:Boolean = false;
         var tooltipText:String = null;
         var lockedState:int = 0;
         super.populate(data);
         this.m_data = data;
         if(Boolean(data) && data.hasOwnProperty("task"))
         {
            this.m_task = data.task;
         }
         if(Boolean(data) && data.hasOwnProperty("taskSlotNumber"))
         {
            this.m_slotnumber = data.taskSlotNumber;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
         if(item)
         {
            this.m_iconMc.visible = true;
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
            {
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_task.type);
               this.m_iconMc.loadIcon(recipeItem.image70);
            }
            else
            {
               iconUrl = item.getImageByName("icon70");
               if(iconUrl != null && iconUrl != "")
               {
                  this.m_iconMc.loadIcon(iconUrl);
               }
               else
               {
                  this.m_iconMc.loadIcon(this.m_task.iconUrl);
               }
            }
         }
         if(this.m_task)
         {
            this.m_titelTf.text = this.m_task.titleText;
            this.m_titelTf.visible = true;
            this.m_taskBt.visible = true;
         }
         if(this.m_task)
         {
            this.setSkipButton(this.m_task.skipCashValue.toString());
         }
         if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            canAsk = this.m_task.canAskForHelp();
            if(canAsk == false)
            {
               this.m_taskBt.enabled = this.m_task.canAskForHelp();
               tooltipText = this.m_task.helperText;
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,tooltipText);
               this.m_taskBt.text = "Posted";
            }
            else
            {
               this.m_taskBt.enabled = true;
               this.m_taskBt.text = "Ask";
            }
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
         {
            this.setHelperText(this.m_task.helperText);
            if(this.manager.checkBushelUpdate())
            {
               this.m_taskBt.text = "Give";
               this.m_taskBt.callback = this.sinkBushel;
            }
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_CONSUMABLE)
         {
            this.m_titelTf.text = "Send " + this.m_task.total + " Letters to Santa";
            this.m_taskBt.text = "Do it!";
            this.m_taskBt.visible = true;
            if(this.m_skipBt)
            {
               this.m_skipBt.visible = false;
            }
            if(!this.manager.hasEnoughConsumableForSink(this.m_task.total))
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,"You don\'t have enough letters!");
               this.m_taskBt.element.mouseEnabled = this.m_taskBt.element.mouseChildren = true;
               if(this.m_taskToolTip)
               {
                  this.m_taskToolTip.detach();
               }
               this.m_taskBt.attachTooltip(this.m_taskToolTip = new FarmTextTooltip("You don\'t have enough letters!"));
            }
            else
            {
               this.m_taskBt.enabled = true;
               this.m_taskBt.detachTooltip();
               if(this.m_taskToolTip)
               {
                  this.m_taskToolTip.detach();
               }
               this.m_taskBt.callback = this.sinkConsumable;
            }
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
         {
            this.m_taskBt.text = "Craft";
            lockedState = CraftingManager.getInstance().isRecipeLocked(this.m_task.type);
            if(lockedState > 0)
            {
               this.m_taskBt.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState));
            }
            else
            {
               this.m_taskBt.detachTooltip();
            }
         }
         else
         {
            this.setHelperText(this.m_task.helperText);
         }
         this.setTaskProgress();
      }
      
      private function setHelperText(requestText:String) : void
      {
         var lockedState:int = 0;
         var recipeLocked:Boolean = false;
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
            case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
               requestText = "Open";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               requestText = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               requestText = "Craft";
               lockedState = CraftingManager.getInstance().isRecipeLocked(this.m_task.type);
               if(lockedState > 0)
               {
                  this.m_taskBt.callback = null;
                  this.m_taskBt.detachTooltip();
                  recipeLocked = true;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState));
                  this.m_taskBt.element.mouseEnabled = this.m_taskBt.element.mouseChildren = true;
                  if(this.m_taskToolTip)
                  {
                     this.m_taskToolTip.detach();
                  }
                  this.m_taskBt.attachTooltip(this.m_taskToolTip = new FarmTextTooltip(CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState)));
               }
               break;
            case QuestConstants.HELPER_TYPE_SINK_GOLD:
               requestText = ZLocUtils.t("Quests","Helper_Sink_Gold_Button");
               break;
            case QuestConstants.TASK_USE_ITEM_BY_CODE:
               if(!this.m_task.canAskForHelp())
               {
                  this.m_taskBt.element.generic_tf.text = "Posted";
                  this.m_taskBt.attachTooltip(new FarmTextTooltip(requestText));
               }
               else
               {
                  this.m_taskBt.enabled = true;
               }
               this.m_taskBt.visible = true;
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
            if(requestText != "Posted")
            {
               this.m_taskBt.enabled = true;
            }
            this.m_taskBt.visible = true;
         }
      }
      
      private function setSkipButton(cost:String) : void
      {
         if(this.m_skipBt)
         {
            this.m_skipBt.visible = true;
            this.m_skipBt.enabled = true;
            this.m_skipBt.setAmountText(cost);
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
      
      private function get manager() : WhitewinterInnovationManager
      {
         return WhitewinterInnovationManager.getInstance();
      }
      
      public function setTaskProgress() : void
      {
         var progress:int = 0;
         progress = this.manager.getTaskProgress(this.m_slotnumber);
         if(progress >= this.m_task.total)
         {
            this.m_checkmark.visible = true;
            if(this.m_skipBt)
            {
               this.m_skipBt.visible = false;
            }
            this.m_taskBt.visible = false;
            this.m_countTf.visible = false;
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
         {
            this.m_countTf.visible = true;
            progress = Math.min(CraftingManager.getInstance().getBushelQuantityInInventory(this.m_task.type),this.m_task.total);
            this.m_countTf.text = progress.toString() + "/" + this.m_task.total;
         }
         else if(this.m_task.helperType != QuestConstants.HELPER_TYPE_SINK_CONSUMABLE)
         {
            this.m_countTf.visible = true;
            this.m_countTf.text = progress.toString() + "/" + this.m_task.total;
         }
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_data.task.skipCashValue});
         if(parseInt(this.m_data.task.skipCashValue) >= 7)
         {
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
            {
               this.m_skipBt.enabled = false;
               this.m_owner.tintWindow();
               this.m_owner.enableInput = false;
            }
         }
         else
         {
            this.skipTask(event);
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.skipTask(event);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      public function skipTask(ev:Event = null) : void
      {
         var result:Boolean = this.manager.skipTask(this.m_slotnumber);
         if(result)
         {
            this.m_checkmark.visible = true;
            if(this.m_skipBt)
            {
               this.m_skipBt.visible = false;
            }
            this.m_taskBt.visible = false;
            this.m_countTf.visible = false;
         }
         this.m_skipBt.enabled = true;
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
      }
      
      public function sinkConsumable(ev:Event = null) : void
      {
         this.m_checkmark.visible = true;
         if(this.m_skipBt)
         {
            this.m_skipBt.visible = false;
         }
         this.m_taskBt.visible = false;
         this.manager.sinkConsumable();
      }
      
      public function sinkBushel(ev:Event = null) : void
      {
         this.m_checkmark.visible = true;
         if(this.m_skipBt)
         {
            this.m_skipBt.visible = false;
            this.m_skipBt.enabled = false;
         }
         if(this.m_taskBt)
         {
            this.m_taskBt.visible = false;
         }
         if(this.m_countTf)
         {
            this.m_countTf.visible = false;
            this.m_countTf.text = "";
         }
         this.manager.sinkbushel();
      }
   }
}

