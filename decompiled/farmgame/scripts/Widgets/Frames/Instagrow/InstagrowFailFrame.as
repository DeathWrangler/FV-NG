package Widgets.Frames.Instagrow
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class InstagrowFailFrame extends ZwFrame
   {
      
      public function InstagrowFailFrame(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwTextField(m_element.exclamation_tf,"?"));
         addWidget(new ZwFrame(m_element.biplane_mc));
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","InstantGrow_DialogFail")));
         addWidget(new FarmAnimatedTextButton(m_element.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onOkayClick));
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}

