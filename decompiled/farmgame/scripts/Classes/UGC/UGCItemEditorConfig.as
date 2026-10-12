package Classes.UGC
{
   public class UGCItemEditorConfig
   {
      
      private static const XML_ATTR_DIALOGPATH:String = "@path";
      
      private static const XML_ATTR_WINDOWCLASS:String = "@windowClass";
      
      private var m_dialogPath:String;
      
      private var m_windowClass:String;
      
      private var m_tabs:Array;
      
      public function UGCItemEditorConfig(xml:XML)
      {
         var tabXML:XML = null;
         super();
         if(xml.hasOwnProperty(XML_ATTR_DIALOGPATH))
         {
            this.m_dialogPath = xml[XML_ATTR_DIALOGPATH].toString();
         }
         if(xml.hasOwnProperty(XML_ATTR_WINDOWCLASS))
         {
            this.m_windowClass = xml[XML_ATTR_WINDOWCLASS].toString();
         }
         this.m_tabs = new Array();
         for each(tabXML in xml.tabs.tab as XMLList)
         {
            this.m_tabs.push(new UGCItemEditorTabConfig(tabXML));
         }
      }
      
      public function get dialogPath() : String
      {
         return this.m_dialogPath;
      }
      
      public function get windowClass() : String
      {
         return this.m_windowClass;
      }
      
      public function get tabs() : Array
      {
         return this.m_tabs;
      }
   }
}

