package Classes.util
{
   import flash.filters.ColorMatrixFilter;
   
   public class ColorUtil
   {
      
      public function ColorUtil()
      {
         super();
      }
      
      public static function colorToMatrix(color:uint, a:Number) : Array
      {
         var r:Number = (color >> 16 & 0xFF) / 255;
         var g:Number = (color >> 8 & 0xFF) / 255;
         var b:Number = (color & 0xFF) / 255;
         return [r,0,0,0,0,0,g,0,0,0,0,0,b,0,0,0,0,0,a,0];
      }
      
      public static function getGreyscaleFilter() : ColorMatrixFilter
      {
         var matrix:Array = [0.2989,0.587,0.114,0,0,0.2989,0.587,0.114,0,0,0.2989,0.587,0.114,0,0,0,0,0,1,0];
         return new ColorMatrixFilter(matrix);
      }
      
      public static function getColorMatrixFilter(color:uint, alpha:Number) : ColorMatrixFilter
      {
         return new ColorMatrixFilter(colorToMatrix(color,alpha));
      }
      
      public static function lighten(color:uint, amount:Number) : uint
      {
         var rgb:RGB = RGB.separate(color);
         rgb.r += (255 - rgb.r) * amount;
         rgb.g += (255 - rgb.g) * amount;
         rgb.b += (255 - rgb.b) * amount;
         return rgb.combine();
      }
      
      public static function darken(color:uint, amount:Number) : uint
      {
         var rgb:RGB = RGB.separate(color);
         rgb.r -= rgb.r * amount;
         rgb.g -= rgb.g * amount;
         rgb.b -= rgb.b * amount;
         return rgb.combine();
      }
      
      public static function interpolate(color1:uint, color2:uint, i:Number) : uint
      {
         var rgb1:RGB = RGB.separate(color1);
         var rgb2:RGB = RGB.separate(color2);
         var ri:uint = rgb1.r + (rgb2.r - rgb1.r) * i;
         var gi:uint = rgb1.g + (rgb2.g - rgb1.g) * i;
         var bi:uint = rgb1.b + (rgb2.b - rgb1.b) * i;
         return RGB.combine(ri,gi,bi);
      }
      
      public static function distance(color1:uint, color2:uint) : Number
      {
         var r1:uint = uint(color1 >> 16 & 0xFF);
         var g1:uint = uint(color1 >> 8 & 0xFF);
         var b1:uint = uint(color1 & 0xFF);
         var r2:uint = uint(color2 >> 16 & 0xFF);
         var g2:uint = uint(color2 >> 8 & 0xFF);
         var b2:uint = uint(color2 & 0xFF);
         return Math.sqrt((r2 - r1) * (r2 - r1) + (g2 - g1) * (g2 - g1) + (b2 - b1) * (b2 - b1));
      }
      
      public static function randomColor() : uint
      {
         return Math.round(Math.random() * 16777215);
      }
      
      public static function getLuminance(color:uint, perceived:Boolean = false, fast:Boolean = true) : Number
      {
         var result:Number = NaN;
         var r:Number = (color >> 16 & 0xFF) / 255;
         var g:Number = (color >> 8 & 0xFF) / 255;
         var b:Number = (color & 0xFF) / 255;
         if(perceived)
         {
            if(fast)
            {
               result = 0.299 * r + 0.587 * g + 0.114 * b;
            }
            else
            {
               result = Math.sqrt(0.241 * Math.pow(r,2) + 0.691 * Math.pow(g,2) + 0.068 * Math.pow(b,2));
            }
         }
         else
         {
            result = 0.2126 * r + 0.7152 * g + 0.0722 * b;
         }
         return result;
      }
   }
}

class RGB
{
   
   public var r:uint;
   
   public var g:uint;
   
   public var b:uint;
   
   public function RGB()
   {
      super();
   }
   
   public static function separate(color:uint) : RGB
   {
      var rgb:RGB = new RGB();
      rgb.r = color >> 16 & 0xFF;
      rgb.g = color >> 8 & 0xFF;
      rgb.b = color & 0xFF;
      return rgb;
   }
   
   public static function combine(r:uint, g:uint, b:uint) : uint
   {
      return (r << 16) + (g << 8) + b;
   }
   
   public function combine() : uint
   {
      return RGB.combine(this.r,this.g,this.b);
   }
}
