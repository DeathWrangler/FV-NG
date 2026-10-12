package Classes
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class MiniGameDecoration extends Decoration
   {
      
      private var m_showArrwow:Boolean;
      
      private var m_arrowMC:MovieClip;
      
      public function MiniGameDecoration(itemName:String)
      {
         super(itemName);
      }
      
      public function set showArrow(showArrow:Boolean) : void
      {
         this.m_showArrwow = showArrow;
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         if(this.m_showArrwow)
         {
            this.showArrowMC();
         }
      }
      
      private function showArrowMC() : void
      {
         var tutArrowClass:Class = null;
         if(this.m_arrowMC == null)
         {
            tutArrowClass = EmbeddedArt.bouncing_arrow;
            this.m_arrowMC = new tutArrowClass() as MovieClip;
         }
         var spr:Sprite = m_displayObject as Sprite;
         spr.addChild(this.m_arrowMC);
         var point:Point = new Point();
         this.m_arrowMC.scaleX = 1 / m_displayObject.scaleX;
         this.m_arrowMC.scaleY = 1 / m_displayObject.scaleY;
         if(spr.getChildAt(0))
         {
            point.y = -1 * Math.min(this.m_arrowMC.height,90);
            point.x = (spr.getChildAt(0).width - Math.min(this.m_arrowMC.width,30) * spr.scaleX) / 2;
            if(point.x != this.m_arrowMC.x || point.y != this.m_arrowMC.y)
            {
               this.m_arrowMC.y = point.y - 50;
               this.m_arrowMC.x = point.x - 20;
            }
         }
      }
      
      override public function showMenu() : void
      {
      }
   }
}

