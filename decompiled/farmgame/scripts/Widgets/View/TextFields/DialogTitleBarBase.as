package Widgets.View.TextFields
{
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.Parser.XMLExtendableData;
   import Widgets.View.Core.*;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class DialogTitleBarBase extends ElementBase
   {
      
      private static const MAGIC_FLASH_NUMBER:Number = 4;
      
      private var m_mcTitle:Sprite = null;
      
      protected var m_text:TextField = null;
      
      public function DialogTitleBarBase(aKeyValuePairs:Array, aTokenValues:Array)
      {
         super(aKeyValuePairs);
         m_originType = ElementBase.NUM_ORIGIN_TYPE_TOP_CENTER;
         this.createTitleText(aKeyValuePairs,aTokenValues);
         this.m_mcTitle = this.createTitleBG(aKeyValuePairs,aTokenValues);
         addChild(this.m_mcTitle);
         this.m_mcTitle.addChild(this.m_text);
      }
      
      public function createTitleText(aKeyValuePairs:Array, aTokenValues:Array) : void
      {
         var nForceHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var nMaxWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_MAX_WIDTH);
         var uTextColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR);
         var nTextSize:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE);
         var nForceWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         var sTitle:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_TITLE);
         var rtMargin:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_MARGIN);
         var nMarginTop:Number = Number(rtMargin[XMLExtendableData.STR_RECT_TOP]);
         var nMarginLeft:Number = Number(rtMargin[XMLExtendableData.STR_RECT_LEFT]);
         var nMarginRight:Number = Number(rtMargin[XMLExtendableData.STR_RECT_RIGHT]);
         var nMarginBottom:Number = Number(rtMargin[XMLExtendableData.STR_RECT_BOTTOM]);
         var rtPadding:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_PADDING);
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         if(this.m_text != null)
         {
            this.m_text = null;
         }
         this.m_text = new TextField();
         var textFormat:TextFormat = null;
         textFormat = new TextFormat("Merkin2",nTextSize,uTextColor,true);
         textFormat.align = TextFormatAlign.CENTER;
         this.m_text.embedFonts = true;
         Utilities.toggleInputOnlySelf(this.m_text,false);
         if(!isNaN(nMaxWidth))
         {
            this.m_text.wordWrap = true;
            this.m_text.width = nMaxWidth;
         }
         this.m_text.selectable = false;
         this.m_text.textColor = 16777215;
         this.m_text.defaultTextFormat = textFormat;
         this.m_text.htmlText = sTitle;
         this.m_text.width = this.m_text.textWidth + nPaddingLeft + nPaddingRight;
         this.m_text.height = this.m_text.textHeight + MAGIC_FLASH_NUMBER;
         this.m_text.cacheAsBitmap = true;
         this.m_text.x = -this.m_text.width * 0.5;
      }
      
      public function createTitleBG(aKeyValuePairs:Array, aTokenValues:Array) : Sprite
      {
         var nShadowColor:Number = NaN;
         var ptShadowOffset:Point = null;
         var nForceHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var bDrawShadow:Boolean = getAttributeValue(XMLDialogParser.BOOL_STYLE_KEY_DRAW_SHADOW);
         var nForceWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         var ptTextNudge:Point = getAttributeValue(XMLDialogParser.PT_STYLE_KEY_TEXT_NUDGE);
         var rtMargin:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_MARGIN);
         var nMarginTop:Number = Number(rtMargin[XMLExtendableData.STR_RECT_TOP]);
         var nMarginLeft:Number = Number(rtMargin[XMLExtendableData.STR_RECT_LEFT]);
         var nMarginRight:Number = Number(rtMargin[XMLExtendableData.STR_RECT_RIGHT]);
         var nMarginBottom:Number = Number(rtMargin[XMLExtendableData.STR_RECT_BOTTOM]);
         var rtPadding:Array = getAttributeValue(XMLDialogParser.RECT_STYLE_KEY_PADDING);
         var nPaddingTop:Number = Number(rtPadding[XMLExtendableData.STR_RECT_TOP]);
         var nPaddingLeft:Number = Number(rtPadding[XMLExtendableData.STR_RECT_LEFT]);
         var nPaddingRight:Number = Number(rtPadding[XMLExtendableData.STR_RECT_RIGHT]);
         var nPaddingBottom:Number = Number(rtPadding[XMLExtendableData.STR_RECT_BOTTOM]);
         var nWidth:Number = this.m_text.width;
         var nHeight:Number = this.m_text.height;
         if(nForceWidth >= 0)
         {
            nWidth = nForceWidth;
         }
         if(nForceHeight > 0)
         {
            nHeight = nForceHeight;
         }
         m_widthNoShadow = nWidth;
         m_heightNoShadow = nHeight;
         var pSprite:Sprite = new Sprite();
         Utilities.toggleInputOnlySelf(pSprite,false);
         var nCornerRadius:Number = 0;
         var nLineThickness:Number = 0;
         var nX:Number = -nWidth * 0.5;
         var nY:Number = -nHeight * 0.5 + ptTextNudge.y;
         if(bDrawShadow)
         {
            nShadowColor = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_SHADOW_COLOR);
            ptShadowOffset = getAttributeValue(XMLDialogParser.PT_STYLE_KEY_SHADOW_OFFSET);
            pSprite.graphics.beginFill(nShadowColor,1);
            this.drawPath(pSprite,nX + ptShadowOffset.x,nY + ptShadowOffset.y,m_widthNoShadow,m_heightNoShadow);
            pSprite.graphics.endFill();
         }
         var nColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_COLOR);
         pSprite.graphics.beginFill(nColor,1);
         this.drawPath(pSprite,nX,nY,m_widthNoShadow,m_heightNoShadow);
         pSprite.graphics.endFill();
         return pSprite;
      }
      
      private function drawPath(pSprite:Sprite, x:Number, y:Number, w:Number, h:Number) : void
      {
         var square_coord:Array = new Array();
         square_coord.push(x - 3,y,x + w + 3,y,x + w - 3,y + h,x + 3,y + h,x - 3,y);
         var i:Number = 0;
         pSprite.graphics.moveTo(square_coord[i + 0],square_coord[i + 1]);
         i += 2;
         pSprite.graphics.lineTo(square_coord[i + 0],square_coord[i + 1]);
         i += 2;
         pSprite.graphics.lineTo(square_coord[i + 0],square_coord[i + 1]);
         i += 2;
         pSprite.graphics.lineTo(square_coord[i + 0],square_coord[i + 1]);
         i += 2;
         pSprite.graphics.lineTo(square_coord[i + 0],square_coord[i + 1]);
      }
   }
}

