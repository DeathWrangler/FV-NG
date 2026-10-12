package org.cove.ape
{
   public class RectangleParticle extends AbstractParticle
   {
      
      private var _extents:Array;
      
      private var _axes:Array;
      
      private var _radian:Number;
      
      public function RectangleParticle(x:Number, y:Number, width:Number, height:Number, rotation:Number = 0, fixed:Boolean = false, mass:Number = 1, elasticity:Number = 0.3, friction:Number = 0)
      {
         super(x,y,fixed,mass,elasticity,friction);
         this._extents = new Array(width / 2,height / 2);
         this._axes = new Array(new CartesianVector(0,0),new CartesianVector(0,0));
         this.radian = rotation;
      }
      
      public function get radian() : Number
      {
         return this._radian;
      }
      
      public function set radian(t:Number) : void
      {
         this._radian = t;
         this.setAxes(t);
      }
      
      public function get angle() : Number
      {
         return this.radian * MathUtil.ONE_EIGHTY_OVER_PI;
      }
      
      public function set angle(a:Number) : void
      {
         this.radian = a * MathUtil.PI_OVER_ONE_EIGHTY;
      }
      
      override public function init() : void
      {
         var w:Number = NaN;
         var h:Number = NaN;
         cleanup();
         if(displayObject != null)
         {
            initDisplay();
         }
         else
         {
            w = this.extents[0] * 2;
            h = this.extents[1] * 2;
            sprite.graphics.clear();
            sprite.graphics.lineStyle(lineThickness,lineColor,lineAlpha);
            sprite.graphics.beginFill(fillColor,fillAlpha);
            sprite.graphics.drawRect(-w / 2,-h / 2,w,h);
            sprite.graphics.endFill();
         }
         this.paint();
      }
      
      override public function paint() : void
      {
         sprite.x = curr.x;
         sprite.y = curr.y;
         sprite.rotation = this.angle;
      }
      
      public function set width(w:Number) : void
      {
         this._extents[0] = w / 2;
      }
      
      public function get width() : Number
      {
         return this._extents[0] * 2;
      }
      
      public function set height(h:Number) : void
      {
         this._extents[1] = h / 2;
      }
      
      public function get height() : Number
      {
         return this._extents[1] * 2;
      }
      
      internal function get axes() : Array
      {
         return this._axes;
      }
      
      internal function get extents() : Array
      {
         return this._extents;
      }
      
      internal function getProjection(axis:CartesianVector) : Interval
      {
         var radius:Number = this.extents[0] * Math.abs(axis.dot(this.axes[0])) + this.extents[1] * Math.abs(axis.dot(this.axes[1]));
         var c:Number = samp.dot(axis);
         interval.min = c - radius;
         interval.max = c + radius;
         return interval;
      }
      
      private function setAxes(t:Number) : void
      {
         var s:Number = Math.sin(t);
         var c:Number = Math.cos(t);
         this.axes[0].x = c;
         this.axes[0].y = s;
         this.axes[1].x = -s;
         this.axes[1].y = c;
      }
   }
}

