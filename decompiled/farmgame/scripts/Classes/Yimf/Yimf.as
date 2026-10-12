package Classes.Yimf
{
   public class Yimf
   {
      
      protected var m_type:String;
      
      protected var m_weights:Array;
      
      protected var m_bgColor:uint;
      
      protected var m_backgroundPath:String = null;
      
      protected var m_outlineColor:uint;
      
      protected var m_outlineAlpha:Number;
      
      protected var m_expansionOutlineColor:uint;
      
      protected var m_tileClass:String;
      
      protected var m_drawOutline:Boolean;
      
      protected var m_horizon:String = null;
      
      protected var m_skyColor:uint;
      
      protected var m_correspondingTheme:String = null;
      
      protected var m_renderBackgroundAtBottom:Boolean;
      
      protected var m_isToolGenerated:Boolean = false;
      
      public function Yimf(xml:XML)
      {
         super();
         this.m_type = String(xml.@type);
         var weightsString:String = String(xml.weights);
         if(weightsString)
         {
            this.m_weights = weightsString.split(",");
         }
         this.m_bgColor = uint(xml.bgColor);
         if(xml.hasOwnProperty("backgroundPath"))
         {
            this.m_backgroundPath = String(xml.backgroundPath);
         }
         this.m_outlineColor = uint(xml.outlineColor);
         if(xml.hasOwnProperty("outlineAlpha"))
         {
            this.m_outlineAlpha = Number(xml.outlineAlpha);
         }
         else
         {
            this.m_outlineAlpha = 1;
         }
         if(xml.hasOwnProperty("expansionColor"))
         {
            this.m_expansionOutlineColor = uint(xml.expansionColor);
         }
         else
         {
            this.m_expansionOutlineColor = this.m_outlineColor;
         }
         if(xml.hasOwnProperty("toolGenerated"))
         {
            this.m_isToolGenerated = true;
         }
         this.m_tileClass = String(xml.tileClass);
         this.m_drawOutline = String(xml.drawOutline) == "true";
         this.m_renderBackgroundAtBottom = String(xml.renderBackgroundAtBottom) == "true";
         if(xml.hasOwnProperty("horizon"))
         {
            this.m_horizon = String(xml.horizon);
         }
         if(xml.hasOwnProperty("skyColor"))
         {
            this.m_skyColor = uint(xml.skyColor);
         }
         if(xml.hasOwnProperty("correspondingTheme"))
         {
            this.m_correspondingTheme = String(xml.correspondingTheme);
         }
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get bgColor() : uint
      {
         return this.m_bgColor;
      }
      
      public function get backgroundPath() : String
      {
         return this.m_backgroundPath;
      }
      
      public function set backgroundPath(url:String) : void
      {
         this.m_backgroundPath = url;
      }
      
      public function get outlineColor() : uint
      {
         return this.m_outlineColor;
      }
      
      public function get outlineAlpha() : Number
      {
         return this.m_outlineAlpha;
      }
      
      public function get expansionOutlineColor() : uint
      {
         return this.m_expansionOutlineColor;
      }
      
      public function get tileClass() : String
      {
         return this.m_tileClass;
      }
      
      public function get drawOutline() : Boolean
      {
         return this.m_drawOutline;
      }
      
      public function get horizon() : String
      {
         return this.m_horizon;
      }
      
      public function set horizon(url:String) : void
      {
         this.m_horizon = url;
      }
      
      public function get weights() : Array
      {
         return this.m_weights;
      }
      
      public function get skyColor() : uint
      {
         return this.m_skyColor;
      }
      
      public function set skyColor(argbColor:uint) : void
      {
         this.m_skyColor = argbColor;
      }
      
      public function get renderBackgroundAtBottom() : Boolean
      {
         return this.m_renderBackgroundAtBottom;
      }
      
      public function get isToolGenerated() : Boolean
      {
         return this.m_isToolGenerated;
      }
      
      public function get correspondingTheme() : String
      {
         return this.m_correspondingTheme;
      }
   }
}

