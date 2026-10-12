package Widgets.Menu
{
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class FarmTabMenuButton extends FarmTabButton
   {
      
      public function FarmTabMenuButton(element:DisplayObjectContainer, text:String = "", callback:Function = null, textColor:String = null)
      {
         super(element,text,callback,textColor);
      }
      
      public function autoSizeWidth(padding:Number = 10) : void
      {
         var handle:uint = 0;
         var textField:ZwTextField = null;
         var textFieldElement:TextField = null;
         var stateHandles:Array = null;
         var widget:ZwWidget = null;
         var textHandles:Array = [m_textDisabledHandle,m_textSelectedHandle,m_textDeselectedHandle];
         for each(handle in textHandles)
         {
            textField = m_activeTextManager.getWidget(handle) as ZwTextField;
            textFieldElement = textField.element as TextField;
            textFieldElement.autoSize = TextFieldAutoSize.LEFT;
            textFieldElement.multiline = false;
            textFieldElement.wordWrap = false;
            textField.x = Math.round(padding - (textFieldElement.width - textFieldElement.textWidth) / 2);
         }
         stateHandles = [m_downStateHandle,m_overStateHandle,m_upStateHandle,m_disabledStateHandle];
         for each(handle in stateHandles)
         {
            widget = m_activeStateManager.getWidget(handle) as ZwWidget;
            widget.x = 0;
            widget.width = Math.round(textField.width + padding * 2);
         }
      }
   }
}

