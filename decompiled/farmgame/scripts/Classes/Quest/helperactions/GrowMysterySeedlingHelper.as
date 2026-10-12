package Classes.Quest.helperactions
{
   import Display.UI;
   
   public class GrowMysterySeedlingHelper extends QuestHelperAction
   {
      
      public function GrowMysterySeedlingHelper(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         UI.displayMiniMarketDialog(["mysteryseedling"]);
      }
      
      override public function get readableText() : String
      {
         return "";
      }
   }
}

