package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Managers.ClickTrackingManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class FarmGameSprite extends Sprite
   {
      
      public static const DEFAULT_TOOLTIP_WIDTH:Number = 200;
      
      protected var m_toolTip:String;
      
      protected var m_toolTipWidth:Number = 200;
      
      protected var m_toolTipObj:Sprite = null;
      
      protected var m_toolTipText:TextField = null;
      
      protected var m_normalScale:Number = -1;
      
      protected var m_rollOverScale:Number = 1.1;
      
      protected var m_strokeField:StrokeTextField = null;
      
      protected var m_trackClicks:Boolean = false;
      
      protected var m_id:String = "";
      
      public function FarmGameSprite()
      {
         super();
         this.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this.trackClicks(true);
      }
      
      public function RemoveEventListeners() : void
      {
         this.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function set id(value:String) : void
      {
         this.m_id = value;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function set toolTipWidth(value:Number) : void
      {
         if(value != this.m_toolTipWidth)
         {
            this.m_toolTipWidth = value;
            if(this.m_toolTipObj)
            {
               this.m_toolTipText.width = this.m_toolTipWidth;
               this.drawBG(this.m_toolTipObj);
               this.updateToolTipPosition();
            }
         }
      }
      
      public function set toolTip(value:String) : void
      {
         if(value != this.m_toolTip)
         {
            this.m_toolTip = value;
            if(this.m_toolTipObj)
            {
               this.m_toolTipText.text = this.m_toolTip;
               this.drawBG(this.m_toolTipObj);
               this.updateToolTipPosition();
            }
         }
      }
      
      public function get toolTip() : String
      {
         return this.m_toolTip;
      }
      
      public function set normalScale(value:Number) : void
      {
         this.m_normalScale = value;
      }
      
      public function trackClicks(value:Boolean) : void
      {
         if(value == false)
         {
            this.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
         }
         else if(value == true && this.m_trackClicks == false)
         {
            this.addEventListener(MouseEvent.CLICK,this.onMouseClick);
         }
         this.m_trackClicks = value;
      }
      
      public function set rollOverScale(value:Number) : void
      {
         this.m_rollOverScale = value;
      }
      
      protected function onMouseClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
      }
      
      protected function onRollOver(event:MouseEvent) : void
      {
         if(this.m_normalScale > 0)
         {
            this.scaleX = this.scaleY = this.m_rollOverScale * this.m_normalScale;
         }
         if(this.m_toolTipObj == null && this.m_toolTip != null)
         {
            if(this.m_strokeField == null)
            {
               this.m_strokeField = new StrokeTextField(2105376,0.8);
               this.m_strokeField.multiline = true;
               this.m_strokeField.wordWrap = true;
               this.m_strokeField.width = this.m_toolTipWidth;
               this.m_strokeField.autoSize = TextFieldAutoSize.LEFT;
               this.m_strokeField.cacheAsBitmap = true;
            }
            this.m_strokeField.defaultTextFormat = new TextFormat("Arial",14,16777215,true);
            this.m_strokeField.toolTipText = this.m_toolTip;
            this.m_toolTipText = this.m_strokeField;
            this.m_toolTipObj = new Sprite();
            this.drawBG(this.m_toolTipObj);
            this.updateToolTipPosition();
            Global.stage.addChild(this.m_toolTipObj);
         }
      }
      
      protected function drawBG(spr:Sprite) : void
      {
         var padding:Number = 2;
         spr.graphics.clear();
         while(spr.numChildren > 0)
         {
            spr.removeChildAt(0);
         }
         var bitmapData:BitmapData = new BitmapData(this.m_toolTipText.textWidth + padding * 2,this.m_toolTipText.textHeight + padding * 2,true,0);
         bitmapData.draw(this.m_toolTipText);
         var bitmap:Bitmap = new Bitmap(bitmapData);
         spr.addChild(bitmap);
         spr.graphics.beginFill(0,0.4);
         spr.graphics.drawRoundRect(0,0,this.m_toolTipText.textWidth + padding * 2,this.m_toolTipText.textHeight + padding * 2,8,8);
         spr.graphics.endFill();
      }
      
      protected function onRollOut(event:MouseEvent) : void
      {
         if(this.m_normalScale > 0)
         {
            this.scaleX = this.scaleY = this.m_normalScale;
         }
         if(Boolean(this.m_toolTipObj) && Boolean(this.m_toolTipObj.parent))
         {
            this.m_toolTipObj.parent.removeChild(this.m_toolTipObj);
            this.m_toolTipObj = null;
            this.m_toolTipText = null;
         }
      }
      
      protected function onMouseMove(event:MouseEvent) : void
      {
         this.updateToolTipPosition();
      }
      
      protected function updateToolTipPosition() : void
      {
         var pos:Point = null;
         if(this.m_toolTipObj)
         {
            pos = new Point(Global.stage.mouseX + 10,Global.stage.mouseY + 10);
            if(Global.stage.stageWidth - this.m_toolTipObj.width < pos.x)
            {
               pos.x = Global.stage.mouseX - this.m_toolTipObj.width - 10;
            }
            if(Global.stage.stageHeight - this.m_toolTipObj.height < pos.y)
            {
               pos.y = Global.stage.mouseY - this.m_toolTipObj.height - 10;
            }
            this.m_toolTipObj.x = pos.x;
            this.m_toolTipObj.y = pos.y;
         }
      }
      
      public function isToolTipVisible() : Boolean
      {
         return this.m_toolTipObj != null;
      }
      
      public function hideToolTip() : void
      {
         this.onRollOut(null);
      }
   }
}

