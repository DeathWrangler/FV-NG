package Classes.storage
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureCraftingManager;
   
   public class MasterySignStorageFilter extends StorageFilter
   {
      
      public static const RECIPE_MASTERY:String = "recipe";
      
      private var m_masterySignTypes:Array;
      
      public function MasterySignStorageFilter(xml:XML, storagedata:Object)
      {
         var elem:XML = null;
         var elemData:String = null;
         this.m_masterySignTypes = new Array();
         super(xml,storagedata);
         if(xml)
         {
            for each(elem in xml.descendants("masterySignType"))
            {
               this.m_masterySignTypes.push(elem.toString());
            }
         }
         else if(storagedata)
         {
            for each(elemData in storagedata["masterySignType"])
            {
               this.m_masterySignTypes.push(elemData.toString());
            }
         }
      }
      
      override public function canTake(item:MapResource) : Boolean
      {
         var masteredItemName:String = null;
         var masterySignName:String = null;
         var recipeName:String = null;
         var codeStr:String = null;
         var masteredItem:FarmItem = null;
         var regularCropCode:String = null;
         var masteredOrganicItem:FarmItem = null;
         var parentItem:FarmItem = null;
         var result:Boolean = false;
         if(Boolean(item) && Boolean(item.getItem()))
         {
            masteredItemName = Global.farmGameSettingsManager.getItemNameFromMasterySign(item.getItem().name);
            if(this.m_masterySignTypes.indexOf(RECIPE_MASTERY) != -1)
            {
               codeStr = item.getItem().code;
               result = null != Global.craftConfigSettings.getRecipeByMasterySign(item.getItem().code);
            }
            if(!result && Boolean(masteredItemName))
            {
               masteredItem = Global.farmGameSettingsManager.getFarmItemByName(masteredItemName);
               if(Boolean(masteredItem) && this.m_masterySignTypes.indexOf(masteredItem.type) != -1)
               {
                  result = true;
               }
            }
            else
            {
               regularCropCode = "";
               masteredOrganicItem = Global.farmGameSettingsManager.getFarmItemByName(item.getItem().name);
               if(masteredOrganicItem)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     regularCropCode = masteredOrganicItem.getStringFromDataSource("masteredItemCode");
                  }
                  else
                  {
                     regularCropCode = masteredOrganicItem.xml.masteredItemCode;
                  }
                  parentItem = Global.farmGameSettingsManager.getFarmItemByCode(regularCropCode);
                  if(Boolean(parentItem) && this.m_masterySignTypes.indexOf(parentItem.type) != -1)
                  {
                     result = true;
                  }
               }
            }
            masterySignName = item.getItem().name;
            recipeName = null;
            if(masterySignName.search("_") > 0)
            {
               recipeName = masterySignName.split("_")[1];
            }
            else if(masterySignName.indexOf("master") == 0)
            {
               recipeName = masterySignName.substr(6);
            }
            if(result == false && recipeName != null && this.m_masterySignTypes.indexOf(RECIPE_MASTERY) != -1)
            {
               result = FeatureCraftingManager.instance.getRecipeForMasterySign(recipeName) != null;
            }
         }
         return result;
      }
   }
}

