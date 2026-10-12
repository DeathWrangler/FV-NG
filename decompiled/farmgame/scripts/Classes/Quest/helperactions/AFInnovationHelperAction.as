package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.AFInnovationManager;
   
   public class AFInnovationHelperAction extends QuestHelperAction
   {
      
      private var m_craftingSystem:String;
      
      public function AFInnovationHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         AFInnovationManager.getInstance().showMainUI();
      }
      
      override public function get readableText() : String
      {
         var zLocKey:String = "Helper_Open_Play_Match_Making";
         return ZLocUtils.getZLocString("Quests",zLocKey,zLocKey,"Button");
      }
   }
}

