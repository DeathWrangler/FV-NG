package Classes.Quest.helperactions
{
   public class ItemHelperAction extends QuestHelperAction
   {
      
      private var m_itemName:String = null;
      
      public function ItemHelperAction(questName:String, itemName:String)
      {
         super(questName);
         this.m_itemName = itemName;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
   }
}

