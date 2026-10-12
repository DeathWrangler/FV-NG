package Widgets.Windows
{
   public class StateIndicatorWindow extends FarmWindow
   {
      
      protected var m_iconUrl:String;
      
      protected var m_title:String;
      
      protected var m_text:String;
      
      public function StateIndicatorWindow(assetUrl:String, iconUrl:String, title:String, text:String)
      {
         super(assetUrl);
         this.m_iconUrl = iconUrl;
         this.m_title = title;
         this.m_text = text;
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function set iconUrl(value:String) : void
      {
         this.m_iconUrl = value;
      }
      
      public function get title() : String
      {
         return this.m_title;
      }
      
      public function set title(value:String) : void
      {
         this.m_title = value;
      }
      
      public function get text() : String
      {
         return this.m_text;
      }
      
      public function set text(value:String) : void
      {
         this.m_text = value;
      }
   }
}

