package Classes.Minigames
{
   import Classes.util.ParseXMLUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   
   public class RedeemablesFeatureData extends BaseFeatureData
   {
      
      private static const PRIZE_IDENTIFIER:String = "Level";
      
      private static const TAG_TOKEN_REWARDS:String = "rewards";
      
      private static const TAG_TOKEN_REWARD:String = "reward";
      
      private static const TAG_TICKET_PREFIX:String = "ticketPrefix";
      
      private static const ATTRIB_LEVEL:String = "@level";
      
      private static const ATTRIB_PRICE:String = "@price";
      
      private static const ATTRIB_IMAGE_URL:String = "@imageUrl";
      
      private static const ATTRIB_SPOTLIGHT:String = "@spotlight";
      
      private var m_ticketPrefix:String = null;
      
      private var m_uiData:Array = null;
      
      public function RedeemablesFeatureData(xml:XML, parent:MinigameData)
      {
         super(xml,parent);
      }
      
      public function get ticketPrefix() : String
      {
         return this.m_ticketPrefix;
      }
      
      public function getUIData() : Array
      {
         return this.m_uiData;
      }
      
      override protected function parseXML() : void
      {
         var zlocPrefix:String = null;
         var rewards:XMLList = null;
         var rewardsLength:int = 0;
         var i:int = 0;
         super.parseXML();
         this.m_uiData = new Array();
         if(m_rawXml)
         {
            this.m_ticketPrefix = ParseXMLUtil.parseRequiredString(m_rawXml,TAG_TICKET_PREFIX);
            zlocPrefix = m_parentMinigameData.zlocPrefix;
            if(zlocPrefix)
            {
               if(m_rawXml.hasOwnProperty(TAG_TOKEN_REWARDS) && m_rawXml[TAG_TOKEN_REWARDS].hasOwnProperty(TAG_TOKEN_REWARD))
               {
                  rewards = m_rawXml[TAG_TOKEN_REWARDS][TAG_TOKEN_REWARD];
                  rewardsLength = rewards.length();
                  for(i = 0; i < rewardsLength; i++)
                  {
                     if(rewards[i].hasOwnProperty(ATTRIB_LEVEL) && rewards[i].hasOwnProperty(ATTRIB_PRICE) && rewards[i].hasOwnProperty(ATTRIB_IMAGE_URL))
                     {
                        this.m_uiData.push({
                           "title":ZLocUtils.t("Dialogs",zlocPrefix + "_" + PRIZE_IDENTIFIER + rewards[i].@level + "_ItemName"),
                           "icon":ParseXMLUtil.parseRequiredString(rewards[i],ATTRIB_IMAGE_URL),
                           "price":ParseXMLUtil.parseRequiredUInt(rewards[i],ATTRIB_PRICE),
                           "level":ParseXMLUtil.parseRequiredUInt(rewards[i],ATTRIB_LEVEL),
                           "spotlight":ParseXMLUtil.parseOptionalBoolean(rewards[i],ATTRIB_SPOTLIGHT,false)
                        });
                     }
                     else
                     {
                        ErrorManager.addError("RedeemablesFeatureData.as: <reward> index " + i + " missing level= price= or imageUrl= in xml?");
                     }
                  }
               }
               else
               {
                  ErrorManager.addError("RedeemablesFeatureData.as: error no <rewards> in xml?");
               }
            }
            else
            {
               ErrorManager.addError("RedeemablesFeatureData.as: error: no <zlocPrefix> xml?");
            }
         }
         else
         {
            ErrorManager.addError("RedeemablesFeatureData.as: error: no <feature name=\"redeemables\"> xml?");
         }
      }
      
      public function getRedeemButtonText() : String
      {
         return getFailOverText("_BuyText");
      }
      
      public function getRedeemTicketTitleText() : String
      {
         return getFailOverText("_TicketTitle");
      }
      
      public function getRedeemPriceText(price:int) : String
      {
         return getFailOverText("_Price",{"quantity":price});
      }
      
      public function getRedeemPrizeInGiftboxText() : String
      {
         return getFailOverText("_PrizeText");
      }
      
      public function getRedeemPrizeConfirmationText() : String
      {
         return getFailOverText("_PrizeConfirmation");
      }
      
      public function getRedeemTicketsNameText() : String
      {
         return getFailOverText("_TicketsName");
      }
      
      public function getRedeemingText() : String
      {
         return getFailOverText("_Redeeming");
      }
      
      public function getRedeemTicketChangeText(delta:int) : String
      {
         var locToken:String = "_TicketChangeAdd";
         if(delta < 0)
         {
            locToken = "_TicketChangeSub";
         }
         return getFailOverText(locToken,{
            "delta":delta,
            "unit_name":this.getRedeemTicketsNameText()
         });
      }
      
      public function getRewardSpotlight(spotlightIndex:uint) : Object
      {
         var result:Object = null;
         var rewardsLen:uint = this.m_uiData.length;
         for(var curIndex:uint = 0; curIndex < rewardsLen; curIndex++)
         {
            if(this.m_uiData[curIndex]["spotlight"] == true)
            {
               if(spotlightIndex == 0)
               {
                  result = this.m_uiData[curIndex];
                  break;
               }
               spotlightIndex--;
            }
         }
         return result;
      }
   }
}

