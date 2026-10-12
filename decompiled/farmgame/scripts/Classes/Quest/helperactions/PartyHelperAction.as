package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.PartyManager;
   
   public class PartyHelperAction extends QuestHelperAction
   {
      
      private var m_partyId:String = null;
      
      public function PartyHelperAction(questName:String, partyId:String)
      {
         super(questName);
         this.m_partyId = partyId;
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         PartyManager.getInstance().displayPartyWindow(this.m_partyId);
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_Party_Button");
      }
   }
}

