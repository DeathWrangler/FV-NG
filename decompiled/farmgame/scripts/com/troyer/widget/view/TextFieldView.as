package com.troyer.widget.view
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.style.BaseStyle;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   
   public class TextFieldView extends BaseWidgetView
   {
      
      public static const ATTRIBUTE_TEXT:String = "text";
      
      public static const ATTRIBUTE_SELECTABLE:String = "selectable";
      
      public static const ATTRIBUTE_ALIGN:String = "align";
      
      public static const ATTRIBUTE_WORD_WRAP:String = "wordWrap";
      
      public static const ATTRIBUTE_MULTILINE:String = "multiline";
      
      public static const ATTRIBUTE_FONT_SIZE:String = "fontSize";
      
      public static const ATTRIBUTE_WRAP_WIDTH:String = "wrapWidth";
      
      public static const ATTRIBUTE_SCALE_WIDTH:String = "scaleWidth";
      
      protected var m_textField:TextField;
      
      protected var m_textFormat:TextFormat;
      
      protected var m_overrideFontSize:Number;
      
      protected var m_minimumFontSize:Number = 6;
      
      protected var m_text:String = "";
      
      protected var m_align:String = "left";
      
      private var m_noHTML:Boolean = false;
      
      private var m_multiLine:Boolean = false;
      
      private var m_wordWrap:Boolean = true;
      
      private var m_wrapWidth:Number;
      
      private var m_scaleWidth:Number;
      
      public function TextFieldView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2);
      }
      
      override public function destroy() : void
      {
         this.m_textField = null;
         this.m_textFormat = null;
         this.m_text = null;
         this.m_align = null;
         super.destroy();
      }
      
      override public function getAttributeNames() : Array
      {
         var _loc1_:Array = super.getAttributeNames();
         _loc1_.push(ATTRIBUTE_TEXT,ATTRIBUTE_SELECTABLE,ATTRIBUTE_ALIGN,ATTRIBUTE_WORD_WRAP);
         return _loc1_;
      }
      
      override public function setStyle(param1:BaseStyle) : void
      {
         super.setStyle(param1);
         this.m_textFormat = null;
         this.setup();
         this.notifyResized();
      }
      
      protected function createTextField() : TextField
      {
         return new TextField();
      }
      
      override protected function setup() : void
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         if(!m_style)
         {
            return;
         }
         var _loc1_:Object = m_style.getFont(0);
         if(!_loc1_)
         {
            return;
         }
         if(!this.m_textField)
         {
            this.m_textField = this.createTextField();
            this.m_textField.selectable = false;
            addChild(this.m_textField);
         }
         this.updateTextField();
         if(_loc1_.hasOwnProperty(BaseStyle.FONT_EMBEDDED))
         {
            if(Utility.stringIsTrue(_loc1_[BaseStyle.FONT_EMBEDDED]))
            {
               this.m_textField.embedFonts = true;
            }
         }
         if(_loc1_.hasOwnProperty(BaseStyle.FONT_HTML))
         {
            if(Utility.stringIsTrue(_loc1_[BaseStyle.FONT_HTML]))
            {
               this.m_noHTML = false;
            }
            else
            {
               this.m_noHTML = true;
            }
         }
         if(_loc1_.hasOwnProperty(BaseStyle.FONT_BORDER))
         {
            if(Utility.stringIsTrue(_loc1_[BaseStyle.FONT_BORDER]))
            {
               this.m_textField.border = true;
            }
         }
         if(_loc1_.hasOwnProperty(BaseStyle.FONT_COLOR_BG))
         {
            this.m_textField.background = true;
            this.m_textField.backgroundColor = _loc1_[BaseStyle.FONT_COLOR_BG];
         }
         else
         {
            this.m_textField.background = false;
         }
         if(_loc1_.hasOwnProperty(BaseStyle.FONT_INPUT))
         {
            if(Utility.stringIsTrue(_loc1_[BaseStyle.FONT_INPUT]))
            {
               this.m_textField.type = TextFieldType.INPUT;
               this.m_textField.selectable = true;
               this.m_textField.tabEnabled = false;
               this.m_textField.border = true;
               if(_loc1_.hasOwnProperty(BaseStyle.FONT_LIMIT))
               {
                  this.m_textField.maxChars = parseInt(_loc1_[BaseStyle.FONT_LIMIT]);
               }
               if(_loc1_.hasOwnProperty(BaseStyle.FONT_PASSWORD) && Utility.stringIsTrue(_loc1_[BaseStyle.FONT_PASSWORD]))
               {
                  this.m_textField.displayAsPassword = true;
               }
               else if(_loc1_.hasOwnProperty(BaseStyle.FONT_RESTRICT))
               {
                  this.m_textField.restrict = _loc1_[BaseStyle.FONT_RESTRICT];
               }
               else if(_loc1_.hasOwnProperty(BaseStyle.FONT_COLOR_BORDER))
               {
                  this.m_textField.borderColor = _loc1_[BaseStyle.FONT_COLOR_BORDER];
               }
            }
         }
         if(!this.m_textFormat)
         {
            this.m_textFormat = new TextFormat();
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_ALIGN) && this.m_align == "")
            {
               this.m_align = _loc1_[BaseStyle.FONT_ALIGN];
            }
            if(this.m_align != "")
            {
               this.m_textFormat.align = this.m_align;
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_SIZE))
            {
               this.m_textFormat.size = _loc1_[BaseStyle.FONT_SIZE];
            }
            if(!isNaN(this.m_overrideFontSize))
            {
               this.m_textFormat.size = this.m_overrideFontSize;
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_NAME))
            {
               this.m_textFormat.font = MT4DManager.getInstance().config.onGetLocalizedFontName(m_style.getName(),_loc1_[BaseStyle.FONT_NAME]);
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_COLOR))
            {
               this.m_textFormat.color = _loc1_[BaseStyle.FONT_COLOR];
            }
            else
            {
               this.m_textFormat.color = m_style.getColor(0);
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_BOLD) && Utility.stringIsTrue(_loc1_[BaseStyle.FONT_BOLD]))
            {
               this.m_textFormat.bold = true;
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_ITALIC) && Utility.stringIsTrue(_loc1_[BaseStyle.FONT_ITALIC]))
            {
               this.m_textFormat.italic = true;
            }
            if(_loc1_.hasOwnProperty(BaseStyle.FONT_FORMATTING))
            {
               _loc2_ = _loc1_[BaseStyle.FONT_FORMATTING];
               for(_loc3_ in _loc2_)
               {
                  if(this.m_textFormat.hasOwnProperty(_loc3_))
                  {
                     this.m_textFormat[_loc3_] = _loc2_[_loc3_];
                  }
               }
            }
            this.m_textField.defaultTextFormat = this.m_textFormat;
         }
         if(!isNaN(this.m_scaleWidth))
         {
            while(this.m_textField.textWidth > this.m_scaleWidth && this.m_textFormat.size > this.m_minimumFontSize)
            {
               this.m_overrideFontSize = Number(this.m_textFormat.size) - 1;
               this.m_textFormat.size = this.m_overrideFontSize;
               this.m_textField.defaultTextFormat = this.m_textFormat;
               this.updateInnerText();
            }
         }
         this.updateTextField();
         if(m_fixedWidth)
         {
            this.m_textField.wordWrap = this.m_wordWrap;
            this.m_textField.multiline = this.m_multiLine;
            this.m_textField.width = m_size.width;
         }
         else if(!isNaN(this.m_wrapWidth))
         {
            if(this.m_textField.width > this.m_wrapWidth)
            {
               this.m_textField.wordWrap = this.m_wordWrap;
               this.m_textField.multiline = this.m_multiLine;
               this.m_textField.width = this.m_wrapWidth;
            }
         }
         if(m_fixedHeight)
         {
            this.m_textField.height = m_size.height;
         }
         if(!m_fixedWidth || !m_fixedHeight)
         {
            m_size = new Rectangle(0,0,this.m_textField.width,this.m_textField.height);
            if(m_offsetLeft + m_offsetRight == 0 && m_offsetTop + m_offsetBottom == 0)
            {
               m_adjustedSize = m_size;
            }
            else
            {
               m_adjustedSize = new Rectangle(0,0,m_size.width + m_offsetLeft + m_offsetRight,m_size.height + m_offsetTop + m_offsetBottom);
            }
         }
      }
      
      private function updateTextField() : void
      {
         if(Boolean(this.m_textField) && this.m_text != null)
         {
            this.updateInnerText();
            if((m_fixedWidth || isNaN(this.m_wrapWidth) == false) && !this.m_wordWrap)
            {
               this.m_textField.autoSize = TextFieldAutoSize.NONE;
            }
            else
            {
               this.m_textField.autoSize = TextFieldAutoSize.LEFT;
            }
         }
      }
      
      private function updateInnerText() : void
      {
         if(this.m_noHTML)
         {
            this.m_textField.text = this.m_text;
         }
         else
         {
            this.m_textField.htmlText = this.m_text;
         }
      }
      
      private function stripHTML(param1:String) : String
      {
         var _loc2_:RegExp = /<[^>]*>/gi;
         return param1.replace(_loc2_,"");
      }
      
      override public function setAttribute(param1:String, param2:*) : void
      {
         var _loc3_:String = null;
         if(param1 == ATTRIBUTE_TEXT && param2 is String)
         {
            this.m_text = param2 as String;
            this.setup();
            notifyResized();
         }
         else if(param1 == ATTRIBUTE_SELECTABLE && param2 is String)
         {
            _loc3_ = param2 as String;
            if(Utility.stringIsTrue(_loc3_))
            {
               this.m_textField.selectable = true;
            }
            else
            {
               this.m_textField.selectable = false;
            }
         }
         else if(param1 == ATTRIBUTE_ALIGN)
         {
            if(param2 == Constants.ALIGN_LEFT)
            {
               this.m_align = TextFormatAlign.LEFT;
            }
            else if(param2 == Constants.ALIGN_CENTER)
            {
               this.m_align = TextFormatAlign.CENTER;
            }
            else if(param2 == Constants.ALIGN_RIGHT)
            {
               this.m_align = TextFormatAlign.RIGHT;
            }
            this.m_textFormat = null;
            this.setup();
            notifyResized();
         }
         else if(param1 == ATTRIBUTE_WORD_WRAP && param2 is String)
         {
            this.m_wordWrap = Utility.stringIsTrue(param2);
            if(this.m_wordWrap)
            {
               this.m_multiLine = true;
            }
            this.setup();
            notifyResized();
         }
         else if(param1 == ATTRIBUTE_MULTILINE && param2 is String)
         {
            this.m_multiLine = Utility.stringIsTrue(param2);
         }
         else if(param1 == ATTRIBUTE_FONT_SIZE)
         {
            if(param2 is String)
            {
               this.m_overrideFontSize = parseFloat(param2);
            }
            else if(param2 is Number)
            {
               this.m_overrideFontSize = param2;
            }
            this.m_textFormat = null;
            this.setup();
            notifyResized();
         }
         else if(param1 == ATTRIBUTE_WRAP_WIDTH)
         {
            if(param2 is String)
            {
               this.m_wrapWidth = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_wrapWidth = param2;
            }
            if(this.m_wrapWidth == 0)
            {
               this.m_wrapWidth = Number.NaN;
            }
            this.setup();
            notifyResized();
         }
         else if(param1 == ATTRIBUTE_SCALE_WIDTH)
         {
            if(param2 is String)
            {
               this.m_scaleWidth = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_scaleWidth = param2;
            }
            this.setup();
            notifyResized();
         }
         else
         {
            super.setAttribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_TEXT)
         {
            if(this.m_textField)
            {
               _loc2_ = this.m_textField.text;
            }
         }
         else if(param1 == ATTRIBUTE_WRAP_WIDTH)
         {
            _loc2_ = this.m_wrapWidth;
         }
         else if(param1 == ATTRIBUTE_ALIGN)
         {
            _loc2_ = this.m_align;
         }
         else if(param1 == ATTRIBUTE_FONT_SIZE)
         {
            _loc2_ = this.m_overrideFontSize;
         }
         else if(param1 == ATTRIBUTE_SELECTABLE)
         {
            if(this.m_textField)
            {
               _loc2_ = this.m_textField.selectable;
            }
         }
         else if(param1 == ATTRIBUTE_WORD_WRAP)
         {
            _loc2_ = this.m_wordWrap;
         }
         else if(param1 == ATTRIBUTE_SCALE_WIDTH)
         {
            _loc2_ = this.m_scaleWidth;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override public function localizeAttributeValue(param1:MT4DManager, param2:String, param3:String) : String
      {
         if(param2 == ATTRIBUTE_TEXT)
         {
            return Utility.localizeAttributeValue(param1.config,param3);
         }
         return super.localizeAttributeValue(param1,param2,param3);
      }
   }
}

