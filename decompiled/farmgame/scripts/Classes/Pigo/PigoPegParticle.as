package Classes.Pigo
{
   import flash.filters.BevelFilter;
   import flash.filters.DropShadowFilter;
   import org.cove.ape.CircleParticle;
   
   public class PigoPegParticle extends CircleParticle
   {
      
      public function PigoPegParticle(x:Number, y:Number, radius:Number, fixed:Boolean = false, mass:Number = 1, elasticity:Number = 0.3, friction:Number = 0)
      {
         super(x,y,radius,fixed,mass,elasticity,friction);
         setLine(1,18074);
         setFill(1037038);
      }
      
      override public function init() : void
      {
         super.init();
         sprite.filters = [new BevelFilter(1,45,1037038,1,18074,1,1,1),new DropShadowFilter(4,90,0,0.33,2,2)];
      }
   }
}

