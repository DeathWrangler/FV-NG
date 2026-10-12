package Classes.ZItem
{
   import Classes.util.FarmGameUtil;
   
   public class BrandPromoData
   {
      
      protected static const INVALID_VALUE:int = 3735929069;
      
      protected var m_itemName:String = null;
      
      protected var m_brandPromoName:String = null;
      
      protected var m_brandPromoStartDate:String = null;
      
      protected var m_brandPromoEndDate:String = null;
      
      protected var m_promoSwf:String = null;
      
      protected var m_brandPromoEndCoinGrant:int = -559038227;
      
      protected var m_brandUrl:String = null;
      
      public function BrandPromoData(promoName:String, itemName:String)
      {
         super();
         this.m_itemName = itemName;
         this.m_brandPromoName = promoName;
      }
      
      public function get brandPromoName() : String
      {
         return this.m_brandPromoName;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get brandUrl() : String
      {
         if(this.m_brandUrl == null)
         {
            this.m_brandUrl = Global.zapCampaignSettings.getBrandUrl(this.brandPromoName);
         }
         return this.m_brandUrl;
      }
      
      public function get brandPromoStartDate() : String
      {
         if(this.m_brandPromoStartDate == null)
         {
            this.m_brandPromoStartDate = Global.zapCampaignSettings.getPromoStartDate(this.brandPromoName);
            if(this.m_brandPromoStartDate == "")
            {
               this.m_brandPromoStartDate = null;
            }
         }
         return this.m_brandPromoStartDate;
      }
      
      public function get brandPromoEndDate() : String
      {
         if(this.m_brandPromoEndDate == null)
         {
            this.m_brandPromoEndDate = Global.zapCampaignSettings.getPromoEndDate(this.brandPromoName);
            if(this.m_brandPromoEndDate == "")
            {
               this.m_brandPromoEndDate = null;
            }
         }
         return this.m_brandPromoEndDate;
      }
      
      public function get swf() : String
      {
         if(this.m_promoSwf == null)
         {
            this.m_promoSwf = Global.zapCampaignSettings.getPromoSwf(this.brandPromoName);
         }
         return this.m_promoSwf;
      }
      
      public function get brandPromoEndCoinGrant() : Number
      {
         if(this.m_brandPromoEndCoinGrant == INVALID_VALUE)
         {
            this.m_brandPromoEndCoinGrant = Global.zapCampaignSettings.getBrandPromoEndCoinGrant(this.brandPromoName,this.itemName);
         }
         return this.m_brandPromoEndCoinGrant;
      }
      
      public function get isBrandPromoExpired() : Boolean
      {
         var returnVal:Boolean = true;
         var endTime:Number = FarmGameUtil.synchronizedDateToNumber(this.brandPromoEndDate);
         return endTime < GlobalEngine.serverTime;
      }
   }
}

