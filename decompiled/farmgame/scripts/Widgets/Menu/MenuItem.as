package Widgets.Menu
{
   public class MenuItem
   {
      
      private var m_data:Object;
      
      private var m_text:String;
      
      private var m_featured:Boolean;
      
      private var m_newTab:Boolean;
      
      private var m_isLocked:Boolean = false;
      
      private var m_specialTag:String = "";
      
      public function MenuItem(data:Object, text:String, featured:Boolean = false, newTab:Boolean = false, isLocked:Boolean = false, specialTag:String = "")
      {
         super();
         this.m_data = data;
         this.m_text = text;
         this.m_featured = featured;
         this.m_newTab = newTab;
         this.m_isLocked = isLocked;
         this.m_specialTag = specialTag;
      }
      
      public function set featured(value:Boolean) : void
      {
         this.m_featured = value;
      }
      
      public function get featured() : Boolean
      {
         return this.m_featured;
      }
      
      public function get newTab() : Boolean
      {
         return this.m_newTab;
      }
      
      public function set newTab(newTab:Boolean) : void
      {
         this.m_newTab = newTab;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      public function set data(value:Object) : void
      {
         this.m_data = value;
      }
      
      public function get text() : String
      {
         return this.m_text;
      }
      
      public function set text(value:String) : void
      {
         this.m_text = value;
      }
      
      public function set isLocked(value:Boolean) : void
      {
         this.m_isLocked = value;
      }
      
      public function get isLocked() : Boolean
      {
         return this.m_isLocked;
      }
      
      public function get specialTag() : String
      {
         return this.m_specialTag;
      }
   }
}

