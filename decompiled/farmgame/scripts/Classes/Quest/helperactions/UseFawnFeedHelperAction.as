package Classes.Quest.helperactions
{
   import Display.UI;
   
   public class UseFawnFeedHelperAction extends QuestHelperAction
   {
      
      public function UseFawnFeedHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         UI.displayMiniMarketDialog(["fawn_feed"]);
      }
      
      override public function get readableText() : String
      {
         return "";
      }
   }
}

