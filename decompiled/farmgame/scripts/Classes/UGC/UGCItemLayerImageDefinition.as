package Classes.UGC
{
   public class UGCItemLayerImageDefinition
   {
      
      private var m_ugcItemLayerDef:UGCItemLayerDefinition;
      
      private var m_exportName:String;
      
      private var m_layerPriority:int;
      
      public function UGCItemLayerImageDefinition(itemLayerDef:UGCItemLayerDefinition, exportName:String, layerPriority:int)
      {
         super();
         this.m_ugcItemLayerDef = itemLayerDef;
         this.m_exportName = exportName;
         this.m_layerPriority = layerPriority;
      }
      
      public function get ugcItemLayerDefinition() : UGCItemLayerDefinition
      {
         return this.m_ugcItemLayerDef;
      }
      
      public function get exportName() : String
      {
         return this.m_exportName;
      }
      
      public function get layerPriority() : int
      {
         return this.m_layerPriority;
      }
   }
}

