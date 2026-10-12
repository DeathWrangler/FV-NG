package Widgets.View.Frames
{
   import Widgets.View.Core.ElementBase;
   import flash.display.Sprite;
   
   public class DialogBGBase extends ElementBase
   {
      
      public static const kStyle_Blue:String = "Blue";
      
      protected static const kSubStyle_BG:String = "_";
      
      protected var mmcBG:Sprite = null;
      
      public function DialogBGBase(aKeyValuePairs:Array, nWidth:Number, nHeight:Number, bDrawShadow:Boolean = true, sColorStyle:String = "Blue")
      {
         super(aKeyValuePairs);
         this.mmcBG = this.CreateBG(nWidth,nHeight,bDrawShadow,sColorStyle);
         if(this.mmcBG)
         {
            addChild(this.mmcBG);
         }
      }
      
      public function CreateBG(nWidth:Number, nHeight:Number, bDrawShadow:Boolean = true, sColorStyle:String = "Blue", sColorSubStyle:String = "_") : Sprite
      {
         return null;
      }
   }
}

