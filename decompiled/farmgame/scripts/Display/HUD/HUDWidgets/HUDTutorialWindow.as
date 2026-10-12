package Display.HUD.HUDWidgets
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class HUDTutorialWindow extends HUDWidget
   {
      
      private static const X_POSITION:int = 80;
      
      private static const Y_POSITION:int = 200;
      
      public static const SMALL_BUBBLE:int = 0;
      
      public static const LARGE_BUBBLE:int = 1;
      
      public static const EXTRA_LARGE_BUBBLE:int = 2;
      
      private var m_tutorialManager:HUDTutorialManager;
      
      private var m_smallBubble:ZwFrame;
      
      private var m_largeBubble:ZwFrame;
      
      private var m_extraLargeBubble:ZwFrame;
      
      private var m_smallText:ZwTextField;
      
      private var m_largeText:ZwTextField;
      
      private var m_extraLargeBubbleText:ZwTextField;
      
      private var m_continueButton:FarmAnimatedTextButton;
      
      private var m_skipButton:FarmAnimatedTextButton;
      
      public function HUDTutorialWindow(tutController:HUDTutorialManager)
      {
         super(tutController.getStateContainer().getAssetPath(),Global.hud);
         this.m_tutorialManager = tutController;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_loader.x = X_POSITION;
         m_loader.y = Y_POSITION;
         if(m_element.bubble_2_mc)
         {
            this.m_smallBubble = new ZwFrame(m_element.bubble_2_mc);
            addWidget(this.m_smallBubble,false);
            if(m_element.bubble_2_mc.generic_tf)
            {
               this.m_smallBubble.addWidget(this.m_smallText = new ZwTextField(m_element.bubble_2_mc.generic_tf));
            }
         }
         if(m_element.bubble_3_mc)
         {
            this.m_largeBubble = new ZwFrame(m_element.bubble_3_mc);
            addWidget(this.m_largeBubble,false);
            if(m_element.bubble_3_mc.generic_tf)
            {
               this.m_largeBubble.addWidget(this.m_largeText = new ZwTextField(m_element.bubble_3_mc.generic_tf));
            }
         }
         if(m_element.bubble_4_mc)
         {
            this.m_extraLargeBubble = new ZwFrame(m_element.bubble_4_mc);
            addWidget(this.m_extraLargeBubble,false);
            if(m_element.bubble_4_mc.generic_tf)
            {
               this.m_extraLargeBubble.addWidget(this.m_extraLargeBubbleText = new ZwTextField(m_element.bubble_4_mc.generic_tf));
            }
         }
         if(m_element.accept_bt)
         {
            this.m_continueButton = new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t_pk("Dialogs","Accept"),this.progressTutorial);
            addWidget(this.m_continueButton,false);
         }
         if(Boolean(this.m_tutorialManager) && Boolean(this.m_tutorialManager.getStateContainer()) && this.m_tutorialManager.getStateContainer().getHasSkipButton())
         {
            this.m_skipButton = new FarmAnimatedTextButton(m_element.skip_bt,ZLocUtils.t_pk("Dialogs","Skip"),this.skipTutorial);
            addWidget(this.m_skipButton);
         }
         else if(m_element.hasOwnProperty("skip_bt"))
         {
            (m_element.skip_bt as DisplayObject).visible = false;
         }
         this.m_tutorialManager.launchTutorial();
      }
      
      public function updateText(message:String, displayButton:Boolean = false, bubbleType:int = 0, buttonText:String = null) : void
      {
         if(this.m_continueButton)
         {
            this.m_continueButton.visible = displayButton;
            if(buttonText)
            {
               this.m_continueButton.text = buttonText;
            }
         }
         if(Boolean(this.m_tutorialManager) && Boolean(this.m_tutorialManager.getStateContainer()) && this.m_tutorialManager.getStateContainer().getHasSkipButton())
         {
            this.m_skipButton.visible = displayButton;
         }
         if(Boolean(this.m_smallBubble) && Boolean(this.m_largeBubble) && Boolean(this.m_extraLargeBubble))
         {
            this.m_smallBubble.visible = false;
            this.m_largeBubble.visible = false;
            this.m_extraLargeBubble.visible = false;
            switch(bubbleType)
            {
               case SMALL_BUBBLE:
                  this.m_smallBubble.visible = true;
                  this.m_largeBubble.visible = false;
                  this.m_extraLargeBubble.visible = false;
                  this.m_smallText.text = message;
               case LARGE_BUBBLE:
                  this.m_largeBubble.visible = true;
                  this.m_smallBubble.visible = false;
                  this.m_extraLargeBubble.visible = false;
                  this.m_largeText.text = message;
               case EXTRA_LARGE_BUBBLE:
                  this.m_extraLargeBubble.visible = true;
                  this.m_smallBubble.visible = false;
                  this.m_largeBubble.visible = false;
                  this.m_extraLargeBubbleText.text = message;
            }
         }
      }
      
      private function progressTutorial(event:Event) : void
      {
         this.m_tutorialManager.step();
      }
      
      private function skipTutorial(event:Event) : void
      {
         HUDTutorialManager.instance.stop();
      }
      
      public function toggleWindowVisibility(toggle:Boolean) : void
      {
         this.m_element.visible = toggle;
      }
   }
}

