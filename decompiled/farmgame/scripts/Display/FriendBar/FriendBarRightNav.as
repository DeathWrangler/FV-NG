package Display.FriendBar
{
   import Classes.Constants.ClickTrackingConstants;
   import Display.SpriteButton;
   import Events.FriendBarEvent;
   import Managers.ClickTrackingManager;
   import flash.events.MouseEvent;
   
   public class FriendBarRightNav extends FriendBarNav
   {
      
      private static const X_POSITION:int = 577;
      
      private static const Y_POSITION:int = 462;
      
      private static const BUTTON_ROTATION:int = 0;
      
      private static const X_POSITION_SINGLESTEP_BUTTON:int = 5;
      
      private static const Y_POSITION_SINGLESTEP_BUTTON:int = 30;
      
      private static const X_POSITION_MULTISTEP_BUTTON:int = 0;
      
      private static const Y_POSITION_MULTISTEP_BUTTON:int = 60;
      
      private static const X_POSITION_SKIPEND_BUTTON:int = 0;
      
      private static const Y_POSITION_SKIPEND_BUTTON:int = 90;
      
      private static const MOVE_DISTANCE_SINGLE_STEP:int = -66;
      
      private static const MOVE_DISTANCE_MULTI_STEP:int = -528;
      
      private static const MOVE_DISTANCE_SKIP_END:int = 1;
      
      public function FriendBarRightNav()
      {
         super();
         this.x = X_POSITION;
         this.y = Y_POSITION;
         m_buttonRotation = BUTTON_ROTATION;
      }
      
      override public function set singleStepButton(newButton:SpriteButton) : void
      {
         super.singleStepButton = newButton;
         m_singleStep.x = X_POSITION_SINGLESTEP_BUTTON;
         m_singleStep.y = Y_POSITION_SINGLESTEP_BUTTON;
      }
      
      override public function set multiStepButton(newButton:SpriteButton) : void
      {
         super.multiStepButton = newButton;
         m_multiStep.x = X_POSITION_MULTISTEP_BUTTON;
         m_multiStep.y = Y_POSITION_MULTISTEP_BUTTON;
      }
      
      override public function set skipEndButton(newButton:SpriteButton) : void
      {
         super.skipEndButton = newButton;
         m_skipEnd.x = X_POSITION_SKIPEND_BUTTON;
         m_skipEnd.y = Y_POSITION_SKIPEND_BUTTON;
      }
      
      override protected function onSingleStep(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().sampleOrCount("fv_neighbor_bar_populate",ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_RIGHT_ARROW_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_SINGLE_ARROW);
         event.stopPropagation();
         dispatchEvent(new FriendBarEvent(FriendBarEvent.MOVE,MOVE_DISTANCE_SINGLE_STEP));
      }
      
      override protected function onMultiStep(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().sampleOrCount("fv_neighbor_bar_populate",ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_RIGHT_ARROW_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_DOUBLE_ARROW);
         event.stopPropagation();
         dispatchEvent(new FriendBarEvent(FriendBarEvent.MOVE,MOVE_DISTANCE_MULTI_STEP));
      }
      
      override protected function onSkipEnd(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().sampleOrCount("fv_neighbor_bar_populate",ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_RIGHT_ARROW_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_SINGLE_W_BAR);
         event.stopPropagation();
         dispatchEvent(new FriendBarEvent(FriendBarEvent.MOVE_END,MOVE_DISTANCE_SKIP_END));
      }
   }
}

