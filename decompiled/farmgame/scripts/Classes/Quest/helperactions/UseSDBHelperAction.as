package Classes.Quest.helperactions
{
   import Display.UI;
   
   public class UseSDBHelperAction extends QuestHelperAction
   {
      
      public function UseSDBHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         UI.displayGiftBoxWindow(false,"Special Delivery");
      }
      
      override public function get readableText() : String
      {
         return "";
      }
   }
}

