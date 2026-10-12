package Display.Quests
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Display.FarmDynamicDialog;
   import Display.QueuedIcons.QuestQueuedIcon;
   import com.troyer.widget.view.BaseWidgetView;
   
   public class QuestDialog extends FarmDynamicDialog
   {
      
      protected var m_questObject:FarmQuest = null;
      
      protected var m_questProgress:Object = null;
      
      public function QuestDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.m_questObject = this.getImport(QuestQueuedIcon.QUEST_OBJECT_IMPORT_NAME);
         if(this.m_questObject != null)
         {
            this.m_questProgress = FarmQuestManager.getInstance().getQuestProgressByName(this.m_questObject.name);
         }
      }
   }
}

