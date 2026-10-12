package Widgets.Tooltips
{
   import Classes.util.FarmGameUtil;
   import Display.StrokeTextField;
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   public class FarmTextTooltip extends ZwAbstractTooltip
   {
      
      protected var m_text:String = "";
      
      protected var m_textFunction:Function = null;
      
      protected var m_refreshSeconds:uint = 0;
      
      protected var m_refreshTimer:Timer = null;
      
      protected var m_container:Sprite = null;
      
      protected var m_textfield:TextField = null;
      
      protected var m_backgroundAlpha:Number = 0.4;
      
      protected var m_backgroundColor:uint = 0;
      
      protected var m_backgroundCornerRadius:Number = 8;
      
      protected var m_borderAlpha:Number = 0;
      
      protected var m_borderColor:uint = 16777215;
      
      protected var m_borderThickness:Number = 1;
      
      protected var m_padding:Number = 2;
      
      public function FarmTextTooltip(text:String = "", textFunction:Function = null, refreshSeconds:uint = 0)
      {
         super();
         this.setText(text);
         this.m_textFunction = textFunction;
         this.m_refreshSeconds = refreshSeconds;
      }
      
      override public function release() : void
      {
         this.clearDisplay();
         this.m_text = null;
         this.m_textfield = null;
         this.m_textFunction = null;
         if(this.m_refreshTimer)
         {
            this.m_refreshTimer.removeEventListener(TimerEvent.TIMER,this.onRefreshTimer);
            this.m_refreshTimer = null;
         }
         super.release();
      }
      
      override protected function updatePosition(event:MouseEvent) : void
      {
         var pos:Point = null;
         if(this.m_container)
         {
            pos = new Point(Global.stage.mouseX + 10,Global.stage.mouseY + 10);
            if(Global.stage.stageWidth - this.m_container.width < pos.x)
            {
               pos.x = Global.stage.mouseX - this.m_container.width - 10;
            }
            if(Global.stage.stageHeight - this.m_container.height < pos.y)
            {
               pos.y = Global.stage.mouseY - this.m_container.height - 10;
            }
            this.m_container.x = pos.x;
            this.m_container.y = pos.y;
         }
      }
      
      override protected function show(event:MouseEvent) : void
      {
         if(this.m_textFunction != null || this.m_container == null && this.m_text != "")
         {
            this.refresh();
            this.updatePosition(null);
            Global.stage.addChild(this.m_container);
         }
         if(this.m_textFunction != null && this.m_refreshSeconds > 0)
         {
            this.startRefreshTimer();
         }
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         this.clearDisplay();
         this.stopRefreshTimer();
      }
      
      protected function clearDisplay() : void
      {
         if(Boolean(this.m_container) && Boolean(this.m_container.parent))
         {
            this.m_container.parent.removeChild(this.m_container);
            this.m_container = null;
            this.m_textfield = null;
         }
      }
      
      public function setText(value:String) : void
      {
         if(this.m_text != value)
         {
            this.m_text = value;
            if(this.m_container)
            {
               this.m_textfield.htmlText = this.m_text;
               this.refresh();
               this.updatePosition(null);
            }
         }
      }
      
      public function getText() : String
      {
         return this.m_text;
      }
      
      public function setTextFunction(textFunction:Function) : void
      {
         this.m_textFunction = textFunction;
         if(this.m_textFunction != null)
         {
            this.startRefreshTimer();
         }
         else
         {
            this.stopRefreshTimer();
         }
      }
      
      public function getTextFunction() : Function
      {
         return this.m_textFunction;
      }
      
      public function setRefreshSeconds(refreshSeconds:uint) : void
      {
         this.m_refreshSeconds = refreshSeconds;
         if(this.m_refreshTimer)
         {
            this.m_refreshTimer.delay = this.m_refreshSeconds * FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
      }
      
      public function getRefreshSeconds() : uint
      {
         return this.m_refreshSeconds;
      }
      
      protected function createTextField() : void
      {
         this.m_textfield = new StrokeTextField(2105376,0.8);
      }
      
      protected function get defaultTextFormat() : TextFormat
      {
         return new TextFormat("Arial",14,16777215,true);
      }
      
      protected function startRefreshTimer() : void
      {
         if(!this.m_refreshTimer)
         {
            this.m_refreshTimer = new Timer(this.m_refreshSeconds * 1000);
            this.m_refreshTimer.addEventListener(TimerEvent.TIMER,this.onRefreshTimer);
         }
         if(!this.m_refreshTimer.running)
         {
            this.m_refreshTimer.start();
         }
      }
      
      protected function stopRefreshTimer() : void
      {
         if(this.m_refreshTimer)
         {
            this.m_refreshTimer.reset();
         }
      }
      
      protected function onRefreshTimer(event:TimerEvent) : void
      {
         this.refresh();
      }
      
      protected function refresh() : void
      {
         var bitmapData:BitmapData = null;
         var bitmap:Bitmap = null;
         if(this.m_textfield == null)
         {
            this.createTextField();
            this.m_textfield.multiline = true;
            this.m_textfield.wordWrap = true;
            this.m_textfield.width = 200;
            this.m_textfield.autoSize = TextFieldAutoSize.LEFT;
            this.m_textfield.cacheAsBitmap = true;
            this.m_textfield.defaultTextFormat = this.defaultTextFormat;
         }
         if(this.m_textFunction != null)
         {
            this.m_text = this.m_textFunction();
         }
         if(this.m_text)
         {
            this.m_textfield.htmlText = this.m_text;
         }
         if(this.m_container == null)
         {
            this.m_container = new Sprite();
         }
         this.m_container.graphics.clear();
         this.m_container.graphics.lineStyle(this.m_borderThickness,this.m_borderColor,this.m_borderAlpha,true);
         this.m_container.graphics.beginFill(this.m_backgroundColor,this.m_backgroundAlpha);
         this.m_container.graphics.drawRoundRect(0,0,this.m_textfield.textWidth + this.m_padding * 2,this.m_textfield.textHeight + this.m_padding * 2,this.m_backgroundCornerRadius,this.m_backgroundCornerRadius);
         this.m_container.graphics.endFill();
         while(this.m_container.numChildren > 0)
         {
            this.m_container.removeChildAt(0);
         }
         if(this.m_textfield.text != "")
         {
            bitmapData = new BitmapData(this.m_textfield.textWidth + this.m_padding * 2,this.m_textfield.textHeight + this.m_padding * 2,true,0);
            bitmapData.draw(this.m_textfield);
            bitmap = new Bitmap(bitmapData);
            bitmap.x = this.m_padding;
            bitmap.y = this.m_padding - (this.m_textfield.height - this.m_textfield.textHeight) / 2;
            this.m_container.addChild(bitmap);
         }
      }
   }
}

