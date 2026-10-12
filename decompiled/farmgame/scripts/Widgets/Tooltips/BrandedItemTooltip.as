package Widgets.Tooltips
{
   import Classes.ImageLoader;
   import Display.StrokeTextField;
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class BrandedItemTooltip extends ZwAbstractTooltip
   {
      
      protected var m_title:String = "";
      
      protected var m_text:String = "";
      
      protected var m_brandMessage:String = "";
      
      protected var m_iconPath:String = "";
      
      protected var m_iconObject:DisplayObject = null;
      
      protected var m_container:Sprite = null;
      
      protected var m_titleField:TextField = null;
      
      protected var m_textField:TextField = null;
      
      protected var m_brandMessageField:TextField = null;
      
      protected var m_backgroundAlpha:Number = 1;
      
      protected var m_backgroundColor:uint = 16777215;
      
      protected var m_backgroundCornerRadius:Number = 10;
      
      protected var m_borderAlpha:Number = 1;
      
      protected var m_borderColor:uint = 5325357;
      
      protected var m_borderThickness:Number = 2;
      
      protected var m_padding:Number = 6;
      
      public function BrandedItemTooltip(title:String = "", text:String = "", brandMsg:String = "", iconUrl:String = "")
      {
         var imageLoader:ImageLoader = null;
         super();
         this.m_text = text;
         this.m_title = title;
         this.m_iconPath = iconUrl;
         this.m_brandMessage = brandMsg;
         if(this.m_iconPath != null)
         {
            imageLoader = ImageLoader.getInstance(this.m_iconPath);
            imageLoader.getContent(this.onItemIconLoaded);
         }
      }
      
      private function onItemIconLoaded(content:DisplayObject) : void
      {
         this.m_iconObject = content;
      }
      
      override public function release() : void
      {
         this.clearDisplay();
         this.m_text = null;
         this.m_title = null;
         this.m_brandMessage = null;
         this.m_titleField = null;
         this.m_textField = null;
         this.m_brandMessageField = null;
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
         if(this.m_container == null && this.m_text != "")
         {
            this.refresh();
            this.updatePosition(null);
            Global.stage.addChild(this.m_container);
         }
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         this.clearDisplay();
      }
      
      protected function clearDisplay() : void
      {
         if(Boolean(this.m_container) && Boolean(this.m_container.parent))
         {
            this.m_container.parent.removeChild(this.m_container);
            this.m_container = null;
            this.m_brandMessage = null;
            this.m_titleField = null;
            this.m_textField = null;
         }
      }
      
      protected function createTitleField() : void
      {
         this.m_titleField = new StrokeTextField(2105376,1,0,0);
      }
      
      protected function createTextField() : void
      {
         this.m_textField = new StrokeTextField(2105376,1,0,0);
      }
      
      protected function createBrandMessageField() : void
      {
         this.m_brandMessageField = new StrokeTextField(2105376,1,0,0);
      }
      
      protected function get defaultTextFormat() : TextFormat
      {
         return new TextFormat("Arial",12,2105376,false);
      }
      
      protected function get titleTextFormat() : TextFormat
      {
         return new TextFormat("Arial",14,3158064,true);
      }
      
      protected function refresh() : void
      {
         var bitmapData1:BitmapData = null;
         var bitmap1:Bitmap = null;
         var bitmapData2:BitmapData = null;
         var bitmap2:Bitmap = null;
         var bitmapData3:BitmapData = null;
         var bitmap3:Bitmap = null;
         if(this.m_titleField == null)
         {
            this.createTitleField();
            this.m_titleField.multiline = true;
            this.m_titleField.wordWrap = true;
            this.m_titleField.width = 200;
            this.m_titleField.autoSize = TextFieldAutoSize.LEFT;
            this.m_titleField.cacheAsBitmap = true;
            this.m_titleField.defaultTextFormat = this.titleTextFormat;
         }
         if(this.m_textField == null)
         {
            this.createTextField();
            this.m_textField.multiline = true;
            this.m_textField.wordWrap = true;
            this.m_textField.width = 200;
            this.m_textField.autoSize = TextFieldAutoSize.LEFT;
            this.m_textField.cacheAsBitmap = true;
            this.m_textField.defaultTextFormat = this.defaultTextFormat;
         }
         if(this.m_brandMessageField == null)
         {
            this.createBrandMessageField();
            this.m_brandMessageField.multiline = true;
            this.m_brandMessageField.wordWrap = true;
            this.m_brandMessageField.width = 250;
            this.m_brandMessageField.autoSize = TextFieldAutoSize.LEFT;
            this.m_brandMessageField.cacheAsBitmap = true;
            this.m_brandMessageField.defaultTextFormat = this.defaultTextFormat;
         }
         if(this.m_text)
         {
            this.m_textField.htmlText = this.m_text;
         }
         if(this.m_title)
         {
            this.m_titleField.htmlText = this.m_title;
         }
         if(this.m_brandMessage)
         {
            this.m_brandMessageField.htmlText = this.m_brandMessage;
         }
         if(this.m_container == null)
         {
            this.m_container = new Sprite();
         }
         var iconWidth:int = 0;
         if(this.m_iconObject != null)
         {
            iconWidth = this.m_iconObject.width;
         }
         var titleHeight:int = 0;
         if(Boolean(this.m_title) && this.m_title != "")
         {
            titleHeight = this.m_titleField.textHeight;
         }
         var brandMsgHeight:int = 0;
         if(Boolean(this.m_brandMessage) && this.m_brandMessage != "")
         {
            brandMsgHeight = this.m_brandMessageField.textHeight;
         }
         var rectangleHeigt:int = this.m_padding + titleHeight + this.m_padding * 2 + this.m_textField.textHeight + this.m_padding * 4 + brandMsgHeight + this.m_padding * 2;
         var rectangleWidth:int = this.m_padding + iconWidth + this.m_padding * 2 + this.m_textField.textWidth + this.m_padding;
         this.m_container.graphics.clear();
         this.m_textField.textWidth + this.m_padding * 4 + iconWidth;
         this.m_container.graphics.lineStyle(this.m_borderThickness,this.m_borderColor,this.m_borderAlpha,true);
         this.m_container.graphics.beginFill(this.m_backgroundColor,this.m_backgroundAlpha);
         this.m_container.graphics.drawRoundRect(0,0,rectangleWidth,rectangleHeigt,this.m_backgroundCornerRadius,this.m_backgroundCornerRadius);
         this.m_container.graphics.endFill();
         while(this.m_container.numChildren > 0)
         {
            this.m_container.removeChildAt(0);
         }
         if(this.m_iconObject != null)
         {
            this.m_iconObject.x = this.m_padding;
            this.m_container.addChild(this.m_iconObject);
         }
         if(this.m_titleField.text != "")
         {
            bitmapData1 = new BitmapData(this.m_titleField.textWidth + this.m_padding * 2,this.m_titleField.textHeight + this.m_padding * 2,true,0);
            bitmapData1.draw(this.m_titleField);
            bitmap1 = new Bitmap(bitmapData1);
            bitmap1.x = this.m_padding + iconWidth + this.m_padding * 2;
            bitmap1.y = this.m_padding - (this.m_titleField.height - this.m_titleField.textHeight) / 2;
            this.m_container.addChild(bitmap1);
         }
         if(this.m_textField.text != "")
         {
            bitmapData2 = new BitmapData(this.m_textField.textWidth + this.m_padding * 2,this.m_textField.textHeight + this.m_padding * 2,true,0);
            bitmapData2.draw(this.m_textField);
            bitmap2 = new Bitmap(bitmapData2);
            bitmap2.x = this.m_padding + iconWidth + this.m_padding * 2;
            bitmap2.y = this.m_padding + titleHeight + this.m_padding * 2 - (this.m_textField.height - this.m_textField.textHeight) / 2;
            this.m_container.addChild(bitmap2);
         }
         if(this.m_brandMessageField.text != "")
         {
            this.m_brandMessageField.width = 200 + iconWidth;
            bitmapData3 = new BitmapData(this.m_brandMessageField.textWidth + this.m_padding * 2,this.m_brandMessageField.textHeight + this.m_padding * 2,true,0);
            bitmapData3.draw(this.m_brandMessageField);
            bitmap3 = new Bitmap(bitmapData3);
            bitmap3.x = this.m_padding;
            bitmap3.y = this.m_padding + titleHeight + this.m_padding * 2 + this.m_textField.textHeight + this.m_padding - (this.m_brandMessageField.height - this.m_brandMessageField.textHeight) / 2;
            this.m_container.addChild(bitmap3);
         }
      }
   }
}

