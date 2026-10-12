package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.ContextMenuQuestManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.MultiTaskProgressSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class StageMultiTaskProgressWidget extends AbstractStageWidget
   {
      
      private static const SLOT_PREFIX:String = "slot";
      
      private static const SLOT_POSTFIX:String = "_mc";
      
      public function StageMultiTaskProgressWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow = null, stage:int = 1, completeCallback:Function = null)
      {
         super(element,quest,parentWindow,stage);
         for(var index:int = 0; index < quest.farmTasks.length; index++)
         {
            if(m_element[SLOT_PREFIX + index.toString() + SLOT_POSTFIX])
            {
               addWidget(new MultiTaskProgressSlot(m_element[SLOT_PREFIX + index.toString() + SLOT_POSTFIX],quest,index,this.onCompleteTask));
            }
         }
         addWidget(new ZwTextField(m_element.stageNumber_tf,ZLocUtils.t("Dialogs","StageMultiTaskProgressWidget_stageNumber",{"num":stage.toString()})));
         addWidget(new ZwTextField(m_element.questDescription_tf,quest.bodyText));
         addWidget(new FarmIcon(m_element.questNpc_mc,quest.avatarHeadImage));
         var timeLeftSeconds:Number = (quest.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeLeftString:String = FarmGameUtil.toFriendlyTime(timeLeftSeconds,true);
         addWidget(new ZwTextField(m_element.expirationText_tf,timeLeftString));
         var mainUIOpenSessionSeenFlag:String = ContextMenuQuestManager.instance.mainUIOpenFlag(quest);
         Global.player.setSeenSessionFlag(mainUIOpenSessionSeenFlag,true);
      }
      
      private function onCompleteTask() : void
      {
         if(!FarmQuestManager.getInstance().isQuestActive(m_farmQuest.name))
         {
            m_parentWindow.close();
         }
      }
      
      override public function release() : void
      {
         var mainUIOpenSessionSeenFlag:String = ContextMenuQuestManager.instance.mainUIOpenFlag(m_farmQuest);
         Global.player.setSeenSessionFlag(mainUIOpenSessionSeenFlag,false);
         super.release();
      }
   }
}

