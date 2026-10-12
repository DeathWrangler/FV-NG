package Classes.Collections
{
   import Classes.GameSettingsObject;
   
   public class CollectionSource extends GameSettingsObject
   {
      
      protected var m_ID:String;
      
      protected var m_sources:Array = new Array();
      
      public function CollectionSource(xml:XML)
      {
         super(xml);
         this.buildSourceNames();
      }
      
      private function buildSourceNames() : void
      {
         var sourceName:String = null;
         var sourceNames:XMLList = m_xml.source;
         for(var sourceIndex:int = 0; sourceIndex < sourceNames.length(); sourceIndex++)
         {
            sourceName = sourceNames[sourceIndex].@name;
            this.m_sources.push(sourceName);
         }
      }
      
      public function get subtype() : String
      {
         return this.m_xml.@subtype;
      }
      
      public function get id() : String
      {
         return this.m_xml.@id;
      }
      
      public function getSourceNames() : Array
      {
         return this.m_sources;
      }
   }
}

