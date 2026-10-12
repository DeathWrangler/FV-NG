package com.troyer.widget.style
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.parser.Utility;
   import flash.utils.Dictionary;
   
   public class BaseStyle
   {
      
      public static const FONT_NAME:String = "name";
      
      public static const FONT_SIZE:String = "size";
      
      public static const FONT_COLOR:String = "color";
      
      public static const FONT_COLOR_BG:String = "colorBg";
      
      public static const FONT_COLOR_BORDER:String = "colorBorder";
      
      public static const FONT_BOLD:String = "bold";
      
      public static const FONT_ITALIC:String = "italic";
      
      public static const FONT_ALIGN:String = "align";
      
      public static const FONT_HTML:String = "html";
      
      public static const FONT_EMBEDDED:String = "embedded";
      
      public static const FONT_BORDER:String = "border";
      
      public static const FONT_INPUT:String = "input";
      
      public static const FONT_LIMIT:String = "limit";
      
      public static const FONT_PASSWORD:String = "password";
      
      public static const FONT_RESTRICT:String = "restrict";
      
      public static const FONT_FORMATTING:String = "formatting";
      
      public static const FONT_FORMATTING_ALIGN:String = "align";
      
      public static const FONT_FORMATTING_BLOCK_INDENT:String = "blockIndent";
      
      public static const FONT_FORMATTING_BOLD:String = "bold";
      
      public static const FONT_FORMATTING_BULLET:String = "bullet";
      
      public static const FONT_FORMATTING_COLOR:String = "color";
      
      public static const FONT_FORMATTING_FONT:String = "font";
      
      public static const FONT_FORMATTING_INDENT:String = "indent";
      
      public static const FONT_FORMATTING_ITALIC:String = "italic";
      
      public static const FONT_FORMATTING_KERNING:String = "kerning";
      
      public static const FONT_FORMATTING_LEADING:String = "leading";
      
      public static const FONT_FORMATTING_LEFT_MARGIN:String = "leftMargin";
      
      public static const FONT_FORMATTING_LETTER_SPACING:String = "letterSpacing";
      
      public static const FONT_FORMATTING_RIGHT_MARGIN:String = "rightMargin";
      
      public static const FONT_FORMATTING_SIZE:String = "size";
      
      public static const FONT_FORMATTING_TAB_STOPS:String = "tabStops";
      
      public static const FONT_FORMATTING_TARGET:String = "target";
      
      public static const FONT_FORMATTING_UNDERLINE:String = "underline";
      
      public static const FONT_FORMATTING_URL:String = "url";
      
      public static const SKIN_VIEW:String = "view";
      
      public static const SKIN_TARGET:String = "target";
      
      public static const SKIN_INJECT_TARGET:String = "injectTarget";
      
      public static const DATA_SCALE:String = "scale";
      
      public static const DATA_ROUND:String = "round";
      
      public static const DATA_BORDER:String = "border";
      
      public static const DATA_ANGLE:String = "angle";
      
      public static const DATA_COLORS:String = "colors";
      
      public static const DATA_GRADIENT_TYPE:String = "gradientType";
      
      public static const DATA_DISTRIBUTION:String = "distribution";
      
      public static const DATA_IMAGE:String = "image";
      
      public static const DATA_TILED:String = "tiled";
      
      public static const DATA_THICKNESS:String = "thickness";
      
      public static const DATA_ALPHA:String = "alpha";
      
      public static const DEFAULT_THICKNESS:Number = 2;
      
      public static const KEY_NAME:String = "name";
      
      public static const KEY_SKIN:String = "skin";
      
      public static const KEY_COLORS:String = "colors";
      
      public static const KEY_FILTERS:String = "filters";
      
      public static const KEY_DATA:String = "data";
      
      public static const KEY_FONTS:String = "fonts";
      
      private var m_name:String;
      
      private var m_context:MT4DContext;
      
      private var m_skin:Dictionary;
      
      private var m_colors:Array;
      
      private var m_filters:Array;
      
      private var m_fonts:Array;
      
      private var m_data:Dictionary;
      
      public function BaseStyle(param1:MT4DContext = null)
      {
         super();
         if(param1 == null)
         {
            this.m_context = MT4DManager.getInstance().getDefaultContext();
         }
         else
         {
            this.m_context = param1;
         }
      }
      
      private function getWrappedIndex(param1:Array, param2:int) : *
      {
         var _loc3_:* = null;
         if(Boolean(param1) && param1.length > 0)
         {
            param2 %= param1.length;
            _loc3_ = param1[param2];
         }
         return _loc3_;
      }
      
      public function getColor(param1:int) : uint
      {
         return this.getWrappedIndex(this.m_colors,param1);
      }
      
      public function getFilters() : Array
      {
         return this.m_filters;
      }
      
      public function getFont(param1:int) : Object
      {
         return this.getWrappedIndex(this.m_fonts,param1) as Object;
      }
      
      public function getName() : String
      {
         return this.m_name;
      }
      
      public function deserialize(param1:Dictionary) : void
      {
         if(param1.hasOwnProperty("name"))
         {
            this.m_name = param1.name;
         }
         if(param1.hasOwnProperty("skin") && param1.skin is Object)
         {
            this.m_skin = param1.skin;
         }
         if(param1.hasOwnProperty("colors") && param1.colors is Array)
         {
            this.m_colors = param1.colors;
         }
         if(param1.hasOwnProperty("filters") && param1.filters is Array)
         {
            this.m_filters = param1.filters;
         }
         if(param1.hasOwnProperty("data") && param1.data is Object)
         {
            this.m_data = param1.data;
         }
         if(param1.hasOwnProperty("fonts") && param1.fonts is Array)
         {
            this.m_fonts = param1.fonts;
         }
      }
      
      public function serialize() : Dictionary
      {
         var _loc1_:Dictionary = new Dictionary();
         _loc1_[KEY_NAME] = this.m_name;
         _loc1_[KEY_SKIN] = Utility.cloneDictionary(this.m_skin);
         _loc1_[KEY_COLORS] = Utility.cloneArray(this.m_colors);
         _loc1_[KEY_FILTERS] = Utility.cloneArray(this.m_filters);
         _loc1_[KEY_DATA] = Utility.cloneDictionary(this.m_data);
         _loc1_[KEY_FONTS] = Utility.cloneArray(this.m_fonts);
         return _loc1_;
      }
      
      public function hasSkin() : Boolean
      {
         return this.m_skin != null;
      }
      
      public function getSkinViewData() : Dictionary
      {
         return this.m_skin != null ? this.m_skin.view as Dictionary : null;
      }
      
      public function getSkinTarget() : String
      {
         return this.m_skin != null ? this.m_skin.target as String : null;
      }
      
      public function getSkinInjectTarget() : String
      {
         return this.m_skin != null ? this.m_skin.injectTarget as String : null;
      }
      
      public function hasData(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(Boolean(this.m_data) && this.m_data.hasOwnProperty(param1))
         {
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function getData(param1:String) : String
      {
         var _loc2_:String = null;
         if(Boolean(this.m_data) && this.m_data.hasOwnProperty(param1))
         {
            _loc2_ = this.m_data[param1];
         }
         return _loc2_;
      }
   }
}

