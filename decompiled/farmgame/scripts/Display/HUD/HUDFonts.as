package Display.HUD
{
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class HUDFonts
   {
      
      private static var m_titleFmt:TextFormat;
      
      private static var m_resourceFmt:TextFormat;
      
      private static var m_levelFmt:TextFormat;
      
      private static var m_smallLevelFmt:TextFormat;
      
      private static var m_xpFmt:TextFormat;
      
      private static var m_messageCenterTextFmt:TextFormat;
      
      private static const FONT_NAME_TITLE:String = "Merkin";
      
      private static const FONT_NAME_RESOURCE:String = "Merkin2";
      
      private static const FONT_NAME_LEVEL:String = "Merkin2";
      
      private static const FONT_NAME_XP:String = "Merkin2";
      
      private static const FONT_NAME_MESSAGE_CENTER_BUTTON:String = "Merkin2";
      
      private static const FONT_SIZE_TITLE:int = 14;
      
      private static const FONT_SIZE_RESOURCE:int = 14;
      
      private static const FONT_SIZE_LEVEL:int = 14;
      
      private static const FONT_SIZE_SMALL_LEVEL:int = 11;
      
      private static const FONT_SIZE_XP:int = 16;
      
      private static const FONT_SIZE_MESSAGE_CENTER_BUTTON:int = 12;
      
      private static const FONT_COLOR_TITLE:int = 16777215;
      
      private static const FONT_COLOR_RESOURCE:int = 16776444;
      
      private static const FONT_COLOR_LEVEL:int = 7752991;
      
      private static const FONT_COLOR_XP:int = 16777215;
      
      private static const FONT_COLOR_MESSAGE_CENTER_BUTTON:int = 16777215;
      
      public function HUDFonts()
      {
         super();
      }
      
      public static function get TitleText() : TextFormat
      {
         if(m_titleFmt == null)
         {
            m_titleFmt = new TextFormat(FONT_NAME_TITLE,FONT_SIZE_TITLE,FONT_COLOR_TITLE);
         }
         return m_titleFmt;
      }
      
      public static function get ResourceText() : TextFormat
      {
         if(m_resourceFmt == null)
         {
            m_resourceFmt = new TextFormat(FONT_NAME_RESOURCE,FONT_SIZE_RESOURCE,FONT_COLOR_RESOURCE);
         }
         return m_resourceFmt;
      }
      
      public static function get LevelText() : TextFormat
      {
         if(m_levelFmt == null)
         {
            m_levelFmt = new TextFormat(FONT_NAME_LEVEL,FONT_SIZE_LEVEL,FONT_COLOR_LEVEL);
            m_levelFmt.align = TextFormatAlign.CENTER;
         }
         return m_levelFmt;
      }
      
      public static function get SmallLevelText() : TextFormat
      {
         if(m_smallLevelFmt == null)
         {
            m_smallLevelFmt = new TextFormat(FONT_NAME_LEVEL,FONT_SIZE_SMALL_LEVEL,FONT_COLOR_LEVEL);
            m_smallLevelFmt.align = TextFormatAlign.CENTER;
         }
         return m_smallLevelFmt;
      }
      
      public static function get XpText() : TextFormat
      {
         if(m_xpFmt == null)
         {
            m_xpFmt = new TextFormat(FONT_NAME_XP,FONT_SIZE_XP,FONT_COLOR_XP);
            m_xpFmt.align = TextFormatAlign.CENTER;
         }
         return m_xpFmt;
      }
      
      public static function get MessageCenterButtonText() : TextFormat
      {
         if(m_messageCenterTextFmt == null)
         {
            m_messageCenterTextFmt = new TextFormat(FONT_NAME_MESSAGE_CENTER_BUTTON,FONT_SIZE_MESSAGE_CENTER_BUTTON,FONT_COLOR_MESSAGE_CENTER_BUTTON);
            m_messageCenterTextFmt.align = TextFormatAlign.CENTER;
         }
         return m_messageCenterTextFmt;
      }
   }
}

