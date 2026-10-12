package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.util.ObjectUtil;
   import Engine.Managers.ErrorManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MultiStageQuestWidgetFactory
   {
      
      public function MultiStageQuestWidgetFactory()
      {
         super();
      }
      
      public static function getStageUI(questSettings:FarmQuest, window:DisplayObject, parentWindow:FarmWindow = null, stage:int = 1, completeCallBack:Function = null) : ZwBaseWidget
      {
         var stageWidget:ZwBaseWidget = null;
         var tasks:Vector.<FarmTask> = questSettings.farmTasks;
         var widget:String = tasks[0].widget;
         var stageWindow:MovieClip = window as MovieClip;
         var isTemplateUIEnabled:Boolean = false;
         if(Boolean(parentWindow) && Boolean(parentWindow as MultiStageQuestDialog) && (parentWindow as MultiStageQuestDialog).isTemplateUIEnabled())
         {
            isTemplateUIEnabled = true;
         }
         switch(tasks.length)
         {
            case 1:
               switch(tasks[0].action)
               {
                  case "completeFriendSet":
                     widget = Boolean(widget) && !isTemplateUIEnabled ? widget : "friendSet_mc";
                     if(ObjectUtil.pathExists(stageWindow,widget))
                     {
                        stageWidget = new StageCompleteFriendSetWidget(stageWindow[widget],questSettings,parentWindow,stage,completeCallBack);
                     }
                     break;
                  case "waitOrPay":
                     widget = Boolean(widget) && !isTemplateUIEnabled ? widget : "waiting_mc";
                     if(ObjectUtil.pathExists(stageWindow,widget))
                     {
                        stageWidget = new StageWaitingWidget(stageWindow[widget],questSettings,parentWindow,stage,completeCallBack);
                     }
                     break;
                  case "useItemByCode":
                     widget = Boolean(widget) && !isTemplateUIEnabled ? widget : "collectItem_mc";
                     if(ObjectUtil.pathExists(stageWindow,widget))
                     {
                        stageWidget = new StageCollectItemWidget(stageWindow[widget],questSettings,parentWindow,stage,completeCallBack);
                     }
               }
               break;
            case 3:
               if(tasks[0].action == QuestConstants.TASK_USE_ITEM_BY_CODE && tasks[1].action == QuestConstants.TASK_USE_ITEM_BY_CODE && tasks[2].action == QuestConstants.TASK_USE_ITEM_BY_CODE)
               {
                  widget = widget ? widget : "buildable_mc";
                  if(ObjectUtil.pathExists(window,widget))
                  {
                     stageWidget = new StageMultiCollectItemWidget(stageWindow[widget],questSettings,parentWindow,stage,completeCallBack);
                  }
               }
               else
               {
                  widget = widget ? widget : "quest_mc";
                  if(ObjectUtil.pathExists(window,widget))
                  {
                     stageWidget = new StageMultiTaskProgressWidget(stageWindow[widget],questSettings,parentWindow,stage,completeCallBack);
                  }
               }
         }
         if(stageWidget == null)
         {
            showMissingExportError(widget,questSettings.name);
         }
         return stageWidget;
      }
      
      private static function showMissingExportError(widget:String, questName:String) : void
      {
         ErrorManager.addError(questName + " UI Dialog is missing the following export: " + widget);
      }
   }
}

