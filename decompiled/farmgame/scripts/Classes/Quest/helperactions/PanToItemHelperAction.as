package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.ItemFinderManager;
   
   public class PanToItemHelperAction extends QuestHelperAction
   {
      
      private var m_itemCode:String = null;
      
      public function PanToItemHelperAction(questName:String, itemCode:String)
      {
         super(questName);
         this.m_itemCode = itemCode;
      }
      
      override public function perform() : void
      {
         var itemName:String = null;
         super.perform();
         var items:Array = Global.world.getObjectsByCode(this.m_itemCode);
         if(Boolean(items) && items.length > 0)
         {
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_itemCode);
            ItemFinderManager.getInstance().highlightWorldItems(itemName);
         }
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_Pan_To_Item_Button");
      }
   }
}

