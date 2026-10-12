package Widgets.Frames.Breeding
{
   import Classes.breeding.AnimalBreedingSkillState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingXpMeter extends ZwFrame
   {
      
      public static const NUM_FRAMES_PER_MILESTONE:int = 75;
      
      private var m_levelText:ZwTextField = null;
      
      private var m_animation:MovieClip = null;
      
      private var m_targetFrameNum:int = 0;
      
      private var m_levelupAnimation:BreedingLevelUpAnimation = null;
      
      private var m_milestoneAnimation:BreedingMilestoneAnimation = null;
      
      private var m_skillState:AnimalBreedingSkillState = null;
      
      private var m_featureName:String;
      
      private var m_milestonesAcheived:int = 0;
      
      private var m_rewards:Object = null;
      
      public function BreedingXpMeter(element:DisplayObject)
      {
         super(element);
         this.m_animation = element as MovieClip;
      }
      
      public function setupMeterBarForLevel(skillState:AnimalBreedingSkillState, featureName:String) : void
      {
         this.m_featureName = featureName;
         this.m_skillState = skillState;
         this.m_milestonesAcheived = this.m_skillState.getNumMilestonesAcheived();
         this.m_levelText = new ZwTextField(this.m_animation.level_tf);
         this.updateText();
         this.updateMeter();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_animation.stop();
         this.m_animation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.m_animation = null;
         this.m_levelupAnimation = null;
         this.m_milestoneAnimation = null;
      }
      
      public function updateText() : void
      {
         this.m_levelText.text = this.m_skillState.level.toString();
         this.m_levelText.visible = true;
      }
      
      public function updateMeter() : void
      {
         var numMilestonesAcheived:int = this.m_skillState.getNumMilestonesAcheived();
         (this.m_animation as MovieClip).gotoAndStop(NUM_FRAMES_PER_MILESTONE * numMilestonesAcheived);
      }
      
      private function playAnimation(endframeNum:int) : void
      {
         this.m_targetFrameNum = endframeNum;
         this.m_animation.gotoAndPlay(this.m_animation.currentFrame);
         this.m_animation.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if((this.m_element as MovieClip).currentFrame == this.m_targetFrameNum && this.m_animation != null)
         {
            this.m_animation.stop();
            this.m_animation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            if(this.m_targetFrameNum == NUM_FRAMES_PER_MILESTONE * 3 && this.m_levelupAnimation != null)
            {
               this.m_levelupAnimation.playAnimation();
               this.updateText();
               this.updateMeter();
            }
            else if(this.m_milestoneAnimation != null)
            {
               this.m_milestoneAnimation.playAnimation(this.m_rewards);
            }
         }
      }
      
      public function checkMilestoneCompletion(rewards:Object) : void
      {
         this.m_rewards = rewards;
         var numMilestonesPerLevel:int = Global.animalBreedingSettings.getNumMilestonesPerLevel(this.m_featureName);
         var skillStateMilestonesAchieved:int = this.m_skillState.getNumMilestonesAcheived();
         if(skillStateMilestonesAchieved != this.m_milestonesAcheived)
         {
            if(skillStateMilestonesAchieved == 0)
            {
               if(this.m_milestonesAcheived == numMilestonesPerLevel)
               {
                  this.playAnimation((this.m_milestonesAcheived + 1) * NUM_FRAMES_PER_MILESTONE);
               }
               else
               {
                  this.m_animation.gotoAndStop(1);
               }
            }
            else
            {
               this.playAnimation(skillStateMilestonesAchieved * NUM_FRAMES_PER_MILESTONE);
            }
            this.m_milestonesAcheived = this.m_skillState.getNumMilestonesAcheived();
         }
      }
      
      public function set levelupAnimation(breedingLevelupAnimation:BreedingLevelUpAnimation) : void
      {
         this.m_levelupAnimation = breedingLevelupAnimation;
      }
      
      public function set milestoneAnimation(breedingMilestoneAnimation:BreedingMilestoneAnimation) : void
      {
         this.m_milestoneAnimation = breedingMilestoneAnimation;
      }
   }
}

