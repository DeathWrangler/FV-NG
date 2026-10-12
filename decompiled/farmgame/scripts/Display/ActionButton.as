package Display
{
   import Classes.Constants.WorldsConstants;
   import Classes.EmbeddedArt;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   
   public class ActionButton extends FarmGameSprite
   {
      
      private var m_icon:DisplayObject;
      
      protected var m_mouseOverGlow:GlowFilter;
      
      private var m_down:Boolean;
      
      private var m_enabled:Boolean;
      
      private var m_toggle:Boolean;
      
      private var m_selected:Boolean = false;
      
      protected var m_arrowlessHeight:Number = 0;
      
      private var m_bouncingArrow:DisplayObject = null;
      
      public function ActionButton(asset:Class, pos:String = "top", enabled:Boolean = true, toggle:Boolean = false)
      {
         var m_backgroundGradient:Bitmap = null;
         super();
         this.buttonMode = true;
         this.m_enabled = enabled;
         this.m_toggle = toggle;
         this.m_mouseOverGlow = new GlowFilter();
         this.m_mouseOverGlow.blurX = this.m_mouseOverGlow.blurY = 1.3;
         this.m_mouseOverGlow.color = 15518892;
         this.m_mouseOverGlow.alpha = 1;
         this.m_mouseOverGlow.quality = BitmapFilterQuality.HIGH;
         this.m_mouseOverGlow.strength = 30;
         if(pos == "top")
         {
            m_backgroundGradient = new EmbeddedArt.hud_act_bttn_top();
         }
         if(pos == "bottom")
         {
            if(Boolean(Global.worldManager.currentWorldType) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_VILLAGE)
            {
               m_backgroundGradient = new EmbeddedArt.village_hud_act_bttn_bottom();
            }
            else
            {
               m_backgroundGradient = new EmbeddedArt.hud_act_bttn_bottom();
            }
         }
         addChild(m_backgroundGradient);
         this.setIcon(new asset());
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove,false,0,true);
         addChild(this.m_icon);
      }
      
      public function setArrow(visible:Boolean) : void
      {
         if(visible)
         {
            if(!this.m_bouncingArrow)
            {
               this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
               this.m_bouncingArrow.x = 5;
               this.m_bouncingArrow.y = -70;
               this.m_bouncingArrow.scaleX = 1;
               this.m_bouncingArrow.scaleY = 1;
               this.m_arrowlessHeight = this.height;
               this.addChild(this.m_bouncingArrow);
            }
         }
         else if(this.m_bouncingArrow)
         {
            this.removeChild(this.m_bouncingArrow);
            this.m_arrowlessHeight = 0;
            this.m_bouncingArrow = null;
         }
      }
      
      public function isArrowVisible() : Boolean
      {
         return null != this.m_bouncingArrow;
      }
      
      public function setIcon(asset:DisplayObject) : void
      {
         if(Boolean(this.m_icon) && Boolean(this.m_icon.parent))
         {
            this.m_icon.parent.removeChild(this.m_icon);
         }
         this.m_icon = asset;
         this.m_icon.x = (this.width - this.m_icon.width) / 2;
         if(this.m_arrowlessHeight != 0)
         {
            this.m_icon.y = (this.m_arrowlessHeight - this.m_icon.height) / 2;
         }
         else
         {
            this.m_icon.y = (this.height - this.m_icon.height) / 2;
         }
         addChild(this.m_icon);
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         if(this.m_enabled)
         {
            this.filters = [this.m_mouseOverGlow];
         }
         super.onRollOver(event);
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         if(!this.m_toggle)
         {
            this.filters = [];
         }
         else if(this.m_toggle && !this.m_down)
         {
            this.filters = [];
         }
         if(this.m_down && this.m_enabled && !this.m_toggle)
         {
            this.onMouseUp(null);
         }
         super.onRollOut(event);
      }
      
      protected function onMouseDown(event:MouseEvent) : void
      {
         Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         if(this.m_enabled && this.m_down == false)
         {
            this.m_down = true;
            this.x += 2;
            this.y += 2;
         }
      }
      
      protected function onMouseUp(event:MouseEvent) : void
      {
         Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         if(this.m_selected == false)
         {
            if(this.m_down && this.m_enabled)
            {
               this.x -= 2;
               this.y -= 2;
               this.filters = [];
            }
            this.m_down = false;
         }
      }
      
      public function highlight() : void
      {
         this.filters = [this.m_mouseOverGlow];
      }
      
      public function unHighlight() : void
      {
         this.filters = [];
      }
      
      public function toggle() : void
      {
         if(this.m_down == false)
         {
            this.m_down = true;
            this.highlight();
            this.x += 2;
            this.y += 2;
         }
         this.m_selected = true;
      }
      
      public function untoggle() : void
      {
         if(this.m_down)
         {
            this.m_down = false;
            this.unHighlight();
            this.x -= 2;
            this.y -= 2;
         }
         this.m_selected = false;
      }
      
      public function isDown() : Boolean
      {
         return this.m_down;
      }
   }
}

