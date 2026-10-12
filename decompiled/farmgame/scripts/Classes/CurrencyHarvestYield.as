package Classes
{
   import Classes.ZItem.CurrencyData;
   import DataSources.BaseDataSource;
   import Widgets.Constants.Market.Currency;
   
   public class CurrencyHarvestYield extends HarvestYield
   {
      
      public function CurrencyHarvestYield(harvestYield:XML, harvestYieldDS:BaseDataSource = null)
      {
         var currencyData:CurrencyData = null;
         var experimentVariant:Number = NaN;
         super(harvestYield,harvestYieldDS);
         if(m_yield)
         {
            currencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_type);
            experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
            this.m_displayYield = Math.floor(m_yield * currencyData.getInflowTuningMultiplierByVariant(currencyData.getDisplayVariant()));
            this.m_yield *= currencyData.getInflowTuningMultiplierByVariant(experimentVariant);
         }
      }
      
      override public function get yield() : Number
      {
         var result:Number = m_yield;
         var currencyData:CurrencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_type);
         if(Boolean(currencyData) && Boolean(!currencyData.isValidFlow(this.m_yield)) || Global.worldManager.isVisiting() && this.m_type != Currency.COINS)
         {
            result = 0;
         }
         return result;
      }
      
      override public function applyReward(quantity:int = 1, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
         var currencyData:CurrencyData = null;
         var amount:int = 0;
         if(!Global.worldManager.isVisiting() || this.m_type == Currency.COINS)
         {
            currencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_type);
            if(Boolean(currencyData) && Boolean(currencyData.isValidFlow(this.m_yield)) || this.m_type == Currency.COINS)
            {
               amount = Math.ceil(this.m_yield * quantity * multiplier);
               Global.player.updateWorldCurrency(this.m_type,amount,true);
            }
         }
      }
   }
}

