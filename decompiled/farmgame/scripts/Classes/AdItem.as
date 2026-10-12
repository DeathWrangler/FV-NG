package Classes
{
   import Classes.util.ZLocUtils;
   import flash.events.EventDispatcher;
   
   public class AdItem extends EventDispatcher
   {
      
      private var m_xml:XML = null;
      
      public function AdItem(xml:XML)
      {
         super();
         this.m_xml = xml;
      }
      
      public function get xml() : XML
      {
         return this.m_xml;
      }
      
      public function get name() : String
      {
         return this.m_xml.@name;
      }
      
      public function get delay() : int
      {
         return this.m_xml.@delay;
      }
      
      public function get duration() : int
      {
         return this.m_xml.@duration;
      }
      
      public function get phylum() : String
      {
         return this.m_xml.@phylum;
      }
      
      public function get title() : String
      {
         var locString:String = this.xml.adTitle;
         var locArray:Array = locString.split(/\:/);
         return ZLocUtils.t(locArray[0],locArray[1]);
      }
      
      public function get desc() : String
      {
         var locString:String = this.xml.adDesc;
         var locArray:Array = locString.split(/\:/);
         return ZLocUtils.t(locArray[0],locArray[1]);
      }
      
      public function get link() : String
      {
         return this.m_xml.link;
      }
   }
}

