package Classes.Pigo
{
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.filters.BevelFilter;
   import flash.filters.DropShadowFilter;
   import org.cove.ape.CircleParticle;
   
   public class PigoTokenParticle extends CircleParticle
   {
      
      public function PigoTokenParticle(x:Number, y:Number, radius:Number, fixed:Boolean = false, mass:Number = 1, elasticity:Number = 0.3, friction:Number = 0)
      {
         super(x,y,radius,fixed,mass,elasticity,friction);
      }
      
      public static function drawToken(element:Sprite, radius:Number) : void
      {
         element.graphics.clear();
         element.graphics.lineStyle(3,6684672,1);
         element.graphics.beginGradientFill(GradientType.RADIAL,[16176384,15892480],[1,1],[64,255]);
         element.graphics.drawCircle(0,0,radius);
         element.graphics.endFill();
         element.filters = [new BevelFilter(5,90,16777215,1,15892480,1,5,5,0.5),new DropShadowFilter(2,90,0,0.33,2,2)];
      }
      
      override public function init() : void
      {
         cleanup();
         drawToken(sprite,radius);
         sprite.cacheAsBitmap = true;
         paint();
      }
   }
}

