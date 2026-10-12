package Widgets.Constants.Market
{
   public class Currency
   {
      
      public static const COINS:String = "coins";
      
      public static const GOLD:String = "gold";
      
      public static const CASH:String = "cash";
      
      public static const COCONUTS:String = "coconuts";
      
      public static const JADE:String = "jade";
      
      public static const TROWELS:String = "trowels";
      
      public static const COST_STATUS_POINTS:String = "loyaltyPoints";
      
      public static const BERRY:String = "berry";
      
      public static const BOTH:String = "both";
      
      public static const NECTAR:String = "nectar";
      
      private static const ICONS:Object = {
         "coins":"assets/decorations/fv_coin_icon.png",
         "cash":"assets/consumables/consume_cash_icon.png",
         "coconuts":"assets/consumables/consume_coconuts_icon.png",
         "jade":"assets/consumables/consume_jade_icon.png",
         "trowels":"assets/newsfeed/task_goldtrowel.png",
         "nectar":"assets/consumables/task_nectaricon_icon.png"
      };
      
      public function Currency()
      {
         super();
      }
      
      public static function getIcon(unit:String) : String
      {
         return ICONS[unit];
      }
   }
}

