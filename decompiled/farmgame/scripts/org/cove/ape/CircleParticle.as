package org.cove.ape
{
   public class CircleParticle extends AbstractParticle
   {
      
      private var _radius:Number;
      
      public function CircleParticle(x:Number, y:Number, radius:Number, fixed:Boolean = false, mass:Number = 1, elasticity:Number = 0.3, friction:Number = 0)
      {
         super(x,y,fixed,mass,elasticity,friction);
         this._radius = radius;
      }
      
      public function get radius() : Number
      {
         return this._radius;
      }
      
      public function set radius(r:Number) : void
      {
         this._radius = r;
      }
      
      override public function init() : void
      {
         cleanup();
         if(displayObject != null)
         {
            initDisplay();
         }
         else
         {
            sprite.graphics.clear();
            sprite.graphics.lineStyle(lineThickness,lineColor,lineAlpha);
            sprite.graphics.beginFill(fillColor,fillAlpha);
            sprite.graphics.drawCircle(0,0,this.radius);
            sprite.graphics.endFill();
         }
         this.paint();
      }
      
      override public function paint() : void
      {
         sprite.x = curr.x;
         sprite.y = curr.y;
      }
      
      internal function getProjection(axis:CartesianVector) : Interval
      {
         var c:Number = samp.dot(axis);
         interval.min = c - this._radius;
         interval.max = c + this._radius;
         return interval;
      }
      
      internal function getIntervalX() : Interval
      {
         interval.min = samp.x - this._radius;
         interval.max = samp.x + this._radius;
         return interval;
      }
      
      internal function getIntervalY() : Interval
      {
         interval.min = samp.y - this._radius;
         interval.max = samp.y + this._radius;
         return interval;
      }
   }
}

