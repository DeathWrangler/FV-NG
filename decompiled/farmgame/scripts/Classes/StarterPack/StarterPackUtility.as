package Classes.StarterPack
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   
   public class StarterPackUtility
   {
      
      public static const STARTERPACK_PURCHASE_CATEGORY:String = "99";
      
      public static const STARTER_PACK_MARKET_AD_KINGDOM:String = "starterpack_marketad";
      
      public static const STARTER_PACK_MARKET_CARD_KINGDOM:String = "starterpack_marketcard";
      
      public static const STARTER_PACK_MARKET_CLICK_PHYLUM:String = "click";
      
      public static const STARTER_PACK_MARKET_VIEW_PHYLUM:String = "view";
      
      public static const GIFT_TYPE_FIELD:String = "type";
      
      public static const CASH_GIFT_TYPE:String = "cash";
      
      public static const CASH_QUANTITY_FIELD:String = "value";
      
      public static const CASH_ICON_URL:String = "assets/consumables/fv_cash.png";
      
      public static const COIN_GIFT_TYPE:String = "coins";
      
      public static const COIN_QUANTITY_FIELD:String = "value";
      
      public static const COIN_ICON_URL:String = "assets/consumables/fv_coin.png";
      
      public static const ITEM_GIFT_TYPE:String = "item";
      
      public static const ITEM_QUANTITY_FIELD:String = "quantity";
      
      public static const KEY_REQUIREMENTS:String = "prereqs";
      
      public static const STARTER_PACK_PROMO_SLOT:int = 2;
      
      public static const STARTER_PACK_PROMO_FLAG:String = "MARKET_PROMO_STARTER_PACK";
      
      public function StarterPackUtility()
      {
         super();
      }
      
      public static function getVisibleStarterPacks() : Array
      {
         var campaign:Object = null;
         var eligibleForCampaign:Boolean = false;
         var campaignRequirement:Object = null;
         var eligibleStarterPacks:Array = new Array();
         var campaigns:Array = Global.farmGameSettingsManager.getStarterPackCampaigns();
         for each(campaign in campaigns)
         {
            eligibleForCampaign = true;
            for each(campaignRequirement in campaign[KEY_REQUIREMENTS])
            {
               campaignRequirement[PrerequisiteConstants.KEY_PACK_NAME] = campaign[PrerequisiteConstants.KEY_PACK_NAME];
               eligibleForCampaign = PrerequisiteUtility.isPrerequisiteMet(campaignRequirement);
               if(eligibleForCampaign == false)
               {
                  break;
               }
            }
            if(eligibleForCampaign == true)
            {
               eligibleStarterPacks.push(campaign[PrerequisiteConstants.KEY_PACK_NAME]);
            }
         }
         return eligibleStarterPacks;
      }
      
      public static function getBestVisibleStarterPack() : StarterPack
      {
         var bestPack:StarterPack = null;
         var starterPacks:Array = getVisibleStarterPacks();
         if(starterPacks.length > 0)
         {
            bestPack = Global.farmGameSettingsManager.getStarterPackByName(starterPacks[0]);
         }
         return bestPack;
      }
      
      public static function starterPacksAvailable() : Boolean
      {
         var packsAvailable:Boolean = false;
         var starterPacks:Array = getVisibleStarterPacks();
         if(starterPacks.length > 0)
         {
            packsAvailable = true;
         }
         return packsAvailable;
      }
      
      public static function getStarterPackIcon(gift:Object) : String
      {
         var farmItem:FarmItem = null;
         var iconURL:String = "";
         if(gift[GIFT_TYPE_FIELD] == ITEM_GIFT_TYPE)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(gift.value);
            if(farmItem)
            {
               iconURL = farmItem.iconUrl;
            }
         }
         else if(gift[GIFT_TYPE_FIELD] == CASH_GIFT_TYPE)
         {
            iconURL = Global.getAssetURL(CASH_ICON_URL);
         }
         else if(gift[GIFT_TYPE_FIELD] == COIN_GIFT_TYPE)
         {
            iconURL = Global.getAssetURL(COIN_ICON_URL);
         }
         return iconURL;
      }
      
      public static function getStarterPackQuantity(gift:Object) : Number
      {
         var giftQuantity:Number = 0;
         if(gift[GIFT_TYPE_FIELD] == ITEM_GIFT_TYPE)
         {
            giftQuantity = Number(gift[ITEM_QUANTITY_FIELD]);
         }
         else if(gift[GIFT_TYPE_FIELD] == CASH_GIFT_TYPE)
         {
            giftQuantity = Number(gift[CASH_QUANTITY_FIELD]);
         }
         else if(gift[GIFT_TYPE_FIELD] == COIN_GIFT_TYPE)
         {
            giftQuantity = Number(gift[COIN_QUANTITY_FIELD]);
         }
         return giftQuantity;
      }
      
      public static function starterPackItemSort(itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         if(itemA[GIFT_TYPE_FIELD] < itemB[GIFT_TYPE_FIELD])
         {
            result = -1;
         }
         else if(itemA[GIFT_TYPE_FIELD] > itemB[GIFT_TYPE_FIELD])
         {
            result = 1;
         }
         return result;
      }
   }
}

