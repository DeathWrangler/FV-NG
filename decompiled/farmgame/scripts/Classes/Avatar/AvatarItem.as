package Classes.Avatar
{
   import Classes.util.ZLocUtils;
   
   public class AvatarItem
   {
      
      private var m_xml:XML;
      
      private var m_name:String = "";
      
      private var m_friendlyName:String = "";
      
      protected var m_friendlyTitle:String = "";
      
      private var m_itemId:String = "";
      
      private var m_category:String;
      
      private var m_categoryId:Number;
      
      private var m_marketType:String = "";
      
      private var m_subtype:String = null;
      
      private var m_marketCost:Number = 0;
      
      private var m_allowedGenders:Array = [];
      
      private var m_assetFileName:String = "";
      
      private var m_assetMetaData:String = "";
      
      private var m_iconFileName:String = "";
      
      private var m_keywords:Object = {};
      
      private var m_buyable:Boolean = true;
      
      private var m_limitedStartDate:String = null;
      
      private var m_limitedEndDate:String = null;
      
      private var m_limitedIcon:String = null;
      
      private var m_featured:Boolean = false;
      
      public function AvatarItem()
      {
         super();
      }
      
      public static function fromXML(xml:XML, m_itemHash:Object) : AvatarItem
      {
         var keywordXML:XML = null;
         var asset:XML = null;
         var keyword:String = null;
         var item:AvatarItem = new AvatarItem();
         item.m_xml = xml;
         item.m_itemId = xml.@itemId;
         item.m_name = xml.@name;
         item.m_category = xml.@category;
         item.m_categoryId = m_itemHash[item.m_category];
         if(xml.attribute("buyable").toString())
         {
            if(xml.attribute("buyable").toString() == "false")
            {
               item.m_buyable = false;
            }
            else
            {
               item.m_buyable = true;
            }
         }
         for each(keywordXML in xml.descendants("keyword"))
         {
            keyword = keywordXML.toString();
            item.m_keywords[keyword] = keyword;
         }
         for each(asset in xml.descendants("asset"))
         {
            if(asset.@name)
            {
            }
            if(asset.@name == "avatar")
            {
               item.m_assetFileName = asset.@filename;
               item.m_assetMetaData = asset.@meta_data;
            }
            if(asset.@name == "icon")
            {
               item.m_iconFileName = asset.@filename;
            }
         }
         if(xml.hasOwnProperty("limitedStart"))
         {
            item.m_limitedStartDate = xml.limitedStart;
         }
         if(xml.hasOwnProperty("limitedEnd"))
         {
            item.m_limitedEndDate = xml.limitedEnd;
         }
         if(xml.hasOwnProperty("limitedIcon"))
         {
            item.m_limitedIcon = xml.limitedIcon;
         }
         item.m_marketType = xml.market.@type;
         if(item.m_marketType != "free")
         {
            item.m_marketCost = xml.market.@cost;
         }
         return item;
      }
      
      public function get itemId() : String
      {
         return this.m_itemId;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get isClothing() : Boolean
      {
         return Global.avatarConfigSettings.isClothingCategory(this.category);
      }
      
      public function get isRemovable() : Boolean
      {
         return Global.avatarConfigSettings.isCategoryRemovable(this.category);
      }
      
      public function get friendlyName() : String
      {
         if(this.m_friendlyName == "")
         {
            this.m_friendlyName = "Items:" + this.m_name + "_friendlyName";
         }
         return this.m_friendlyName;
      }
      
      public function get friendlyTitle() : String
      {
         if(this.m_friendlyTitle == "")
         {
            this.m_friendlyTitle = ZLocUtils.tk_pk_asTitle(this.friendlyName);
         }
         return this.m_friendlyTitle;
      }
      
      public function get market() : String
      {
         return this.m_marketType;
      }
      
      public function get cost() : Number
      {
         return this.m_marketCost;
      }
      
      public function get xp() : Number
      {
         var xp:Number = NaN;
         if(this.market == "cash")
         {
            xp = this.cost * Global.avatarConfigSettings.getXpPerCash();
         }
         else
         {
            xp = Math.floor(this.cost * Global.farmGameSettingsManager.getNumber("buyXpGainRatio"));
         }
         return Math.max(xp,Global.farmGameSettingsManager.getNumber("buyXpGainMin"));
      }
      
      public function get metaData() : String
      {
         return this.m_assetMetaData;
      }
      
      public function get assetName() : String
      {
         return this.m_assetFileName.indexOf(".swf") != -1 ? this.m_assetFileName.substring(0,this.m_assetFileName.indexOf(".swf")) : this.m_assetFileName;
      }
      
      public function get assetFilename() : String
      {
         return this.m_assetFileName;
      }
      
      public function get iconPath() : String
      {
         return Global.getAssetURL("assets/mylife/item_images/" + this.m_iconFileName);
      }
      
      public function get iconFile() : String
      {
         return this.m_iconFileName;
      }
      
      public function hasKeyword(keyword:String) : Boolean
      {
         return this.m_keywords.hasOwnProperty(keyword) && this.m_keywords[keyword] == keyword;
      }
      
      public function matchedKeywords(keywords:Array) : Array
      {
         var keyword:String = null;
         var matched:Array = new Array();
         for each(keyword in keywords)
         {
            if(this.hasKeyword(keyword))
            {
               matched.push(keyword);
            }
         }
         return matched;
      }
      
      public function get subtype() : String
      {
         var subtypes:Array = null;
         var keyword:String = null;
         if(!this.m_subtype)
         {
            this.m_subtype = "none";
            subtypes = Global.avatarConfigSettings.getDisplaySubtypes();
            for each(keyword in this.m_keywords)
            {
               switch(keyword)
               {
                  case "shirt":
                  case "bottom":
                  case "outfit":
                  case "shoe":
                  case "accessory":
                  case "costume":
                     this.m_subtype = keyword;
               }
            }
         }
         return this.m_subtype;
      }
      
      public function get keywords() : Array
      {
         var key:String = null;
         var result:Array = [];
         for(key in this.m_keywords)
         {
            result.push(key);
         }
         return result;
      }
      
      public function get category() : String
      {
         return this.m_category;
      }
      
      public function get categoryId() : Number
      {
         return this.m_categoryId;
      }
      
      public function get isFree() : Boolean
      {
         return this.market == AvatarConfigSettings.MARKET_FREE;
      }
      
      public function toRawObject() : Object
      {
         var gender:Number = this.hasKeyword("female") ? AvatarConfigSettings.GENDER_CODE_FEMALE : AvatarConfigSettings.GENDER_CODE_MALE;
         return {
            "itemId":this.itemId,
            "metaData":this.metaData,
            "g":gender,
            "category":this.category,
            "categoryId":this.categoryId,
            "filename":this.assetName
         };
      }
      
      public function isClothesItem() : Boolean
      {
         return this.subtype == "shirt" || this.subtype == "bottom" || this.subtype == "outfit" || this.subtype == "shoe" || this.subtype == "accessory" || this.subtype == "costume";
      }
      
      public function get buyable() : Boolean
      {
         return this.m_buyable;
      }
      
      public function get isLimited() : Boolean
      {
         return Boolean(this.m_limitedStartDate) && Boolean(this.m_limitedEndDate);
      }
      
      public function get limitedIcon() : String
      {
         return this.m_limitedIcon;
      }
      
      public function get limitedStartDate() : String
      {
         return this.m_limitedStartDate;
      }
      
      public function get limitedEndDate() : String
      {
         return this.m_limitedEndDate;
      }
      
      public function get limitedIconXML() : XML
      {
         return this.m_xml.limitedIcon[0];
      }
      
      public function get limitedStartDateXML() : XML
      {
         return this.m_xml.limitedStart[0];
      }
      
      public function get limitedEndDateXML() : XML
      {
         return this.m_xml.limitedEnd[0];
      }
      
      public function set featured(value:Boolean) : void
      {
         this.m_featured = value;
      }
      
      public function get featured() : Boolean
      {
         return this.m_featured;
      }
      
      public function toItemXML() : XML
      {
         var itemXML:XML = <item/>;
         var imageXML:XML = <image/>;
         var costXML:XML = <cost/>;
         var cashXML:XML = <cash/>;
         var xpXML:XML = <plantXp/>;
         imageXML.@name = "icon";
         imageXML.@url = "assets/mylife/item_images/" + this.m_iconFileName;
         itemXML.@name = this.name;
         itemXML.@type = "clothes";
         itemXML.@subtype = this.subtype;
         itemXML.@subsubtype = this.category;
         itemXML.@code = this.itemId;
         itemXML.@buyable = this.buyable;
         itemXML.@whatIsThis = "true";
         itemXML.@isClothingItem = "true";
         itemXML.appendChild(imageXML);
         if(this.market == "cash")
         {
            cashXML.appendChild(this.cost);
            costXML.appendChild(this.xp * 100);
            itemXML.@market = "cash";
            itemXML.appendChild(cashXML);
         }
         else
         {
            costXML.appendChild(this.cost);
         }
         xpXML.appendChild(this.xp);
         itemXML.appendChild(costXML);
         itemXML.appendChild(xpXML);
         if(this.isLimited)
         {
            itemXML.appendChild(this.limitedIconXML);
            itemXML.appendChild(this.limitedStartDateXML);
            itemXML.appendChild(this.limitedEndDateXML);
         }
         if(this.m_xml.hasOwnProperty("marketCardDescriptor"))
         {
            itemXML.appendChild(this.m_xml.marketCardDescriptor);
         }
         return itemXML;
      }
   }
}

