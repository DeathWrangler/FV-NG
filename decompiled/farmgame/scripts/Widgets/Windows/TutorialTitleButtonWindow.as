package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class TutorialTitleButtonWindow extends TutorialAnimatedWindow
   {
      
      private var m_title:String = "";
      
      private var m_message:String = "";
      
      private var m_buttonString:String = "";
      
      public function TutorialTitleButtonWindow(title:String, message:String, buttonString:String, asset:String = "assets/dialogs/FV_Craft_tutorial_dialog_end.swf")
      {
         super(asset);
         this.m_title = title;
         this.m_message = message;
         this.m_buttonString = buttonString;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwWidget(m_window.tutorialEnd_mc));
         addWidget(new ZwTextField(m_window.tutorialEnd_mc.title_tf,this.m_title));
         addWidget(new ZwTextField(m_window.tutorialEnd_mc.generic_tf,this.m_message));
         addWidget(new FarmAnimatedTextButton(m_window.tutorialEnd_mc.okay_bt,this.m_buttonString,onClose));
      }
   }
}

