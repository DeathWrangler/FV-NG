package Widgets.ProgressBars
{
   import Classes.breeding.AnimalBreedingSkillState;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BreedingXpProgressBar extends FarmProgressBar
   {
      
      private static const TWEEN_TIME:Number = 2;
      
      protected var m_skillState:AnimalBreedingSkillState;
      
      protected var m_featureName:String;
      
      public function BreedingXpProgressBar(element:DisplayObject)
      {
         super(element);
      }
      
      public function setupProgressBarForLevel(skillState:AnimalBreedingSkillState, featureName:String) : void
      {
         this.m_featureName = featureName;
         this.m_skillState = skillState;
         if(m_bar != null)
         {
            this.maximum = Global.animalBreedingSettings.getXpForNextMilestone(this.m_skillState.level,this.m_featureName);
            this.minimum = 0;
            this.tweenTime = TWEEN_TIME;
            this.animated = true;
            this.progress = this.getUserXpForMilestone();
         }
      }
      
      public function addXp(amount:int) : void
      {
         this.animated = true;
         var progressIncrement:int = this.progress + amount;
         this.progress = progressIncrement;
         this.addEventListener(Event.COMPLETE,this.onTweenComplete);
         if(this.progress == this.maximum)
         {
            this.animated = false;
         }
      }
      
      public function onTweenComplete(event:Event) : void
      {
         if(m_progress == this.maximum)
         {
            if(m_bar != null)
            {
               this.reset();
            }
            this.removeEventListener(Event.COMPLETE,this.onTweenComplete);
            this.setupProgressBarForLevel(this.m_skillState,this.m_featureName);
         }
      }
      
      public function getUserXpForMilestone() : int
      {
         var result:int = 0;
         var xpForNextLevel:int = Global.animalBreedingSettings.getXpForNextMilestone(this.m_skillState.level,this.m_featureName);
         return int(this.m_skillState.xp - this.m_skillState.getNumMilestonesAcheived() * xpForNextLevel);
      }
   }
}

