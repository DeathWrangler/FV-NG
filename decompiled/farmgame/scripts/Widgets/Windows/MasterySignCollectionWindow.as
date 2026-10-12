package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureCraftingManager;
   
   public class MasterySignCollectionWindow extends ItemCollectionWindow
   {
      
      public function MasterySignCollectionWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function buildContents() : Array
      {
         var itemCode:String = null;
         var masterySignName:String = null;
         var masteryItemName:String = null;
         var masteryItem:FarmItem = null;
         var regularCropCode:String = null;
         var masteredOrganicItem:FarmItem = null;
         var recipe:RecipeItem = null;
         var recipeName:String = null;
         var featureCraftingRecipe:FeatureCraftingRecipe = null;
         var contents:Array = new Array();
         for(itemCode in m_contents)
         {
            masterySignName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
            masteryItemName = Global.farmGameSettingsManager.getItemNameFromMasterySign(masterySignName);
            masteryItem = Global.farmGameSettingsManager.getFarmItemByName(masteryItemName);
            if(m_contents[itemCode] != 0 && Boolean(masteryItemName))
            {
               contents.push({
                  "code":itemCode,
                  "name":masteryItem.friendlyTitle,
                  "previewItemName":masteryItemName,
                  "icon":masteryItem.iconUrl,
                  "quantity":m_contents[itemCode],
                  "callbacks":{"remove":generateRemoveItemCallback(itemCode)}
               });
            }
            else if(m_contents[itemCode] != 0)
            {
               regularCropCode = "";
               masteredOrganicItem = Global.farmGameSettingsManager.getFarmItemByName(masterySignName);
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
               }
               masteryItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(regularCropCode);
               masteryItem = Global.farmGameSettingsManager.getFarmItemByName(masteryItemName);
               if(Boolean(masteryItemName) && Boolean(masteryItem))
               {
                  contents.push({
                     "code":itemCode,
                     "name":masteryItem.friendlyTitle,
                     "previewItemName":masteryItemName,
                     "icon":masteryItem.iconUrl,
                     "quantity":m_contents[itemCode],
                     "callbacks":{"remove":generateRemoveItemCallback(itemCode)}
                  });
               }
               else
               {
                  recipe = Global.craftConfigSettings.getRecipeByMasterySign(itemCode);
                  if(recipe)
                  {
                     contents.push({
                        "code":itemCode,
                        "name":ZLocUtils.tk_pk_asTitle(recipe.friendlyName),
                        "icon":recipe.image,
                        "quantity":m_contents[itemCode],
                        "callbacks":{"remove":generateRemoveItemCallback(itemCode)}
                     });
                  }
                  else
                  {
                     recipeName = null;
                     if(masterySignName.search("_") > 0)
                     {
                        recipeName = masterySignName.split("_")[1];
                     }
                     else if(masterySignName.indexOf("master") == 0)
                     {
                        recipeName = masterySignName.substr(6);
                     }
                     if(recipeName != null)
                     {
                        featureCraftingRecipe = FeatureCraftingManager.instance.getRecipeForMasterySign(recipeName);
                        if(featureCraftingRecipe)
                        {
                           contents.push({
                              "code":itemCode,
                              "name":featureCraftingRecipe.friendlyTitle,
                              "icon":featureCraftingRecipe.iconUrl,
                              "quantity":m_contents[itemCode],
                              "callbacks":{"remove":generateRemoveItemCallback(itemCode)}
                           });
                        }
                     }
                  }
               }
            }
         }
         contents.sortOn("name");
         return contents;
      }
   }
}

