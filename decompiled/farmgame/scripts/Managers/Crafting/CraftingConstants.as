package Managers.Crafting
{
   public class CraftingConstants
   {
      
      public static const MAX_INDIVIDUAL_UNSHARABLE_BUSHEL_LIMIT:int = 50;
      
      public static const CAN_MAKE_RECIPE:int = 0;
      
      public static const OVEN_SLOTS_FULL:int = 1;
      
      public static const MAX_BUSHEL_CAPACITY:int = 2;
      
      public static const REWARD_ON_FINISH:String = "OnFinish";
      
      public static const REWARD_ON_MAKE:String = "OnMake";
      
      public static const REWARD_ON_USE:String = "OnUse";
      
      public static const ON_MOTD_RECIPE_INGREDIENTS_GRANTED:Number = 2;
      
      public static const MAX_INDIVIDUAL_STALL_AGE:int = 600;
      
      public static const MAX_GLOBAL_REFRESH_SECONDS:int = 600;
      
      public static const REWARD_PICK_COINS:int = 1;
      
      public static const REWARD_PICK_FUEL:int = 2;
      
      public static const REWARD_PICK_XP:int = 3;
      
      public static const MARKETSTALL_CASH_ITEM_CODE:String = "mc";
      
      public static const MARKETSTALL_COIN_ITEM_CODE:String = "ms";
      
      public static const BASE_STALL_DURATION:Number = 86400;
      
      public static const STALL_MASTERY_MODIFER:Number = 0.333;
      
      public static const CRAFTING_UNLOCK_LEVEL:int = 15;
      
      public static const MARKET_FULL_IMAGE_NAME:String = "market_icon";
      
      public static const BAKERY_SKILL:String = "bakery";
      
      public static const WINERY_SKILL:String = "winery";
      
      public static const PERFUMERY_SKILL:String = "perfumery";
      
      public static const CRAFTSHOP_SKILL:String = "craftshop";
      
      public static const PIZZASHOP_SKILL:String = "pizzashop";
      
      public static const HANGING_GARDENS_CRAFTINGSHOP_SKILL:String = "hgcraftingshop";
      
      public static const VILLAGE_RESOURCE_BUILDING_SKILL:String = "resourceBuilding";
      
      public static const LABTYPE_RECIPE:String = "lab";
      
      public static const CALLOUT_SWF:String = "craftCompleteSwf";
      
      public static const CRAFT_COMPLETE_SOUND:String = "craftCompleteSound";
      
      public static const CRAFTSHOP_SPECIALIZATION:String = "common";
      
      public static const VILLAGE_SPECIALIZATION:String = "village";
      
      public static const MISSION_TYPE_CRAFTING:String = "crafting";
      
      public static const BUILDINGNAME_CRAFTINGSILO:String = "craftingsilo";
      
      public static const RECIPE_LOCKED_UNAVAILABLE:int = 1;
      
      public static const RECIPE_LOCKED_LOW_SKILL:int = 2;
      
      public static const RECIPE_LOCKED_BUYABLE:int = 3;
      
      public static const RECIPE_LOCKED_COMING_SOON:int = 4;
      
      public static const RECIPE_LOCKED_UNKNOWN:int = -1;
      
      public static const RECIPE_STATE_LOCK:String = "comingSoon";
      
      public static const RECIPE_STATE_HAS_INGREDIENTS:String = "hasIngredients";
      
      public static const RECIPE_STATE_RECIPE_MASTERY_LOCKED:String = "recipeMasteryLocked";
      
      public static const RECIPE_STATE_PREREQ_LOCKED:String = "recipePrereqLocked";
      
      public static const RECIPE_STATE_IN_PROGRESS:String = "inProgress";
      
      public static const RECIPE_STATE_COMPLETE:String = "recipeComplete";
      
      public static const LOGFIELD_TIMESTAMP:String = "ts";
      
      public static const LOGFIELD_ACTION:String = "a";
      
      public static const LOGFIELD_DATA:String = "d";
      
      public static const LOGACTION_RECIPE_LVL:String = "rl";
      
      public static const LOGACTION_SOLD:String = "s";
      
      public static const LOGDATA_RECIPE_LVL:String = "rv";
      
      public static const LOGDATA_RECIPE_ID:String = "id";
      
      public static const LOGDATA_REWARD_LINK:String = "k";
      
      public static const LOGDATA_ITEMCODE:String = "ic";
      
      public static const LOGDATA_PRICE:String = "pr";
      
      public static const LOGDATA_QTY:String = "q";
      
      public static const LOGDATA_UID:String = "u";
      
      public static const LOGDATA_UID_OVERFLOW:String = "v";
      
      public static const TABBREV_INVENTORY:String = "in";
      
      public static const TABBREV_ITEMCODE:String = "ic";
      
      public static const TABBREV_TIMESTAMP:String = "ts";
      
      public static const TABBREV_QUANTITY:String = "q";
      
      public static const TABBREV_PRICE:String = "pr";
      
      public static const CRAFTED_GOOD_STORAGE_NAME:String = "CraftedGoodsBox";
      
      public static const NEW_LIMITED_RECIPE_SEEN_FLAG_PREFIX:String = "SeenNewLimitedRecipe_";
      
      public static const EXPIRING_RECIPE_SEEN_FLAG_PREFIX:String = "SeenExpiringRecipe_";
      
      public static const EXCHANGE_RECIPE_SEEN_FLAG_PREFIX:String = "SeenExchangeRecipe_";
      
      public static const RECIPE_LIMITED_TIME_INDICATOR:String = "assets/crafting_cottages/Craft_Indicator_Time.png";
      
      public static const SECONDARY_POPUP_NONE:int = 0;
      
      public static const SECONDARY_POPUP_GET_GOODS:int = 1;
      
      public static const SECONDARY_POPUP_USE_GOODS:int = 2;
      
      public static const MAX_NUM_MASTERY_LEVELS:int = 5;
      
      public static const MAX_POSSIBLE_OVEN_SLOTS:int = 8;
      
      public static const CREW_NEEDED_FOR_BONUS_ITEM:int = 4;
      
      public static const CRAFTSHOP_NUM_HELPERS:int = 4;
      
      public static const CRAFTSHOP_DEFAULT_ICON_URL:String = "assets/buildings/bldg_craftingworkshop_icon.png";
      
      public static const CRAFTING_PROPERTIES_FILE:String = "Crafting";
      
      public static const CRAFTING_GENERAL_LOCKED:String = "General_Locked";
      
      public static const CRAFTSHOP_WORLD_CURRENCY:String = "world_currency";
      
      public function CraftingConstants()
      {
         super();
      }
   }
}

