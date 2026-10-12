package Widgets.View.Frames
{
   import Engine.Utilities;
   import Widgets.Parser.XMLDialogParser;
   import Widgets.View.Core.ElementBase;
   import flash.display.Sprite;
   
   public class DialogContentBoxBase extends ElementBase
   {
      
      protected var m_background:Sprite = null;
      
      public function DialogContentBoxBase(aKeyValuePairs:Array, aTokenValues:Array)
      {
         super(aKeyValuePairs);
         this.m_background = this.createBG();
         addChild(this.m_background);
      }
      
      public function createBG() : Sprite
      {
         var uColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_COLOR);
         var nCornerRadius:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_CORNER_RADIUS);
         var nHeight:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_HEIGHT);
         var uStrokeColor:Number = getAttributeValue(XMLDialogParser.UINT_STYLE_KEY_STROKE_COLOR);
         var nStrokeThickness:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_STROKE_THICKNESS);
         var nWidth:Number = getAttributeValue(XMLDialogParser.NUM_STYLE_KEY_WIDTH);
         m_widthNoShadow = nWidth;
         m_heightNoShadow = nHeight;
         var pSprite:Sprite = new Sprite();
         Utilities.toggleInputOnlySelf(pSprite,false);
         var nX:Number = 0;
         var nY:Number = 0;
         pSprite.graphics.beginFill(uColor,1);
         pSprite.graphics.lineStyle(nStrokeThickness,uStrokeColor);
         pSprite.graphics.drawRoundRect(nX,nY,m_widthNoShadow,m_heightNoShadow,nCornerRadius,nCornerRadius);
         pSprite.graphics.endFill();
         return pSprite;
      }
   }
}

