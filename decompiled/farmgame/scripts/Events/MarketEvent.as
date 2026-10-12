package Events
{
   import flash.events.Event;
   
   public class MarketEvent extends Event
   {
      
      public static const NONE:int = 0;
      
      public static const SEED:int = 1;
      
      public static const TREE:int = 2;
      
      public static const BUILDING:int = 3;
      
      public static const ANIMAL:int = 4;
      
      public static const DECORATION:int = 5;
      
      public static const EXPAND_FARM:int = 6;
      
      public static const FUEL:int = 7;
      
      public static const FUELCAPACITY:int = 8;
      
      public static const HOLIDAY_PRESENT:int = 9;
      
      public static const TILE_SET:int = 10;
      
      public static const CONSUMABLE:int = 11;
      
      public static const COLLECTABLE:int = 12;
      
      public static const CRAFTED:int = 13;
      
      public static const LOOTABLE_CONSUMABLE:int = 14;
      
      public static const CONSUMABLE_PACKAGE:int = 15;
      
      public static const PAINT:int = 17;
      
      public static const TARGETED_CONSUMABLE:int = 20;
      
      public static const PET_RESCUE:int = 21;
      
      public static const VALENTINES_PRESENT:int = 23;
      
      public static const BEEHIVE_ITEM:int = 24;
      
      public static const BUILDING_PART:int = 25;
      
      public static const EQUIPMENT:int = 26;
      
      public static const VEHICLE_PART:int = 27;
      
      public static const ANIMAL_FEED_TROUGH:int = 31;
      
      public static const FEATURE_CREDIT:int = 32;
      
      public static const WATERING_CAN:int = 33;
      
      public static const MARKET_BUY:String = "marketbuy";
      
      public static const MARKET_GIFT:String = "marketgift";
      
      public static const MARKET_PRESENT:String = "marketpresent";
      
      public static const MARKET_SHOWN:String = "marketshown";
      
      public var item:String;
      
      public var eventType:int;
      
      public var m_extraData:Object = {};
      
      public function MarketEvent(type:String, call:int = 0, data:String = "", extraData:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.eventType = call;
         this.item = data;
         if(extraData)
         {
            this.m_extraData = extraData;
         }
         super(type,bubbles,cancelable);
      }
   }
}

