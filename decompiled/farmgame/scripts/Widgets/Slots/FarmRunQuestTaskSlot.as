package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.FarmGameWorldEvent;
   import Managers.FarmRunQuestManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmRunQuestWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FarmRunQuestTaskSlot extends ZwSlotFrame
   {
      
      public var m_slotnumber:int;
      
      private var m_owner:FarmRunQuestWindow;
      
      private var m_quest_title:FarmTextField;
      
      private var m_quest_count:FarmTextField;
      
      private var m_task_button:FarmAnimatedTextButton;
      
      private var m_skip_button:FarmAnimatedCashButton;
      
      private var m_featurename:String;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_completeIcon:MovieClip;
      
      protected var m_item:FarmItem = null;
      
      private var m_worldType:String = "";
      
      public function FarmRunQuestTaskSlot(element:DisplayObject, owner:FarmRunQuestWindow, featureName:String)
      {
         this.m_featurename = featureName;
         this.m_owner = owner;
         super(element);
         if(m_element.hasOwnProperty("taskTitle_tf"))
         {
            this.m_quest_title = addWidget(new FarmTextField(m_element.taskTitle_tf as TextField,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("taskCount_tf"))
         {
            this.m_quest_count = addWidget(new FarmTextField(m_element.taskCount_tf as TextField,""),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("task_bt"))
         {
            this.m_task_button = addWidget(new FarmAnimatedTextButton(m_element.task_bt,"",this.doHelper)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            this.m_skip_button = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Buy","",this.skipTask)) as FarmAnimatedCashButton;
            this.m_skip_button.visible = true;
         }
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_completeIcon = m_element.completeIcon_mc as MovieClip;
            this.m_completeIcon.visible = false;
         }
         if(m_element.icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.icon_mc));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemBox:FarmIcon = null;
         this.m_data = data;
         if(Boolean(data) && data.hasOwnProperty("questTask"))
         {
            this.m_task = data.questTask;
         }
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(Boolean(data) && data.hasOwnProperty("questText"))
         {
            this.m_quest_title.text = data.questText;
            if(this.m_quest_title)
            {
               this.m_quest_title.visible = true;
            }
         }
         if(this.m_quest_count)
         {
            this.m_quest_count.text = "1/" + this.m_task.total;
            this.m_quest_count.visible = true;
         }
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
         if(Boolean(m_element) && Boolean(m_element["icon_mc"]))
         {
            itemBox = getWidget(m_element["icon_mc"]) as FarmIcon;
            if(itemBox)
            {
               itemBox.loadIcon(this.m_item.icon);
               itemBox.visible = true;
            }
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
         {
            this.setHelperText(data.helperText);
            this.setSkipButton(data.skipCashValue);
         }
         var CurrentWorldNum:Number = FarmRunQuestManager.getInstance().getCurrentWorldNum();
         if(CurrentWorldNum == 1)
         {
            this.m_worldType = WorldsConstants.WORLD_ID_TOYLAND;
         }
         else if(CurrentWorldNum == 2)
         {
            this.m_worldType = WorldsConstants.WORLD_ID_STORYBOOK;
         }
         else
         {
            this.m_worldType = WorldsConstants.WORLD_ID_SLEEPYHOLLOW;
         }
         this.setTaskProgress();
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_task;
         if(Boolean(this.m_task_button) && Boolean(task))
         {
            if(task.canAskForHelp())
            {
               this.m_task_button.enabled = true;
               this.m_task_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
            }
            else
            {
               this.m_task_button.enabled = false;
               this.m_task_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
            }
         }
      }
      
      private function doHelper(ev:Event = null) : void
      {
         var worldType:String = null;
         var hasUnlockedWorld:Boolean = false;
         if(Global.worldManager.currentWorldType != this.m_worldType)
         {
            worldType = this.m_worldType;
            if(Boolean(worldType) && worldType.length > 0)
            {
               hasUnlockedWorld = Global.worldManager.hasUnlockedWorld(worldType);
               if(hasUnlockedWorld)
               {
                  Global.worldManager.swapFarm(worldType,false);
                  Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
               }
            }
         }
         else
         {
            if(this.m_task)
            {
               this.m_task.performHelperAction(null,this.onAskFeedPosted);
            }
            if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               this.m_task_button.enabled = false;
               this.m_task_button.text = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
            }
            else
            {
               this.m_owner.close();
            }
         }
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         FarmRunQuestManager.getInstance().openFarmRunQuestUI();
      }
      
      public function setHelperText(requestText:String) : void
      {
         var recipe:FarmItem = null;
         if(Global.worldManager.currentWorldType != this.m_worldType)
         {
            this.m_task_button.text = "Travel";
            this.m_task_button.visible = true;
         }
         else
         {
            if(!this.m_task_button)
            {
               return;
            }
            if(requestText == "" || requestText == null)
            {
               this.m_task_button.visible = false;
               return;
            }
            this.m_task_button.text = requestText;
            this.m_task_button.visible = true;
         }
         if(this.m_task.action == QuestConstants.TASK_MAKE_RECIPE_BY_CODE)
         {
            if(this.m_quest_title)
            {
               recipe = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
               if(recipe)
               {
                  this.m_quest_title.text = "Make " + this.m_task.total + " " + recipe.friendlyTitle;
               }
            }
         }
      }
      
      public function skipTask(ev:Event = null) : void
      {
         var result:Boolean = FarmRunQuestManager.getInstance().skipTask(this.m_slotnumber);
         if(result)
         {
            this.m_completeIcon.visible = true;
            this.m_skip_button.visible = false;
            this.m_task_button.visible = false;
            this.m_quest_count.visible = false;
            this.m_owner.updateTaskFrame();
         }
      }
      
      private function setSkipButton(cost:String) : void
      {
         if(this.m_skip_button)
         {
            this.m_skip_button.visible = true;
            this.m_skip_button.setAmountText(cost);
            if(parseInt(cost) >= FarmAnimatedCashButton.DEFAULT_PAYMENT_CONFIRMATION_MINIMUM)
            {
               this.m_skip_button.showPaymentConfirmation = true;
            }
         }
         else
         {
            this.m_skip_button.visible = false;
         }
      }
      
      public function setTaskProgress() : void
      {
         var progress:int = FarmRunQuestManager.getInstance().getTaskProgress(this.m_slotnumber);
         if(progress >= this.m_task.total)
         {
            this.m_completeIcon.visible = true;
            this.m_skip_button.visible = false;
            this.m_task_button.visible = false;
            this.m_quest_count.visible = false;
         }
         else
         {
            this.m_quest_count.text = progress.toString() + "/" + this.m_task.total;
         }
      }
   }
}

