package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureCraftingManager;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class FeaturedRenderFDecalObject extends Sprite
   {
      
      public static const SKEW_ANGLE_Y:Number = -0.47123889803846897;
      
      public static const ITEM_STROKE_COLOR:Number = 10654327;
      
      public static const ITEM_STROKE_BLUR:Number = 4;
      
      public static const ITEM_STROKE_STRENGTH:Number = 16;
      
      private var m_skewedBitmap:Bitmap;
      
      private const SCALE:Number = 0.45;
      
      public function FeaturedRenderFDecalObject(itemName:String, building:FeatureBuilding)
      {
         var farmItem:FarmItem = null;
         var regularCropCode:String = null;
         var masteredOrganicItem:FarmItem = null;
         var parentItem:FarmItem = null;
         var recipe:RecipeItem = null;
         var recipeName:String = null;
         super();
         var signImageUrl:String = null;
         var farmItemName:String = Global.farmGameSettingsManager.getItemNameFromMasterySign(itemName);
         if(farmItemName != null && farmItemName != "")
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(farmItemName);
            if(farmItem != null)
            {
               signImageUrl = farmItem.iconUrl;
            }
         }
         else
         {
            regularCropCode = "";
            masteredOrganicItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
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
            parentItem = Global.farmGameSettingsManager.getFarmItemByCode(regularCropCode);
            if(parentItem)
            {
               signImageUrl = parentItem.iconUrl;
            }
            else
            {
               recipe = Global.craftConfigSettings.getRecipeByMasterySign(Global.farmGameSettingsManager.getFarmItemCodeByName(itemName));
               if(recipe)
               {
                  signImageUrl = Global.getAssetURL(recipe.image);
               }
               if(!signImageUrl)
               {
                  recipeName = null;
                  if(itemName.search("_") > 0)
                  {
                     recipeName = itemName.split("_")[1];
                  }
                  else if(itemName.indexOf("master") == 0)
                  {
                     recipeName = itemName.substr(6);
                  }
                  if(recipeName != null)
                  {
                     signImageUrl = Global.getAssetURL(FeatureCraftingManager.instance.getImageUrlForRecipe(recipeName));
                  }
               }
            }
         }
         if(signImageUrl == null && Global.farmGameSettingsManager.itemsXMLParsingComplete && FeatureCraftingManager.instance.initialized)
         {
            ErrorManager.addError("FeaturedRenderFDecalObject missing mastered item for:" + itemName);
         }
         else if(signImageUrl != null)
         {
            LoadingManager.load(signImageUrl,this.onIconLoadComplete);
         }
      }
      
      private function onIconLoadComplete(event:Event) : void
      {
         var displayObject:DisplayObject = event.target.content as DisplayObject;
         this.m_skewedBitmap = FarmGameUtil.getSkewedBitmap(displayObject,0,SKEW_ANGLE_Y);
         this.m_skewedBitmap.x = this.m_skewedBitmap.width * -this.SCALE / 2;
         this.m_skewedBitmap.y = this.m_skewedBitmap.height * -this.SCALE / 2;
         this.m_skewedBitmap.scaleX = this.SCALE;
         this.m_skewedBitmap.scaleY = this.SCALE;
         this.addChild(this.m_skewedBitmap);
      }
   }
}

