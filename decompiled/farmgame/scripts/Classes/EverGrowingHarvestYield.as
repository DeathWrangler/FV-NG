package Classes
{
   import Classes.ZItem.CurrencyData;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Widgets.Constants.Market.Currency;
   
   public class EverGrowingHarvestYield extends HarvestYield
   {
      
      public function EverGrowingHarvestYield(harvestYield:XML, harvestYieldDS:BaseDataSource = null)
      {
         var currencyData:CurrencyData = null;
         var experimentVariant:Number = NaN;
         super(harvestYield,harvestYieldDS);
         if(m_yield)
         {
            currencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_type);
            if(currencyData)
            {
               experimentVariant = Global.experimentManager.getExperimentVariant(currencyData.getInflowTuningExperimentName());
               this.m_displayYield = Math.floor(m_yield * currencyData.getInflowTuningMultiplierByVariant(currencyData.getDisplayVariant()));
               this.m_yield *= currencyData.getInflowTuningMultiplierByVariant(experimentVariant);
            }
         }
      }
      
      override public function applyReward(quantity:int = 1, multiplier:Number = 1, payload:SimpleHarvestableResource = null) : void
      {
         var evergrowingBuilding:EverGrowingHarvestableBuilding = null;
         var amount:int = 0;
         var currencyData:CurrencyData = null;
         var coinAmount:int = 0;
         var currencyAmount:int = 0;
         var idx:int = 0;
         if(payload)
         {
            evergrowingBuilding = payload as EverGrowingHarvestableBuilding;
            if(this.m_types != null && this.m_yields != null)
            {
               for(idx = 0; idx < this.m_types.length; idx++)
               {
                  if(!Global.worldManager.isVisiting() || this.m_types[idx] == Currency.COINS)
                  {
                     currencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_types[idx]);
                     if(Boolean(currencyData) && Boolean(currencyData.isValidFlow(this.m_yields[idx])) || this.m_types[idx] == Currency.COINS)
                     {
                        amount = Math.ceil(this.m_yields[idx] * quantity * multiplier * evergrowingBuilding.getCurrencyMultiplier(this.m_types[idx]));
                        if(this.m_types[idx] == Currency.COINS)
                        {
                           coinAmount = amount;
                        }
                        else
                        {
                           currencyAmount = amount;
                        }
                        Global.player.updateWorldCurrency(this.m_types[idx],amount,true);
                     }
                  }
               }
               Global.player.avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestCoinsJade",{
                  "coinNum":coinAmount,
                  "jadeNum":currencyAmount
               }));
            }
            else if(this.m_type != null)
            {
               if(!Global.worldManager.isVisiting() || this.m_type == Currency.COINS)
               {
                  currencyData = Global.farmGameSettingsManager.getCurrencyData(this.m_type);
                  if(Boolean(currencyData) && Boolean(currencyData.isValidFlow(this.m_yield)) || this.m_type == Currency.COINS)
                  {
                     amount = Math.ceil(this.m_yield * quantity * multiplier * evergrowingBuilding.getCurrencyMultiplier(this.m_type));
                     Global.player.updateWorldCurrency(this.m_type,amount,true);
                  }
                  Global.player.avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestCoins",{"coinNum":amount}));
               }
            }
         }
      }
   }
}

