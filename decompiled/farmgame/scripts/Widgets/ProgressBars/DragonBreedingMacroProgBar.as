package Widgets.ProgressBars
{
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import flash.display.DisplayObject;
   
   public class DragonBreedingMacroProgBar extends FarmProgressBar
   {
      
      public static const NUM_LEVELS_PER_BAR:int = 30;
      
      private var m_featureName:String = null;
      
      private var m_skillState:DragonBreedingSkillState = null;
      
      private var m_maxDisplayedLevel:int = 0;
      
      public function DragonBreedingMacroProgBar(element:DisplayObject, featureName:String, maxDisplayLevel:int = 30)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_skillState = DragonBreedingManager.getInstance(this.m_featureName).getBreedingSkillState();
         this.m_maxDisplayedLevel = maxDisplayLevel;
         animated = true;
         this.setupBar();
      }
      
      public function setupBar() : void
      {
         var skillStateLevel:int = 0;
         maximum = this.m_maxDisplayedLevel;
         minimum = this.m_maxDisplayedLevel - NUM_LEVELS_PER_BAR;
         if(this.m_skillState)
         {
            skillStateLevel = this.m_skillState.level;
            if(skillStateLevel < this.m_maxDisplayedLevel)
            {
               progress = skillStateLevel + this.m_skillState.xp / DragonBreedingConfigManager.getInstance(this.m_featureName).getXpForLevel(skillStateLevel + 1);
            }
            else
            {
               progress = maximum;
            }
            update();
            m_element.positionIndicator_mc.x = m_initialSize.width * (progress / maximum);
         }
      }
      
      public function get maxDisplayedLevel() : int
      {
         return this.m_maxDisplayedLevel;
      }
   }
}

