package Classes.util
{
   import Classes.Constants.Experiments;
   import Widgets.Constants.Market.Currency;
   
   public class CurrencyConversionUtil
   {
      
      private static const CURRENCY_ITEM_TOKEN_PREFIX:String = "_exchange_variant";
      
      private static const CURRENCY_COCONUT_ITEM_TOKEN_PREFIX:String = "coconuts_exchange_variant";
      
      private static const CURRENCY_JADE_ITEM_TOKEN_PREFIX:String = "jade_exchange_variant";
      
      private static const CURRENCY_ITEMS:Array = [CURRENCY_COCONUT_ITEM_TOKEN_PREFIX,CURRENCY_JADE_ITEM_TOKEN_PREFIX];
      
      private static const CURRENCY_COCONUT_ITEM_TOKEN_WALLET:String = "wallet";
      
      public function CurrencyConversionUtil()
      {
         super();
      }
      
      public static function isCurrencyExchangeItem(exchangeItemName:String) : Boolean
      {
         var prefix:String = null;
         var result:Boolean = false;
         for each(prefix in CURRENCY_ITEMS)
         {
            if(exchangeItemName.indexOf(prefix) == 0)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public static function isValidCurrencyExchangeItem(exchangeItemName:String, currencyType:String) : Boolean
      {
         var result:Boolean = false;
         switch(currencyType)
         {
            case Currency.COCONUTS:
               return isValidCoconutExchangeItem(exchangeItemName);
            case Currency.JADE:
               return isValidJadeExchangeItem(exchangeItemName);
            default:
               return result;
         }
      }
      
      private static function isValidCoconutExchangeItem(exchangeItemName:String) : Boolean
      {
         var result:Boolean = false;
         var experimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_HAWAII_IMPULSE_COCONUTS);
         if(experimentVariant == 0)
         {
            experimentVariant = Experiments.VARIANT_IMPULSE_COCONUTS_3PAYMENT_DYNAMIC_DISCOUNT_1;
         }
         var walletVariant:int = getWalletTier();
         var currencyItemPattern:String = CURRENCY_COCONUT_ITEM_TOKEN_PREFIX + experimentVariant;
         switch(experimentVariant)
         {
            case Experiments.VARIANT_IMPULSE_COCONUTS_3PAYMENT_DYNAMIC_DISCOUNT_1:
            case Experiments.VARIANT_IMPULSE_COCONUTS_3PAYMENT_DYNAMIC_DISCOUNT_2:
               currencyItemPattern = CURRENCY_COCONUT_ITEM_TOKEN_PREFIX + experimentVariant + "_" + CURRENCY_COCONUT_ITEM_TOKEN_WALLET + walletVariant;
         }
         if(exchangeItemName.indexOf(currencyItemPattern) >= 0)
         {
            return true;
         }
         return result;
      }
      
      private static function isValidJadeExchangeItem(exchangeItemName:String) : Boolean
      {
         var result:Boolean = false;
         if(exchangeItemName.indexOf(CURRENCY_JADE_ITEM_TOKEN_PREFIX) >= 0)
         {
            return true;
         }
         return result;
      }
      
      private static function getWalletTier() : int
      {
         var walletTier:int = 1;
         var playerCash:int = Global.player.cash;
         if(playerCash >= 0 && playerCash <= 15)
         {
            walletTier = 1;
         }
         else if(playerCash > 15 && playerCash <= 25)
         {
            walletTier = 2;
         }
         else if(playerCash > 25 && playerCash <= 70)
         {
            walletTier = 3;
         }
         else
         {
            walletTier = 4;
         }
         return walletTier;
      }
   }
}

