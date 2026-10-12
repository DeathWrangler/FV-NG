package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.DecoPointsManager;
   
   public class PhotoContestHelperAction extends QuestHelperAction
   {
      
      public function PhotoContestHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         DecoPointsManager.instance.openDecoPointsMainUI();
      }
      
      override public function canPerform() : Boolean
      {
         return DecoPointsManager.instance.getWeeklyContestName() != null;
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_OpenPhotoContest_Button");
      }
   }
}

