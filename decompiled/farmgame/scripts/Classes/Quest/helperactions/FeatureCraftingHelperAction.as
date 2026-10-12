package Classes.Quest.helperactions
{
   import Classes.util.ZLocUtils;
   import Managers.FeatureCraftingManager;
   
   public class FeatureCraftingHelperAction extends QuestHelperAction
   {
      
      private var m_craftingSystem:String;
      
      public function FeatureCraftingHelperAction(questName:String, craftingSystem:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_craftingSystem = craftingSystem;
      }
      
      override public function perform() : void
      {
         super.perform();
         FeatureCraftingManager.instance.showUI(this.m_craftingSystem);
      }
      
      override public function get readableText() : String
      {
         var zLocKey:String = "Helper_Open_FeatureCrafting_" + this.m_craftingSystem;
         return ZLocUtils.getZLocString("Quests",m_questName + zLocKey,zLocKey,"Button");
      }
   }
}

