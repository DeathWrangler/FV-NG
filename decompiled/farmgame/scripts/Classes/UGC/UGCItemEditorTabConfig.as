package Classes.UGC
{
   public class UGCItemEditorTabConfig
   {
      
      private static const XML_ATTR_NAME:String = "@name";
      
      private static const XML_ATTR_ELEMENT:String = "@element";
      
      private static const XML_ATTR_DEFAULT:String = "@default";
      
      private var m_name:String;
      
      private var m_element:String;
      
      private var m_default:Boolean;
      
      public function UGCItemEditorTabConfig(xml:XML)
      {
         super();
         if(xml.hasOwnProperty(XML_ATTR_NAME))
         {
            this.m_name = xml[XML_ATTR_NAME].toString();
            if(xml.hasOwnProperty(XML_ATTR_ELEMENT))
            {
               this.m_element = xml[XML_ATTR_ELEMENT].toString();
               this.m_default = false;
               if(xml.hasOwnProperty(XML_ATTR_DEFAULT))
               {
                  this.m_default = xml[XML_ATTR_DEFAULT].toString() == "true";
               }
               return;
            }
            throw new Error("UGCItemEditorTabConfig tab is missing " + XML_ATTR_ELEMENT + "!");
         }
         throw new Error("UGCItemEditorTabConfig tab is missing " + XML_ATTR_NAME + "!");
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get element() : String
      {
         return this.m_element;
      }
      
      public function get isDefault() : Boolean
      {
         return this.m_default;
      }
   }
}

