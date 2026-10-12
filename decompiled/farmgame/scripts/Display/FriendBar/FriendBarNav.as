package Display.FriendBar
{
   import Display.SpriteButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class FriendBarNav extends Sprite
   {
      
      protected var m_buttonRotation:int;
      
      protected var m_singleStep:SpriteButton;
      
      protected var m_multiStep:SpriteButton;
      
      protected var m_skipEnd:SpriteButton;
      
      public function FriendBarNav()
      {
         super();
      }
      
      public function set singleStepButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_singleStep)
            {
               this.m_singleStep.removeEventListener(MouseEvent.CLICK,this.onSingleStep);
               removeChild(this.m_singleStep);
            }
            this.m_singleStep = newButton;
            this.m_singleStep.buttonMode = true;
            this.m_singleStep.rotation = this.m_buttonRotation;
            this.m_singleStep.addEventListener(MouseEvent.CLICK,this.onSingleStep);
            addChild(this.m_singleStep);
         }
      }
      
      public function set multiStepButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_multiStep)
            {
               this.m_multiStep.removeEventListener(MouseEvent.CLICK,this.onMultiStep);
               removeChild(this.m_multiStep);
            }
            this.m_multiStep = newButton;
            this.m_multiStep.buttonMode = true;
            this.m_multiStep.rotation = this.m_buttonRotation;
            this.m_multiStep.addEventListener(MouseEvent.CLICK,this.onMultiStep);
            addChild(this.m_multiStep);
         }
      }
      
      public function set skipEndButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_skipEnd)
            {
               this.m_skipEnd.removeEventListener(MouseEvent.CLICK,this.onSkipEnd);
               removeChild(this.m_skipEnd);
            }
            this.m_skipEnd = newButton;
            this.m_skipEnd.buttonMode = true;
            this.m_skipEnd.rotation = this.m_buttonRotation;
            this.m_skipEnd.addEventListener(MouseEvent.CLICK,this.onSkipEnd);
            addChild(this.m_skipEnd);
         }
      }
      
      protected function onSingleStep(event:MouseEvent) : void
      {
      }
      
      protected function onMultiStep(event:MouseEvent) : void
      {
      }
      
      protected function onSkipEnd(event:MouseEvent) : void
      {
      }
   }
}

