package Widgets.View.Buttons
{
   import Widgets.Parser.XMLDialogParser;
   import Widgets.View.Core.*;
   import flash.display.CapsStyle;
   import flash.display.JointStyle;
   import flash.display.LineScaleMode;
   import flash.display.Shape;
   
   public class DialogXButtonBase extends ButtonBase
   {
      
      public function DialogXButtonBase(aKeyValuePairs:Array = null, aKeyValuePairsShadow:Array = null, aKeyValuePairsOut:Array = null, aKeyValuePairsOver:Array = null, aKeyValuePairsDown:Array = null, aKeyValuePairsDisabled:Array = null, aTokenValues:Array = null)
      {
         super(aKeyValuePairs,aKeyValuePairsShadow,aKeyValuePairsOut,aKeyValuePairsOver,aKeyValuePairsDown,aKeyValuePairsDisabled,aTokenValues);
         this.addXOnTop(aKeyValuePairs);
      }
      
      public function addXOnTop(aKeyValuePairs:Array) : void
      {
         var theX:Shape = new Shape();
         var nStrokeColor:Number = Number(aKeyValuePairs[XMLDialogParser.UINT_STYLE_KEY_TEXT_COLOR]);
         var nStrokeThickness:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_PIXEL_AMOUNT]);
         var nAlpha:Number = 1;
         var bPixelHinting:Boolean = true;
         theX.graphics.lineStyle(nStrokeThickness,nStrokeColor,nAlpha,bPixelHinting,LineScaleMode.NORMAL,CapsStyle.ROUND,JointStyle.ROUND);
         var nOffset:Number = Number(aKeyValuePairs[XMLDialogParser.NUM_STYLE_KEY_TEXT_SIZE]);
         theX.graphics.moveTo(-nOffset,-nOffset);
         theX.graphics.lineTo(nOffset,nOffset);
         theX.graphics.moveTo(-nOffset,nOffset);
         theX.graphics.lineTo(nOffset,-nOffset);
         this.m_textContainer.addChild(theX);
      }
   }
}

