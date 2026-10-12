package Classes.Idle
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.util.FarmGameUtil;
   import Display.ExpansionPromptPopup;
   import Display.UI;
   import Managers.FeatureOptionsManager;
   
   public class ExpansionPromptIdleTask extends BaseIdleTask
   {
      
      public static const EXPANSION_PROMPT_IDLE_PREREQ:String = "expansion_prompt_idle_active_user_prereq";
      
      protected var m_mouseDelay:Number = Global.flashHotParams["EXPANSION_PROMPT_MOUSE_IDLE_TIME"];
      
      public function ExpansionPromptIdleTask()
      {
         super();
         m_displaysPopup = true;
      }
      
      override public function get canFire() : Boolean
      {
         return this.canAfford() && this.isActiveUser() && this.notInCoolDown();
      }
      
      private function isActiveUser() : Boolean
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(EXPANSION_PROMPT_IDLE_PREREQ);
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            return true;
         }
         return false;
      }
      
      private function canAfford() : Boolean
      {
         var result:Boolean = false;
         var nextExpansion:ChangeFarmItem = Global.worldManager.getNextExpansion();
         if(nextExpansion != null)
         {
            result = nextExpansion.cash <= Global.player.cash || nextExpansion.cost <= Global.player.currentWorldCurrencyTotal;
         }
         return result;
      }
      
      private function notInCoolDown() : Boolean
      {
         return GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND >= Number(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.EXPANSION_PROMPT_IDLE,FeatureOptionsManager.EXPANSION_PROMPT_IDLE_NEXT_TIME));
      }
      
      override public function fire() : void
      {
         UI.displayPopup(new ExpansionPromptPopup());
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_mouseDelay;
      }
   }
}

