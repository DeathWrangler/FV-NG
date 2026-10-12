package Display
{
   import Engine.Utilities;
   import flash.display.BlendMode;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class StrokeTextField extends TextField
   {
      
      protected const STROKE_BLUR:int = 3;
      
      protected const STROKE_STRENGTH:int = 200;
      
      public var strokeFilter:GlowFilter;
      
      public function StrokeTextField(strokeColor:uint = 0, strokeAlpha:Number = 0.8, strokeBlur:int = 3, strokeStrength:int = 200, innerStroke:Boolean = false)
      {
         super();
         this.strokeFilter = new GlowFilter(strokeColor,strokeAlpha,strokeBlur,strokeBlur,strokeStrength,1,innerStroke);
         this.filters = [this.strokeFilter];
         this.selectable = false;
         this.blendMode = BlendMode.LAYER;
         this.cacheAsBitmap = true;
         this.autoSize = TextFieldAutoSize.LEFT;
         Utilities.toggleInputOnlySelf(this,false);
         this.mouseWheelEnabled = false;
      }
      
      public function set toolTipText(value:String) : void
      {
         if(value)
         {
            this.htmlText = value;
         }
      }
      
      public function get toolTipText() : String
      {
         return this.htmlText;
      }
   }
}

