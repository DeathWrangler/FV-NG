package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   
   public class VIPSalesManager extends ManagedSalesManager
   {
      
      private const TAB_NAME:String = "VIP";
      
      public function VIPSalesManager()
      {
         super();
      }
      
      override public function isEnabled() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MONDAY_SINK) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(SubscriptionsManager.instance.isSubscriber())
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function getSaleSubTypes() : Array
      {
         var result:Array = null;
         result = super.getSaleSubTypes();
         if(result)
         {
            result.push(this.TAB_NAME);
         }
         return result;
      }
      
      public function getValidOnSaleItems() : Array
      {
         var key:String = null;
         var item:FarmItem = null;
         var result:Array = new Array();
         for(key in m_sales)
         {
            if(key != null)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(key);
               if(Boolean(item) && Boolean(item.meetsWorldRestrictions()) && item.isVisible)
               {
                  result.push(item);
               }
            }
         }
         return result;
      }
      
      public function getVIPDiscount() : Number
      {
         var subscriptionLevel:Number = NaN;
         var discount:Number = 0;
         if(SubscriptionsManager.instance.isSubscriber())
         {
            subscriptionLevel = SubscriptionsManager.instance.getSubscriptionLevel();
            switch(subscriptionLevel)
            {
               case SubscriptionsManager.LEVEL_DIAMOND:
               case SubscriptionsManager.LEVEL_RUBY:
                  discount = 40;
                  break;
               case SubscriptionsManager.LEVEL_GOLD:
               case SubscriptionsManager.LEVEL_SILVER:
                  discount = 30;
                  break;
               case SubscriptionsManager.LEVEL_BRONZE:
               default:
                  discount = 20;
            }
         }
         return discount;
      }
   }
}

