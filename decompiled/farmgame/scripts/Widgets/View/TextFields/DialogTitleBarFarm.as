package Widgets.View.TextFields
{
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.Parser.XMLExtendableData;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class DialogTitleBarFarm extends DialogTitleBarBase
   {
      
      private static const STUD_DIAMETER:Number = 5;
      
      private static const STUD_INSET_X:Number = 12;
      
      private static const STUD_INSET_Y:Number = 5;
      
      public function DialogTitleBarFarm(aKeyValuePairs:Array, aTokenValues:Array)
      {
         super(aKeyValuePairs,aTokenValues);
      }
      
      override public function createTitleBG(aKeyValuePairs:Array, aTokenValues:Array) : Sprite
      {
         var ptTextNudge:Point = null;
         var nForceHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var uTextColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR);
         var nTextSize:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE);
         var nForceWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         var sText:String = getAttributeValue(XMLDialogParser.STR_STYLE_KEY_TEXT);
         ptTextNudge = getAttributeValue(XMLDialogParser.PT_STYLE_KEY_TEXT_NUDGE);
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
         var nWidth:Number = m_text.width;
         var nHeight:Number = m_text.height;
         if(!isNaN(nForceWidth))
         {
            nWidth = nForceWidth;
         }
         if(!isNaN(nForceHeight))
         {
            nHeight = nForceHeight;
         }
         m_widthNoShadow = nWidth;
         m_heightNoShadow = nHeight;
         var pSprite:Sprite = new Sprite();
         Utilities.toggleInputOnlySelf(pSprite,false);
         var nX:Number = -nWidth * 0.5;
         var nY:Number = ptTextNudge.y;
         pSprite.graphics.beginGradientFill(GradientType.LINEAR,[16775883,12751150,15586952,16775883],[1,1,1,1],[0,82,160,200]);
         pSprite.graphics.drawRoundRect(nX - 2,nY - 2,nWidth + 4,nHeight + 4,25,25);
         pSprite.graphics.endFill();
         pSprite.graphics.beginGradientFill(GradientType.LINEAR,[16571755,16775883,12751150,15586952,16775883],[1,1,1,1,1],[0,52,142,220,255]);
         pSprite.graphics.drawRoundRect(nX,nY,nWidth,nHeight,25,25);
         pSprite.graphics.endFill();
         var cornerStartX:Number = nX - 2;
         var cornerStartY:Number = nY - 3;
         this.drawStud(pSprite.graphics,cornerStartX + STUD_INSET_X,cornerStartY + STUD_INSET_Y);
         this.drawStud(pSprite.graphics,cornerStartX - STUD_INSET_X + nWidth,cornerStartY + STUD_INSET_Y);
         this.drawStud(pSprite.graphics,cornerStartX - STUD_INSET_X + nWidth,cornerStartY - STUD_INSET_Y + nHeight);
         this.drawStud(pSprite.graphics,cornerStartX + STUD_INSET_X,cornerStartY - STUD_INSET_Y + nHeight);
         return pSprite;
      }
      
      private function drawStud(graphics:Graphics, x:Number, y:Number) : void
      {
         var matrix:Matrix = new Matrix();
         matrix.createGradientBox(STUD_DIAMETER,STUD_DIAMETER,0,x,y);
         graphics.beginGradientFill(GradientType.RADIAL,[16775883,16435238],[1,1],[50,200],matrix);
         graphics.drawRoundRect(x,y,STUD_DIAMETER,STUD_DIAMETER,STUD_DIAMETER,STUD_DIAMETER);
         graphics.endFill();
      }
   }
}

