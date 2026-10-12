package Classes.USDPaidGifting
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Managers.FeatureOptionsManager;
   
   public class USDPaidGiftingManager
   {
      
      private var m_source:String;
      
      private var m_featureName:String;
      
      private var m_virtualItem:FarmItem;
      
      private var m_usdPrice:Number;
      
      private var m_maxRecipients:int;
      
      private var m_isFeatureEnabled:Boolean;
      
      public function USDPaidGiftingManager(featureName:String, source:String)
      {
         var featureConfig:XML;
         var variant:int = 0;
         var itemData:XMLList = null;
         super();
         this.m_featureName = featureName;
         this.m_source = source;
         featureConfig = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(featureConfig)
         {
            this.m_maxRecipients = featureConfig.@maxRecipients;
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PAID_GIFTING_ON_IDLE_V2);
            itemData = featureConfig.items.item.(@variant == variant) as XMLList;
            if(itemData)
            {
               this.m_virtualItem = Global.farmGameSettingsManager.getFarmItemByCode(itemData.@code);
               this.m_usdPrice = itemData.@usd;
               this.m_isFeatureEnabled = true;
            }
         }
      }
      
      public function getmaxRecipients() : int
      {
         return this.m_maxRecipients;
      }
      
      public function getVirtualItem() : FarmItem
      {
         return this.m_virtualItem;
      }
      
      public function getUSDPrice() : Number
      {
         return this.m_usdPrice;
      }
      
      public function getRandomGiftInfo() : USDPaidGiftInfo
      {
         var giftItem:FarmItem = null;
         var result:USDPaidGiftInfo = null;
         var itemKey:String = this.getRandomItemKey();
         if(itemKey)
         {
            giftItem = this.getFarmItemForItemKey(itemKey);
            if(giftItem)
            {
               result = new USDPaidGiftInfo(this.m_source,this.m_featureName,itemKey,giftItem,null,this.getVirtualItem(),0);
            }
         }
         return result;
      }
      
      private function getRandomItemKey() : String
      {
         var optionsArray:Array = null;
         var itemKey:String = null;
         var result:String = null;
         var currentOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,USDPaidGiftingConstants.KEY_CURRENT_OPTIONS);
         if(currentOptions)
         {
            optionsArray = [];
            for(itemKey in currentOptions)
            {
               optionsArray.push(itemKey);
            }
            if(optionsArray.length > 0)
            {
               result = optionsArray[Math.floor(optionsArray.length * Math.random())];
            }
         }
         return result;
      }
      
      public function getFarmItemForItemKey(itemKey:String) : FarmItem
      {
         var result:FarmItem = null;
         var currentOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,USDPaidGiftingConstants.KEY_CURRENT_OPTIONS);
         if(Boolean(currentOptions) && currentOptions.hasOwnProperty(itemKey))
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(currentOptions[itemKey]);
         }
         return result;
      }
      
      public function isFeatureEnabled() : Boolean
      {
         return this.m_isFeatureEnabled;
      }
   }
}

