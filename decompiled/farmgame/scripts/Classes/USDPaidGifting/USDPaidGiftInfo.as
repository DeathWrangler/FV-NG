package Classes.USDPaidGifting
{
   import Classes.ZItem.FarmItem;
   
   public class USDPaidGiftInfo
   {
      
      public static const REF_FIELD_SOURCE:String = "source";
      
      public static const REF_FIELD_FEATURE_NAME:String = "featureName";
      
      public static const REF_FIELD_ITEM_KEY:String = "itemKey";
      
      public static const REF_FIELD_GIFT_ITEM_CODE:String = "giftItemCode";
      
      public static const REF_FIELD_RECIPIENTS:String = "recipients";
      
      public static const REF_DELIM_FIELDS:String = ":";
      
      public static const REF_DELIM_RECIPIENTS:String = ",";
      
      private var m_source:String;
      
      private var m_featureName:String;
      
      private var m_itemKey:String;
      
      private var m_giftItemCode:String;
      
      private var m_giftItem:FarmItem;
      
      private var m_recipients:Array;
      
      private var m_virtualItemCode:String;
      
      private var m_virtualItem:FarmItem;
      
      private var m_reportedQuantity:int;
      
      public function USDPaidGiftInfo(source:String, featureName:String, itemKey:String, giftItem:FarmItem, recipients:Array, virtualItem:FarmItem, reportedQuantity:int)
      {
         super();
         this.m_source = source;
         this.m_featureName = featureName;
         this.m_itemKey = itemKey;
         this.m_giftItem = giftItem;
         this.m_giftItemCode = giftItem.code;
         this.m_recipients = recipients;
         this.m_virtualItem = virtualItem;
         this.m_virtualItemCode = virtualItem.code;
         this.m_reportedQuantity = reportedQuantity;
      }
      
      public static function buildRefString(source:String, featureName:String, itemKey:String, giftItemCode:String, recipients:Array) : String
      {
         return [USDPaidGiftingConstants.REF_KEY,source,featureName,itemKey,giftItemCode,recipients.join(REF_DELIM_RECIPIENTS)].join(REF_DELIM_FIELDS);
      }
      
      public static function createInstanceFromRefString(ref:String, virtualItemCode:String, reportedQuantity:int) : USDPaidGiftInfo
      {
         var giftItem:FarmItem = null;
         var virtualItem:FarmItem = null;
         var result:USDPaidGiftInfo = null;
         var tagFields:Object = parseRefString(ref);
         if(tagFields)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByCode(tagFields[REF_FIELD_GIFT_ITEM_CODE]);
            virtualItem = Global.farmGameSettingsManager.getFarmItemByCode(virtualItemCode);
            result = new USDPaidGiftInfo(tagFields[REF_FIELD_SOURCE],tagFields[REF_FIELD_FEATURE_NAME],tagFields[REF_FIELD_ITEM_KEY],giftItem,tagFields[REF_FIELD_RECIPIENTS],virtualItem,reportedQuantity);
         }
         return result;
      }
      
      public static function parseRefString(ref:String) : Object
      {
         var result:Object = null;
         var refFields:Array = ref.split(REF_DELIM_FIELDS);
         if(refFields.length == 6 && refFields[0] == USDPaidGiftingConstants.REF_KEY)
         {
            result = {};
            result[REF_FIELD_SOURCE] = refFields[1];
            result[REF_FIELD_FEATURE_NAME] = refFields[2];
            result[REF_FIELD_ITEM_KEY] = refFields[3];
            result[REF_FIELD_GIFT_ITEM_CODE] = refFields[4];
            result[REF_FIELD_RECIPIENTS] = refFields[5].split(REF_DELIM_RECIPIENTS);
         }
         return result;
      }
      
      public function toRefString() : String
      {
         return buildRefString(this.m_source,this.m_featureName,this.m_itemKey,this.m_giftItemCode,this.m_recipients);
      }
      
      public function getSource() : String
      {
         return this.m_source;
      }
      
      public function setSource(source:String) : void
      {
         this.m_source = source;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      public function setFeatureName(featureName:String) : void
      {
         this.m_featureName = featureName;
      }
      
      public function getItemKey() : String
      {
         return this.m_itemKey;
      }
      
      public function setItemKey(itemKey:String) : void
      {
         this.m_itemKey = itemKey;
      }
      
      public function getGiftItemCode() : String
      {
         return this.m_giftItemCode;
      }
      
      public function setGiftItemCode(itemCode:String) : void
      {
         this.m_giftItemCode = itemCode;
      }
      
      public function getGiftItem() : FarmItem
      {
         return this.m_giftItem;
      }
      
      public function getRecipients() : Array
      {
         return this.m_recipients;
      }
      
      public function setRecipients(recipients:Array) : void
      {
         this.m_recipients = recipients;
      }
      
      public function getVirtualItemCode() : String
      {
         return this.m_virtualItemCode;
      }
      
      public function setVirtualItemCode(itemCode:String) : void
      {
         this.m_virtualItemCode = itemCode;
      }
      
      public function getVirtualItem() : FarmItem
      {
         return this.m_virtualItem;
      }
      
      public function getReportedQuantity() : int
      {
         return this.m_reportedQuantity;
      }
      
      public function setReportedQuantity(reportedQuantity:int) : void
      {
         this.m_reportedQuantity = reportedQuantity;
      }
   }
}

