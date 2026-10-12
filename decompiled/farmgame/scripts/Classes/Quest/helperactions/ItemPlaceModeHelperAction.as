package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   
   public class ItemPlaceModeHelperAction extends ItemHelperAction
   {
      
      public function ItemPlaceModeHelperAction(questName:String, itemName:String)
      {
         super(questName,itemName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         super.perform();
         Global.world.enterForcePlaceMode(this.itemName);
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_Place_Button");
      }
   }
}

