package Classes
{
   public class ZapCampaignSettings
   {
      
      private var m_xml:XML;
      
      private var m_campaignNameHash:Object = null;
      
      public function ZapCampaignSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
         this.init();
      }
      
      private function init() : void
      {
         var campaignXml:XML = null;
         var campaignName:String = null;
         this.m_campaignNameHash = {};
         for each(campaignXml in this.m_xml.descendants("zapCampaign"))
         {
            campaignName = campaignXml.@name.toString();
            this.m_campaignNameHash[campaignName] = campaignXml;
         }
      }
      
      public function getBrandUrl(campaignName:String) : String
      {
         var url:String = null;
         if(this.m_campaignNameHash.hasOwnProperty(campaignName))
         {
            url = this.m_campaignNameHash[campaignName].brandUrl;
         }
         if(url == "")
         {
            url = null;
         }
         return url;
      }
      
      public function getPromoStartDate(campaignName:String) : String
      {
         var startDate:String = null;
         if(this.m_campaignNameHash.hasOwnProperty(campaignName))
         {
            startDate = this.m_campaignNameHash[campaignName].campaignStart;
         }
         if(startDate == "")
         {
            startDate = null;
         }
         return startDate;
      }
      
      public function getPromoEndDate(campaignName:String) : String
      {
         var endDate:String = null;
         if(this.m_campaignNameHash.hasOwnProperty(campaignName))
         {
            endDate = this.m_campaignNameHash[campaignName].campaignEnd;
         }
         if(endDate == "")
         {
            endDate = null;
         }
         return endDate;
      }
      
      public function getPromoSwf(campaignName:String) : String
      {
         var swf:String = null;
         if(this.m_campaignNameHash.hasOwnProperty(campaignName))
         {
            swf = this.m_campaignNameHash[campaignName]["swf"];
         }
         if(swf == "")
         {
            swf = null;
         }
         return swf;
      }
      
      public function getBrandPromoEndCoinGrant(campaignName:String, itemName:String) : int
      {
         var items:XMLList = null;
         var i:int = 0;
         var brandPromoEndCoinGrand:String = null;
         if(this.m_campaignNameHash.hasOwnProperty(campaignName))
         {
            items = XML(this.m_campaignNameHash[campaignName]).child("item");
            i = 0;
            for(i = 0; i < items.length(); i++)
            {
               if(items[i].@name == itemName)
               {
                  brandPromoEndCoinGrand = XML(items[i]).child("brandPromoEndCoinGrant").toString();
                  break;
               }
            }
         }
         return parseInt(brandPromoEndCoinGrand);
      }
   }
}

