package Display
{
   import Engine.Utilities;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ContextMenuItem extends Sprite
   {
      
      public static const STATE_UP:String = "up";
      
      public static const STATE_OVER:String = "over";
      
      protected var m_state:String;
      
      protected var m_label:String;
      
      protected var m_action:String;
      
      protected var m_params:Object = {};
      
      protected var m_bgShape:Shape;
      
      protected var m_textField:TextField;
      
      protected var m_style:Object;
      
      public function ContextMenuItem(label:String, action:String, params:Object, style:Object)
      {
         super();
         this.m_label = label;
         this.m_action = action;
         this.m_style = style;
         this.m_params = params;
         this.draw();
         Utilities.toggleInputOnlyChildren(this,false);
         this.state = ContextMenuItem.STATE_UP;
      }
      
      public function get label() : String
      {
         return this.m_label;
      }
      
      public function get action() : String
      {
         return this.m_action;
      }
      
      public function get params() : Object
      {
         return this.m_params;
      }
      
      public function set state(value:String) : void
      {
         this.m_state = value;
         switch(this.m_state)
         {
            case ContextMenuItem.STATE_UP:
               this.drawUpState();
               break;
            case ContextMenuItem.STATE_OVER:
               this.drawOverState();
         }
      }
      
      public function get state() : String
      {
         return this.m_state;
      }
      
      public function getParam(name:String) : *
      {
         var result:* = null;
         if(this.m_params.hasOwnProperty(name))
         {
            result = this.m_params[name];
         }
         return result;
      }
      
      public function draw() : void
      {
         this.drawBg(this.m_style.contextMenuItem.backgroundColor);
         this.drawText(this.m_style.contextMenuItem.color);
      }
      
      protected function drawBg(color:uint) : void
      {
         if(!this.m_bgShape)
         {
            this.m_bgShape = new Shape();
            this.addChild(this.m_bgShape);
         }
         this.m_bgShape.graphics.clear();
         this.m_bgShape.graphics.beginFill(color);
         this.m_bgShape.graphics.drawRect(0,0,Math.max(this.m_style.contextMenuItem.width,this.width,this.parent ? this.parent.width - this.m_style.contextMenu.borderWidth * 2 : 0),this.m_style.contextMenuItem.height);
      }
      
      protected function drawText(color:uint) : void
      {
         var fontName:String = null;
         var textFormat:TextFormat = null;
         var textFieldX:int = 0;
         if(this.m_label)
         {
            fontName = this.m_style.contextMenuItem.font;
            textFormat = new TextFormat();
            textFormat.align = this.m_style.contextMenuItem.textAlign;
            textFormat.color = color;
            textFormat.font = fontName;
            textFormat.size = this.m_style.contextMenuItem.fontSize;
            if(!this.m_textField)
            {
               textFieldX = int(this.m_style.contextMenuItem.padding);
               this.m_textField = new TextField();
               this.m_textField.embedFonts = true;
               this.m_textField.defaultTextFormat = textFormat;
               this.m_textField.multiline = false;
               this.m_textField.antiAliasType = AntiAliasType.ADVANCED;
               this.m_textField.htmlText = this.m_label;
               this.m_textField.autoSize = this.m_style.contextMenuItem.textAlign;
               this.m_textField.selectable = false;
               Utilities.toggleInputOnlySelf(this.m_textField,false);
               this.m_textField.width = this.m_textField.textWidth;
               this.m_textField.height = this.m_textField.textHeight;
               this.m_textField.x = textFieldX;
               this.m_textField.y = this.m_style.contextMenuItem.height - this.m_textField.height >> 1;
               this.addChild(this.m_textField);
            }
            else
            {
               this.m_textField.defaultTextFormat = textFormat;
               this.m_textField.htmlText = this.m_label;
            }
         }
      }
      
      protected function drawOverState() : void
      {
         this.drawBg(this.m_style.contextMenuItem.hoverBackgroundColor);
         this.drawText(this.m_style.contextMenuItem.hoverColor);
      }
      
      protected function drawUpState() : void
      {
         this.drawBg(this.m_style.contextMenuItem.backgroundColor);
         this.drawText(this.m_style.contextMenuItem.color);
      }
   }
}

