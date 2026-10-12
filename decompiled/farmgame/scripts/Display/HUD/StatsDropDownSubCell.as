package Display.HUD
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class StatsDropDownSubCell extends Sprite
   {
      
      protected var m_icon:DisplayObject;
      
      protected var m_count:Number;
      
      protected var m_mc:MovieClip;
      
      public function StatsDropDownSubCell(ParentMC:MovieClip)
      {
         super();
         this.m_mc = ParentMC;
      }
      
      public function set Count(newCount:Number) : void
      {
         this.m_count = newCount;
         this.m_mc.counter_tf.text = this.m_count.toString();
      }
      
      public function get Count() : Number
      {
         return this.m_count;
      }
      
      public function set Icon(newIcon:DisplayObject) : void
      {
         if(this.m_icon)
         {
            this.m_mc.trayIcon_mc.removeChild(this.m_icon);
         }
         this.m_icon = newIcon;
         this.m_mc.trayIcon_mc.addChild(this.m_icon);
      }
      
      public function get Icon() : DisplayObject
      {
         return this.m_icon;
      }
      
      public function get ParentMC() : MovieClip
      {
         return this.m_mc;
      }
   }
}

