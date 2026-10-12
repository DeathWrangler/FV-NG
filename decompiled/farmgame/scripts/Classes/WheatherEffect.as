package Classes
{
   import flash.display.MovieClip;
   import flash.display.Shape;
   
   public class WheatherEffect extends MovieClip
   {
      
      private var m_wind:Number = -1;
      
      private var m_radian:Number = 0;
      
      private var m_speed:Number = 2;
      
      private var movieWidth:Number = GlobalEngine.stage.stageWidth;
      
      private var movieHeight:Number = GlobalEngine.stage.stageHeight;
      
      private var m_cirlce:Shape;
      
      private var m_effectType:String;
      
      public function WheatherEffect(effectType:String)
      {
         super();
         this.m_effectType = effectType;
         this.loadEffectType();
      }
      
      private function loadEffectType() : void
      {
         if(this.m_effectType != "")
         {
            this.m_cirlce = new Shape();
            this.m_cirlce.graphics.beginFill(16777215,1);
            this.m_cirlce.graphics.drawCircle(0,0,1.5);
            this.m_cirlce.graphics.endFill();
            addChild(this.m_cirlce);
         }
      }
      
      public function wheatherEffectEnterFrame() : void
      {
         this.m_radian += this.rotation / 180 * Math.PI;
         this.x -= Math.cos(this.m_radian) + this.m_wind;
         this.y += this.m_speed;
         if(this.y >= this.movieHeight)
         {
            this.y = -2;
         }
         if(this.x >= this.movieWidth)
         {
            this.x = 1;
         }
         if(this.x <= 0)
         {
            this.x = this.movieWidth - 1;
         }
      }
      
      public function removeWheatherEffect() : void
      {
         if(this.m_cirlce)
         {
            this.removeChild(this.m_cirlce);
            this.m_cirlce = null;
         }
      }
   }
}

