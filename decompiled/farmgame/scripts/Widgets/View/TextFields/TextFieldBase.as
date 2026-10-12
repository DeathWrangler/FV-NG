package Widgets.View.TextFields
{
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.View.Core.ElementBase;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class TextFieldBase extends ElementBase
   {
      
      private var m_text:TextField = null;
      
      public function TextFieldBase(aKeyValuePairAttributes:Array, sText:String, aTokenValues:Array)
      {
         super(aKeyValuePairAttributes);
         m_originType = ElementBase.NUM_ORIGIN_TYPE_TOP_CENTER;
         this.createText(replaceTokens(sText,aTokenValues));
         addChild(this.m_text);
      }
      
      private function createText(sText:String) : void
      {
         var sAlign:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_ALIGN);
         sAlign = XMLDialogParser.convertAlignValueToTextFormatAlign(sAlign);
         var nForceHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var sStyle:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_STYLE);
         var uTextColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR);
         var nTextSize:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE);
         var nForceWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         if(this.m_text != null)
         {
            this.m_text = null;
         }
         this.m_text = new TextField();
         var textFormat:TextFormat = null;
         textFormat = new TextFormat("Merkin2",nTextSize,uTextColor,true);
         textFormat.align = sAlign;
         this.m_text.embedFonts = true;
         Utilities.toggleInputOnlySelf(this.m_text,false);
         this.m_text.autoSize = TextFieldAutoSize.LEFT;
         this.m_text.condenseWhite = true;
         this.m_text.wordWrap = true;
         this.m_text.multiline = true;
         this.m_text.selectable = false;
         this.m_text.textColor = 16777215;
         this.m_text.defaultTextFormat = textFormat;
         this.m_text.htmlText = sText;
         if(nForceWidth > 0)
         {
            this.m_text.width = nForceWidth;
         }
         else
         {
            this.m_text.width = this.m_text.textWidth;
         }
         if(nForceHeight > 0)
         {
            this.m_text.height = nForceHeight;
         }
         else
         {
            this.m_text.height = this.m_text.textHeight;
         }
         this.m_text.cacheAsBitmap = true;
         this.m_text.x = -this.m_text.width * 0.5;
         this.m_text.y = 0;
         m_widthNoShadow = this.m_text.width;
         m_heightNoShadow = this.m_text.height;
      }
      
      public function setHtmlText(s:String) : void
      {
         if(this.m_text == null)
         {
            return;
         }
         this.m_text.htmlText = s;
      }
   }
}

