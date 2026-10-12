package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.ZItem.FarmItem;
   import Engine.Managers.ErrorManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class StageCollectItemProgressWidget extends ZwFrame
   {
      
      public function StageCollectItemProgressWidget(element:DisplayObject, quest:FarmQuest, itemIndex:Number)
      {
         var itemMc:MovieClip = null;
         super(element);
         var taskIndex:Number = 0;
         var taskItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(quest.farmTasks[taskIndex].type);
         var hasItemProgress:Boolean = quest.farmTasks[taskIndex].progress >= itemIndex;
         if(taskItem)
         {
            if(hasItemProgress && Boolean(element["itemOn_mc"] as MovieClip))
            {
               itemMc = m_element["itemOn_mc"] as MovieClip;
            }
            else if(m_element["itemOff_mc"] as MovieClip)
            {
               itemMc = m_element["itemOff_mc"] as MovieClip;
            }
            if(itemMc)
            {
               addWidget(new FarmIcon(itemMc,taskItem.iconUrl));
            }
            else
            {
               ErrorManager.addError("itemOn_mc and itemOff_mc are missing");
            }
         }
      }
   }
}

