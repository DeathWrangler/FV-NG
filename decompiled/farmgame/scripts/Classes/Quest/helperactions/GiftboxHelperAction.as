package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   
   public class GiftboxHelperAction extends QuestHelperAction
   {
      
      public function GiftboxHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         UI.displayGiftBoxWindow(false);
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_Giftbox_Button");
      }
   }
}

