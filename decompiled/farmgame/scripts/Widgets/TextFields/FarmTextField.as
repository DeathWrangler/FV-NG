package Widgets.TextFields
{
   import Classes.util.FarmGameUtil;
   import Engine.Utilities;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FarmTextField extends ZwTextField
   {
      
      public function FarmTextField(element:TextField, text:String = "", html:Boolean = false, censor:Boolean = false)
      {
         super(element,text,html);
         m_element.addEventListener(MouseEvent.CLICK,this.onFieldClick);
         if(censor)
         {
            m_element.addEventListener(Event.CHANGE,this.onTextChange);
         }
      }
      
      override public function release() : void
      {
         m_element.removeEventListener(MouseEvent.CLICK,this.onFieldClick);
         Global.overrideDebugKeys = false;
         super.release();
      }
      
      private function onFieldClick(event:MouseEvent) : void
      {
         Global.overrideDebugKeys = true;
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
      }
      
      private function onTextChange(event:Event) : void
      {
         if(FarmGameUtil.hasBadWord(text))
         {
            text = FarmGameUtil.censorString(text);
         }
      }
   }
}

