package Widgets.Buttons
{
   import Widgets.Core.Interfaces.IZwSimpleText;
   import flash.display.MovieClip;
   import flash.text.TextFormat;
   
   public class FarmAnimatedTextButton extends FarmAnimatedMultiTextButton implements IZwSimpleText
   {
      
      public static const BUTTON_GENERIC_TF:String = "generic_tf";
      
      public static const BUTTON_TEXT_TF:String = "text_tf";
      
      public function FarmAnimatedTextButton(element:MovieClip, text:String = "", callback:Function = null, autoSize:Boolean = false, htmlText:Boolean = false)
      {
         var textButtonArray:Array = new Array();
         if(element.generic_tf)
         {
            textButtonArray[BUTTON_GENERIC_TF] = text;
         }
         if(element.text_tf)
         {
            textButtonArray[BUTTON_TEXT_TF] = text;
         }
         if(element.tabTitle_tf)
         {
            textButtonArray["tabTitle_tf"] = text;
         }
         super(element,textButtonArray,callback,autoSize,htmlText);
      }
      
      public function get text() : String
      {
         var fieldName:String = BUTTON_GENERIC_TF;
         if(m_textFields.hasOwnProperty(BUTTON_TEXT_TF))
         {
            fieldName = BUTTON_TEXT_TF;
         }
         return getText(fieldName);
      }
      
      public function set text(value:String) : void
      {
         var fieldName:String = BUTTON_GENERIC_TF;
         if(m_textFields.hasOwnProperty(BUTTON_TEXT_TF))
         {
            fieldName = BUTTON_TEXT_TF;
         }
         setText(fieldName,value);
      }
      
      public function get textFormat() : TextFormat
      {
         var fieldName:String = BUTTON_GENERIC_TF;
         if(m_textFields.hasOwnProperty(BUTTON_TEXT_TF))
         {
            fieldName = BUTTON_TEXT_TF;
         }
         return getTextFormat(fieldName);
      }
      
      public function set textFormat(value:TextFormat) : void
      {
         var fieldName:String = BUTTON_GENERIC_TF;
         if(m_textFields.hasOwnProperty(BUTTON_TEXT_TF))
         {
            fieldName = BUTTON_TEXT_TF;
         }
         setTextFormat(fieldName,value);
      }
   }
}

