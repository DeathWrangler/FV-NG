package Managers.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.RetentionMasterManager;
   
   public class SmartBushelHelper
   {
      
      public static const FICTIONAL_CHARACTER_ID:String = "999999";
      
      private static const ICON_ASSET_PATH:String = "assets/dialogs/FV_Support/FV_SmartBushels/smartbushels_neighbor_Gilda.png";
      
      private static const UNDEFINED_STATE:int = -1;
      
      private static const NUM_PAGES_TO_CHECK:int = 2;
      
      private static const OFFBOARD_SEEN_FLAG:String = "SmartBushelOffboard";
      
      private static const DISABLE_DATE_TOKEN:String = "smartBushelDisableDate";
      
      private static var s_experimentVariant:int = UNDEFINED_STATE;
      
      public function SmartBushelHelper()
      {
         super();
      }
      
      public static function setupSmartBushels(recipes:Array, slots:int) : void
      {
         var ingredients:Array = null;
         var qtyRequired:int = 0;
         var ingredientItem:FarmItem = null;
         var ingredient:Object = null;
         var numIngredients:int = 0;
         var totalQtyNeeded:int = 0;
         var cachedRecipeIdx:int = 0;
         var tempRequiredItems:Array = null;
         var requiredItems:Array = null;
         var idx:int = 0;
         var ingredientIdx:int = 0;
         var cachedTotalQtyNeeded:int = UNDEFINED_STATE;
         slots = Math.min(slots * NUM_PAGES_TO_CHECK,recipes.length);
         if(!SmartBushelHelper.isExpired())
         {
            for(idx = 0; idx < slots; idx++)
            {
               if(recipes[idx])
               {
                  ingredients = recipes[idx].ingredients;
                  totalQtyNeeded = 0;
                  tempRequiredItems = new Array();
                  for(ingredientIdx = 0; ingredientIdx < ingredients.length; ingredientIdx++)
                  {
                     ingredient = ingredients[ingredientIdx];
                     ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
                     numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(ingredient.itemCode);
                     qtyRequired = int(ingredient.quantityRequired);
                     totalQtyNeeded += Math.max(qtyRequired - numIngredients,0);
                     tempRequiredItems.push({
                        "itemCode":ingredient.itemCode,
                        "qty":qtyRequired
                     });
                  }
                  if(totalQtyNeeded > 0 && (totalQtyNeeded < cachedTotalQtyNeeded || cachedTotalQtyNeeded == UNDEFINED_STATE))
                  {
                     cachedTotalQtyNeeded = totalQtyNeeded;
                     cachedRecipeIdx = idx;
                     requiredItems = tempRequiredItems;
                  }
               }
            }
            if(requiredItems)
            {
               MarketViewManager.getInstance().insertSmartBushels(requiredItems);
            }
         }
      }
      
      public static function inExperiment() : Boolean
      {
         if(s_experimentVariant == UNDEFINED_STATE)
         {
            s_experimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFT_BOOSTER);
         }
         return RetentionMasterManager.inMasterExperiment() && (s_experimentVariant == 2 || s_experimentVariant == 4);
      }
      
      public static function getFriendData() : Friend
      {
         var imageUrl:String = Global.getAssetURL(ICON_ASSET_PATH);
         return new Friend({
            "name":ZLocUtils.t("Crafting","FictionalCharacterName"),
            "uid":FICTIONAL_CHARACTER_ID,
            "profilePic":imageUrl
         },null,true);
      }
      
      public static function isExpired() : Boolean
      {
         var endDate:String = Global.farmGameSettingsManager.getString(DISABLE_DATE_TOKEN);
         if(endDate == null || endDate == "")
         {
            ErrorManager.addError("Missing Disable Date for SmartBushelHelper");
         }
         return FarmGameUtil.checkEndDateGate(endDate) == false;
      }
      
      public static function smartBushelOffboard() : void
      {
         var message:String = null;
         var imageUrl:String = null;
         var dialog:GenericPopup = null;
         if(Global.player.getSeenFlag(OFFBOARD_SEEN_FLAG) != true)
         {
            message = ZLocUtils.t("Dialogs","SmartBushelOffboardText");
            if(message != "")
            {
               imageUrl = Global.getAssetURL(ICON_ASSET_PATH);
               dialog = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,imageUrl);
               dialog.setAcceptTextName("Okay");
               UI.displayPopup(dialog,false);
               Global.player.setSeenFlag(OFFBOARD_SEEN_FLAG);
            }
         }
      }
   }
}

