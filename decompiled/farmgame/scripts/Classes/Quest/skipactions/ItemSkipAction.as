package Classes.Quest.skipactions
{
   import Display.Quests.QuestProgressDialog;
   
   public class ItemSkipAction extends QuestSkipAction
   {
      
      protected var m_itemName:String = "";
      
      public function ItemSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog, itemName:String)
      {
         super(cost,questName,taskIndex,dialog);
         this.m_itemName = itemName;
      }
   }
}

