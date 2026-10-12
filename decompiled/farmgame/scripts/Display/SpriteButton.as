package Display
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.MouseEvent;
   
   public class SpriteButton extends FarmGameSprite
   {
      
      protected const NORMAL:int = 0;
      
      protected const HOVER:int = 1;
      
      protected const DOWN:int = 2;
      
      protected const MAX_STATES:int = 3;
      
      protected var m_selected:Boolean = false;
      
      protected var m_down:Boolean = false;
      
      protected var m_over:Boolean = false;
      
      protected var m_imageInst:Array = [null,null,null];
      
      public function SpriteButton(inNormalImage:Class, inHoverImage:Class, inDownImage:Class, clickCallback:Function = null)
      {
         super();
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
         var normalImage:* = new inNormalImage();
         var downImage:* = new inDownImage();
         var hoverImage:* = new inHoverImage();
         if(normalImage is BitmapData)
         {
            normalImage = new Bitmap(normalImage);
         }
         if(downImage is BitmapData)
         {
            downImage = new Bitmap(downImage);
         }
         if(hoverImage is BitmapData)
         {
            hoverImage = new Bitmap(hoverImage);
         }
         this.m_imageInst[this.NORMAL] = normalImage;
         this.m_imageInst[this.DOWN] = downImage;
         this.m_imageInst[this.HOVER] = hoverImage;
         for(var imgIdx:int = 0; imgIdx < this.MAX_STATES; imgIdx++)
         {
            addChild(this.m_imageInst[imgIdx]);
         }
         this.updateImageState();
      }
      
      protected function updateImageState() : void
      {
         var image:int = 0;
         if(this.m_down)
         {
            image = this.DOWN;
         }
         else if(this.m_over)
         {
            image = this.HOVER;
         }
         else
         {
            image = this.NORMAL;
         }
         for(var imageIdx:int = 0; imageIdx < this.MAX_STATES; imageIdx++)
         {
            this.m_imageInst[imageIdx].visible = image == imageIdx;
         }
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
         this.updateImageState();
         Global.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      protected function onMouseUp(event:MouseEvent) : void
      {
         this.m_down = false;
         this.updateImageState();
         Global.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
   }
}

