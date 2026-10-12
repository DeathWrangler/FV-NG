package Display.HUD
{
   import Display.FarmGameSprite;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   
   public class OptionButton extends FarmGameSprite
   {
      
      public var selectedImage:Bitmap;
      
      public var nonSelectedImage:Bitmap;
      
      public var hoverImage:Bitmap;
      
      protected var m_selected:Boolean = false;
      
      protected var m_down:Boolean = false;
      
      protected var m_over:Boolean = false;
      
      public function OptionButton(inSelectedImage:Bitmap, inHoverImage:Bitmap, inNonSelectedImage:Bitmap, clickCallback:Function = null)
      {
         super();
         this.selectedImage = inSelectedImage;
         this.nonSelectedImage = inNonSelectedImage;
         this.hoverImage = inHoverImage;
         addEventListener(MouseEvent.CLICK,this.onClick,false,10,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         if(clickCallback != null)
         {
            addEventListener(MouseEvent.CLICK,clickCallback,false,0,true);
         }
         this.buttonMode = true;
         this.useHandCursor = true;
         this.updateImageState();
      }
      
      public function set selected(value:Boolean) : void
      {
         if(this.m_selected != value)
         {
            this.m_selected = value;
            this.updateImageState();
         }
      }
      
      protected function updateImageState() : void
      {
         var image:Bitmap = null;
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
         if(this.m_over)
         {
            image = this.hoverImage;
         }
         else if(this.selected)
         {
            image = this.selectedImage;
         }
         else
         {
            image = this.nonSelectedImage;
         }
         addChild(image);
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      protected function onClick(event:MouseEvent) : void
      {
         this.selected = !this.selected;
      }
      
      protected function onMouseOver(event:MouseEvent) : void
      {
         this.m_over = true;
         this.updateImageState();
      }
      
      protected function onMouseOut(event:MouseEvent) : void
      {
         this.m_over = false;
         this.updateImageState();
      }
      
      protected function onMouseDown(event:MouseEvent) : void
      {
         this.m_down = true;
         this.x += 1;
         this.y += 1;
         Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      protected function onMouseUp(event:MouseEvent) : void
      {
         if(this.m_down)
         {
            --this.x;
            --this.y;
         }
         this.m_down = false;
         Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
   }
}

