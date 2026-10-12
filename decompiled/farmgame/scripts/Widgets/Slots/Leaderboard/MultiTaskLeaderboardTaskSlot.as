package Widgets.Slots.Leaderboard
{
   import Classes.Constants.QuestConstants;
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardTask;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Leaderboard.MultiTaskLeaderboardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MultiTaskLeaderboardTaskSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_data:LeaderboardTask;
      
      private var m_icon:FarmIcon;
      
      private var m_iconButton:FarmAnimatedButton;
      
      private var m_descriptionTextField:ZwTextField;
      
      public function MultiTaskLeaderboardTaskSlot(element:DisplayObject)
      {
         super(element);
         this.m_iconButton = addWidget(new FarmAnimatedButton(m_element.icon_button_mc,this.onIconButtonClick)) as FarmAnimatedButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_button_mc.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         (this.m_icon.element as MovieClip).mouseChildren = false;
         (this.m_icon.element as MovieClip).mouseEnabled = false;
         this.m_descriptionTextField = addWidget(new ZwTextField(m_element.generic_tf,"")) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var taskItemCode:String = null;
         var taskItem:FarmItem = null;
         super.populate(data);
         this.m_data = data as LeaderboardTask;
         if(data)
         {
            switch(this.m_data["action"])
            {
               case QuestConstants.TASK_HARVEST_BY_CODE:
               case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
                  this.m_iconButton.enabled = true;
            }
            this.m_iconButton.visible = true;
            this.m_icon.loadIcon(this.m_data["iconUrl"]);
            this.m_icon.visible = true;
            taskItemCode = this.m_data["type"];
            if(taskItemCode)
            {
               taskItem = Global.farmGameSettingsManager.getFarmItemByCode(taskItemCode);
               if(taskItem)
               {
                  this.m_descriptionTextField.text = taskItem.friendlyTitle;
                  this.m_descriptionTextField.visible = true;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_iconButton = null;
         this.m_descriptionTextField = null;
         super.release();
      }
      
      private function onIconButtonClick(event:MouseEvent) : void
      {
         var taskItemCode:String = null;
         var taskItemName:String = null;
         var itemNames:Array = null;
         var leaderboard:Leaderboard = null;
         var taskCounter:String = null;
         switch(this.m_data["action"])
         {
            case QuestConstants.TASK_HARVEST_BY_CODE:
               taskItemCode = this.m_data["type"];
               if(taskItemCode)
               {
                  taskItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(taskItemCode);
                  if(taskItemName)
                  {
                     itemNames = [taskItemName];
                     UI.displayMiniMarketDialog(itemNames);
                  }
               }
               break;
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
               taskItemCode = this.m_data["type"];
               if(taskItemCode)
               {
                  CraftingManager.getInstance().openCraftingUiForRecipe(taskItemCode);
               }
         }
         var parentWindow:MultiTaskLeaderboardWindow = getParentWindow() as MultiTaskLeaderboardWindow;
         if(parentWindow)
         {
            leaderboard = parentWindow.leaderboard;
            if(leaderboard)
            {
               taskCounter = this.m_data["action"] + "_" + this.m_data["type"];
               FarmStatsManager.sample(100,LeaderboardManager.STAT_COUNTER,"click","multitask_window_task",leaderboard.name,taskCounter);
            }
         }
         closeParentWindow();
      }
   }
}

