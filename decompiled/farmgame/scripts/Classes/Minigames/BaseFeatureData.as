package Classes.Minigames
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ParseXMLUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import flash.utils.getQualifiedClassName;
   
   public class BaseFeatureData
   {
      
      private static const ZLOC_KEY_MINIGAME:String = "Minigame";
      
      private static const ATTR_NAME:String = "@name";
      
      protected var m_rawXml:XML = null;
      
      protected var m_parentMinigameData:MinigameData = null;
      
      private var m_name:String = null;
      
      private var m_zlocFallbackKey:String = null;
      
      public function BaseFeatureData(xml:XML, parent:MinigameData)
      {
         super();
         this.m_rawXml = xml;
         this.m_parentMinigameData = parent;
         this.parseXML();
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      private function get className() : String
      {
         return getQualifiedClassName(this);
      }
      
      protected function parseXML() : void
      {
         if(this.m_rawXml)
         {
            this.m_name = ParseXMLUtil.parseRequiredString(this.m_rawXml,ATTR_NAME);
            this.m_zlocFallbackKey = ZLOC_KEY_MINIGAME + FarmGameUtil.toUpperCaseFirst(this.m_name);
         }
      }
      
      protected function getFailOverText(partialKey:String, params:Object = null) : String
      {
         return ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_parentMinigameData.zlocPrefix + partialKey),new ZLocFailoverEntry("Dialogs",this.m_zlocFallbackKey + partialKey)],params);
      }
   }
}

