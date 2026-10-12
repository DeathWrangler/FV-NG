package Display
{
   import Classes.EmbeddedArt;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GenericButtonBouncingArrow extends GenericButton
   {
      
      private var m_bouncingArrow:DisplayObject;
      
      private var m_targeClip:MovieClip;
      
      private var m_xPos:Number;
      
      private var m_yPos:Number;
      
      public function GenericButtonBouncingArrow(target_mc:MovieClip, clickCallback:Function = null, val:String = "", overlayName:String = "", x:Number = 5, y:Number = -70)
      {
         super(target_mc,clickCallback,val,overlayName);
         this.m_targeClip = target_mc;
         this.m_xPos = x;
         this.m_yPos = y;
         this.attachBouncingArrow();
      }
      
      private function attachBouncingArrow() : void
      {
         this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
         this.m_bouncingArrow.x = this.m_xPos;
         this.m_bouncingArrow.y = this.m_yPos;
         this.m_bouncingArrow.scaleX = 1;
         this.m_bouncingArrow.scaleY = 1;
         this.m_bouncingArrow.visible = false;
         this.m_targeClip.addChild(this.m_bouncingArrow);
      }
      
      public function showArrow() : void
      {
         this.m_bouncingArrow.visible = true;
      }
      
      public function hideArrow() : void
      {
         this.m_bouncingArrow.visible = false;
      }
   }
}

