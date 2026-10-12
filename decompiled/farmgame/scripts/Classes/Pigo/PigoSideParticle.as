package Classes.Pigo
{
   import flash.filters.BevelFilter;
   import flash.filters.DropShadowFilter;
   import org.cove.ape.RectangleParticle;
   
   public class PigoSideParticle extends RectangleParticle
   {
      
      public function PigoSideParticle(x:Number, y:Number, width:Number, height:Number, rotation:Number = 0, fixed:Boolean = false, mass:Number = 1, elasticity:Number = 0.3, friction:Number = 0)
      {
         super(x,y,width,height,rotation,fixed,mass,elasticity,friction);
         setLine(1,18074);
         setFill(18074);
      }
      
      override public function init() : void
      {
         super.init();
         var bevelAngle:int = radian > 0 ? 135 : 45;
         sprite.filters = [new BevelFilter(1,bevelAngle,16777215,1,18074,1,2,2),new DropShadowFilter(3,90,0,0.33,2,2)];
      }
   }
}

