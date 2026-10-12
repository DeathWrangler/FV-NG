package Widgets.Frames.Breeding
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingMilestoneAnimation extends ZwFrame
   {
      
      public static const MILESTONES:String = "milestones";
      
      public static const REWARD_ITEM_CODE:String = "value";
      
      public static const REWARD_QUANTITY:String = "quantity";
      
      private var m_milestoneAnimation:MovieClip = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_rewardQuantity:ZwTextField = null;
      
      public function BreedingMilestoneAnimation(element:DisplayObject)
      {
         super(element);
         this.m_milestoneAnimation = this.m_element.prizeAnimation_mc as MovieClip;
         this.m_rewardIcon = addWidget(new FarmIcon(this.m_milestoneAnimation.prize_mc)) as FarmIcon;
         this.m_rewardQuantity = addWidget(new ZwTextField(this.m_milestoneAnimation.qty_tf)) as ZwTextField;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_milestoneAnimation.stop();
         this.m_milestoneAnimation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.m_rewardIcon = null;
         this.m_rewardQuantity = null;
         this.m_milestoneAnimation = null;
      }
      
      public function playAnimation(rewards:Object) : void
      {
         var rewardItem:FarmItem = null;
         if(rewards != null)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rewards[MILESTONES][0][REWARD_ITEM_CODE]);
            if(rewardItem != null)
            {
               this.m_rewardIcon.loadIcon(rewardItem.icon);
               this.m_rewardIcon.setIconSize(40,40);
            }
            this.m_rewardQuantity.text = rewards[MILESTONES][0][REWARD_QUANTITY];
         }
         this.m_milestoneAnimation.visible = true;
         this.m_rewardIcon.visible = true;
         this.m_rewardQuantity.visible = true;
         this.m_milestoneAnimation.gotoAndPlay(0);
         this.m_milestoneAnimation.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(this.m_element.currentFrame == this.m_element.totalFrames && this.m_milestoneAnimation != null)
         {
            this.m_milestoneAnimation.stop();
            this.m_milestoneAnimation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_milestoneAnimation.visible = false;
         }
      }
   }
}

