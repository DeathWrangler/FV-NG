package Classes.Quest.helperactions
{
   import Classes.MystreeNursery;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.MystreeNurseryWindow;
   
   public class OpenMystreeHelperAction extends QuestHelperAction
   {
      
      public function OpenMystreeHelperAction(questName:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
      }
      
      override public function perform() : void
      {
         var mystreeBuilding:MystreeNursery = null;
         super.perform();
         var buildingArray:Array = Global.world.getObjectsByName("jacksmystreenursery");
         if(buildingArray.length > 0)
         {
            mystreeBuilding = buildingArray[0];
         }
         UI.displayPopup(new MystreeNurseryWindow(mystreeBuilding));
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_OpenMystree_Button");
      }
   }
}

