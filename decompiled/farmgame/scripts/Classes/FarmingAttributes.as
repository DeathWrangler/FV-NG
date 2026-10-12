package Classes
{
   import Widgets.Constants.Market.Currency;
   
   public class FarmingAttributes
   {
      
      private static const ATTR_PLOW_COST:String = "@plowCost";
      
      private static const ATTR_PLOW_CURRENCY:String = "@plowCurrency";
      
      private var m_plowCost:int;
      
      private var m_plowCurrency:String;
      
      public function FarmingAttributes()
      {
         super();
         this.m_plowCost = Global.farmGameSettingsManager.getInt("plowCost");
         this.m_plowCurrency = Currency.GOLD;
      }
      
      public function initWithXml(xml:XML) : void
      {
         if(xml.hasOwnProperty(ATTR_PLOW_COST))
         {
            this.m_plowCost = parseInt(xml[ATTR_PLOW_COST]);
         }
         if(xml.hasOwnProperty(ATTR_PLOW_CURRENCY))
         {
            this.m_plowCurrency = String(xml[ATTR_PLOW_CURRENCY]);
         }
      }
      
      public function get plowCost() : int
      {
         return this.m_plowCost;
      }
      
      public function get plowCurrency() : String
      {
         return this.m_plowCurrency;
      }
   }
}

