package Widgets.Core.TextFields
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ZwTextField extends ZwWidget
   {
      
      private var m_html:Boolean = false;
      
      public function ZwTextField(element:TextField, text:String = "", html:Boolean = false, pkg:String = null, replacements:Object = null)
      {
         super(element);
         this.m_html = html;
         if(pkg)
         {
            this.text = ZLocUtils.t(pkg,text,replacements);
         }
         else
         {
            this.text = text;
         }
      }
      
      public function set text(value:String) : void
      {
         if(value == null)
         {
            value = "";
         }
         if(this.m_html)
         {
            m_element.htmlText = value;
         }
         else
         {
            m_element.text = value;
         }
         ZLocUtils.autoFormatSize(m_element as TextField);
      }
      
      public function get text() : String
      {
         return m_element.text;
      }
      
      public function set color(value:uint) : void
      {
         var textFormat:TextFormat = this.getTextFormat();
         textFormat.color = value;
         this.setTextFormat(textFormat);
      }
      
      public function get color() : uint
      {
         return uint(this.getTextFormat().color);
      }
      
      public function getTextFormat(beginIndex:int = -1, endIndex:int = -1) : TextFormat
      {
         return m_element.getTextFormat();
      }
      
      public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1) : void
      {
         m_element.setTextFormat(format,beginIndex,endIndex);
      }
      
      public function isMultiline() : Boolean
      {
         return m_element.multiline;
      }
      
      public function setMultiline(isMultiline:Boolean) : void
      {
         m_element.multiline = isMultiline;
      }
      
      public function get wordWrap() : Boolean
      {
         return m_element.wordWrap;
      }
      
      public function set wordWrap(isWordWrap:Boolean) : void
      {
         m_element.wordWrap = isWordWrap;
      }
      
      public function restrict(restrictedText:String, characterLimit:int = 0) : void
      {
         if(restrictedText != null && restrictedText != "")
         {
            m_element.restrict = restrictedText;
         }
         m_element.maxChars = characterLimit;
      }
      
      public function set selectable(toggleSelection:Boolean) : void
      {
         m_element.selectable = toggleSelection;
      }
   }
}

