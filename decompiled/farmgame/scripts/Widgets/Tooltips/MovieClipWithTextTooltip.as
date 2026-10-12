package Widgets.Tooltips
{
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class MovieClipWithTextTooltip extends ZwAbstractTooltip
   {
      
      private var m_visible:Boolean;
      
      private var m_element:MovieClip;
      
      private var m_textField:TextField;
      
      private var m_offset:Point;
      
      private var m_stationary:Boolean = false;
      
      private var m_fadetime:Number = 0.25;
      
      public function MovieClipWithTextTooltip(element:MovieClip, text:String = "")
      {
         super();
         this.m_visible = false;
         this.m_element = element;
         if(element.text_tf)
         {
            this.m_textField = element.text_tf;
            this.m_textField.text = text;
         }
         this.m_element.visible = this.m_visible;
         this.m_element.alpha = 0;
         this.m_offset = new Point(0,0);
      }
      
      override protected function updatePosition(event:MouseEvent) : void
      {
         var pos:Point = null;
         if(Boolean(this.m_element) && !this.m_stationary)
         {
            pos = new Point(this.m_element.parent.mouseX + this.m_offset.x,this.m_element.parent.mouseY + this.m_offset.y);
            this.m_element.x = pos.x;
            this.m_element.y = pos.y;
         }
      }
      
      public function set fadetime(n:Number) : void
      {
         if(n < 0)
         {
            n = 0;
         }
         this.m_fadetime = n;
      }
      
      public function get fadetime() : Number
      {
         return this.m_fadetime;
      }
      
      public function set offset(p:Point) : void
      {
         this.m_offset = p;
      }
      
      public function set stationary(s:Boolean) : void
      {
         this.m_stationary = s;
      }
      
      public function get text() : String
      {
         return this.m_textField.text;
      }
      
      public function set text(s:String) : void
      {
         this.m_textField.text = s;
      }
      
      override protected function show(event:MouseEvent) : void
      {
         this.m_visible = true;
         TweenLite.to(this.m_element,this.m_fadetime,{"alpha":1});
         this.m_element.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         TweenLite.to(this.m_element,this.m_fadetime,{
            "alpha":0,
            "onComplete":function():void
            {
               m_visible = false;
            }
         });
         this.m_element.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override public function release() : void
      {
         this.m_element.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this.m_element = null;
         this.m_textField = null;
         TweenLite.killTweensOf(this.m_element);
         super.release();
      }
      
      private function onFrame(event:Event) : void
      {
         var currentFrame:int = 0;
         if(this.m_element)
         {
            currentFrame = this.m_element.currentFrame;
            this.m_element.visible = this.m_visible;
            if(this.m_textField)
            {
               this.m_textField.visible = this.m_visible;
            }
            this.m_element.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         }
      }
   }
}

