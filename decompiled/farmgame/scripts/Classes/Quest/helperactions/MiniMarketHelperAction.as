package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   
   public class MiniMarketHelperAction extends QuestHelperAction
   {
      
      private var m_itemNames:Array = null;
      
      public function MiniMarketHelperAction(questName:String, itemNames:Array)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_itemNames = itemNames;
      }
      
      override public function perform() : void
      {
         super.perform();
         UI.displayMiniMarketDialog(this.m_itemNames);
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_OpenMarket_Button");
      }
   }
}

