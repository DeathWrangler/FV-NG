package Classes.Minigames
{
   import Classes.util.ParseXMLUtil;
   
   public class DialogFeatureData extends BaseFeatureData
   {
      
      private static const TAG_CLASS:String = "class";
      
      private static const TAG_ASSET:String = "asset";
      
      private var m_dialogClass:String = null;
      
      private var m_dialogAsset:String = null;
      
      public function DialogFeatureData(xml:XML, parent:MinigameData)
      {
         super(xml,parent);
      }
      
      public function get dialogClass() : String
      {
         return this.m_dialogClass;
      }
      
      public function get dialogAsset() : String
      {
         return this.m_dialogAsset;
      }
      
      override protected function parseXML() : void
      {
         super.parseXML();
         if(m_rawXml)
         {
            this.m_dialogClass = ParseXMLUtil.parseRequiredString(m_rawXml,TAG_CLASS);
            this.m_dialogAsset = ParseXMLUtil.parseRequiredString(m_rawXml,TAG_ASSET);
            return;
         }
         throw new Error("Error: no <feature name=\"dialog\"> in xml");
      }
   }
}

