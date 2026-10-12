package Managers.InGameConsole
{
   import Managers.UGCDecoManager;
   import com.adobe.serialization.json.JSON;
   
   public class ConsoleUGCDecoCommandsModule extends InGameConsoleBaseCommandsModule
   {
      
      public function ConsoleUGCDecoCommandsModule()
      {
         super();
      }
      
      override public function get moduleName() : String
      {
         return "ugcdeco";
      }
      
      public function addParts(partId:String, qty:int = 100) : String
      {
         if(UGCDecoManager.instance.getFeatureData()[UGCDecoManager.UGC_MATERIALS_INDEX][partId])
         {
            UGCDecoManager.instance.getFeatureData()[UGCDecoManager.UGC_MATERIALS_INDEX][partId] = qty;
         }
         else
         {
            UGCDecoManager.instance.getFeatureData()[UGCDecoManager.UGC_MATERIALS_INDEX][partId] = UGCDecoManager.instance.getFeatureData()[UGCDecoManager.UGC_MATERIALS_INDEX][partId] + qty;
         }
         sendTransaction("adminCall",{
            "adminController":"CPanelUGCDecorationController",
            "adminCommand":"addMaterial",
            "materialId":partId,
            "qty":qty
         });
         return "You now have : " + partId + " - " + UGCDecoManager.instance.getFeatureData()[UGCDecoManager.UGC_MATERIALS_INDEX][partId];
      }
      
      public function showFeatureData(partId:String, qty:int = 100) : String
      {
         return com.adobe.serialization.json.JSON.encode(UGCDecoManager.instance.getFeatureData());
      }
   }
}

