package Classes.Avatar
{
   import Classes.FarmvilleClothingLoader;
   
   public class AvatarConfigSettings
   {
      
      public static const GENDER_MALE:String = "male";
      
      public static const GENDER_FEMALE:String = "female";
      
      public static const GENDER_CODE_FEMALE:int = 1;
      
      public static const GENDER_CODE_MALE:int = 2;
      
      public static const GENDER_CODES:Array = [GENDER_FEMALE,GENDER_MALE];
      
      public static const MARKET_FREE:String = "free";
      
      private static const AUTO_SELECT_ITEM_TO_FEATURE:Boolean = false;
      
      private var m_xml:XML;
      
      private var m_itemHash:Object = null;
      
      private var m_itemNameHash:Object = null;
      
      private var m_itemList:Array = [];
      
      private var m_surfacableItemList:Object = [];
      
      private var m_categoryHash:Object = {};
      
      private var m_clothingCategoryHash:Object = {};
      
      private var m_genderDefaults:Object;
      
      private var m_clothingLoader:FarmvilleClothingLoader;
      
      private var m_displaySubtypes:Array = [];
      
      private var m_clothingLevelGate:Number = 0;
      
      private var m_xpPerCash:Number = 35;
      
      private var m_featuredAvatarItemByGender:Object;
      
      private var m_newItems:Array;
      
      private var m_removableCategories:Array = [];
      
      public function AvatarConfigSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
         this.init();
         this.m_clothingLoader = new FarmvilleClothingLoader();
      }
      
      public function getLoader() : FarmvilleClothingLoader
      {
         return this.m_clothingLoader;
      }
      
      private function init() : void
      {
         var category:XML = null;
         var genderCode:String = null;
         var appearanceItem:XML = null;
         var defaultAppearance:XML = null;
         var keywordXML:XML = null;
         var categoryId:Number = NaN;
         var categoryName:String = null;
         var itemId:String = null;
         var item:AvatarItem = null;
         var itemName:String = null;
         var index:int = 0;
         var gender:String = null;
         var genderObj:Object = null;
         var defaultItem:XML = null;
         var key:String = null;
         var defaultItemId:String = null;
         var keyword:String = null;
         if(this.m_xml.featureConfig.clothingLevelGate.toString())
         {
            this.m_clothingLevelGate = this.m_xml.featureConfig.clothingLevelGate;
         }
         if(this.m_xml.featureConfig.xpToCash.toString())
         {
            this.m_xpPerCash = this.m_xml.featureConfig.xpToCash;
         }
         for each(category in this.m_xml.descendants("appearanceCategory"))
         {
            categoryId = Number(category.@categoryId);
            categoryName = category.@name.toString();
            if(this.m_categoryHash.hasOwnProperty(categoryName))
            {
            }
            this.m_categoryHash[categoryName] = categoryId;
            if(category.@clothing.toString())
            {
               this.m_clothingCategoryHash[categoryName] = categoryId;
            }
            if(category.@removable.toString() == "true")
            {
               this.m_removableCategories.push(categoryName);
            }
         }
         this.m_itemHash = {};
         this.m_itemNameHash = {};
         for each(genderCode in GENDER_CODES)
         {
            this.m_surfacableItemList.push([]);
         }
         for each(appearanceItem in this.m_xml.descendants("appearanceItem"))
         {
            itemId = appearanceItem.@itemId;
            if(this.m_itemHash.hasOwnProperty(itemId))
            {
            }
            if(this.isValidItem(appearanceItem))
            {
               item = AvatarItem.fromXML(appearanceItem,this.m_categoryHash);
               this.m_itemHash[itemId] = item;
               itemName = item.name;
               this.m_itemNameHash[itemName] = item;
               this.m_itemList.push(item);
               if(item.buyable == true && this.isValidFeaturedItem(itemId) && item.market == "cash")
               {
                  for(index = 0; index < GENDER_CODES.length; index++)
                  {
                     if(item.hasKeyword(GENDER_CODES[index]))
                     {
                        this.m_surfacableItemList[index].push(item);
                     }
                  }
               }
            }
         }
         this.m_genderDefaults = {};
         for each(defaultAppearance in this.m_xml.descendants("defaultAppearance"))
         {
            gender = defaultAppearance.@gender;
            genderObj = {};
            for each(defaultItem in defaultAppearance.descendants("defaultItem"))
            {
               key = defaultItem.@category;
               defaultItemId = defaultItem.@itemId;
               if(!this.m_itemHash.hasOwnProperty(defaultItemId))
               {
                  throw new Error("AvatarConfigSettings fatal error: default item id:" + itemId + " for category:" + key + " gender:" + gender + " was not found");
               }
               genderObj[key] = this.m_itemHash[defaultItemId];
            }
            this.m_genderDefaults[gender] = genderObj;
         }
         for each(keywordXML in this.m_xml.subtypeKeywords.descendants("keyword"))
         {
            keyword = keywordXML.toString();
            this.m_displaySubtypes.push(keyword);
         }
         this.parseFeaturedItems();
         this.parseNewItems();
      }
      
      private function parseFeaturedItems() : void
      {
         var gender:String = null;
         var avItem:AvatarItem = null;
         var appearanceItemRef:XML = null;
         var itemId:String = null;
         var matchedGenders:Array = null;
         var i:int = 0;
         this.m_featuredAvatarItemByGender = {};
         var genders:Array = [];
         for(gender in this.m_genderDefaults)
         {
            genders.push(gender);
         }
         if(this.m_xml.featuredItems)
         {
            for each(appearanceItemRef in this.m_xml.featuredItems.descendants("appearanceItemRef"))
            {
               itemId = appearanceItemRef.@itemId;
               if(this.isValidFeaturedItem(itemId))
               {
                  avItem = this.getItemById(itemId);
                  matchedGenders = avItem.matchedKeywords(genders);
                  for each(gender in matchedGenders)
                  {
                     if(!this.m_featuredAvatarItemByGender[gender])
                     {
                        this.m_featuredAvatarItemByGender[gender] = avItem;
                        avItem.featured = true;
                        for(i = 0; i < genders.length; i++)
                        {
                           if(genders[i] == gender)
                           {
                              genders.splice(i,1);
                           }
                        }
                     }
                  }
               }
               if(genders.length == 0)
               {
                  break;
               }
            }
            if(genders.length > 0 && AUTO_SELECT_ITEM_TO_FEATURE)
            {
               for each(avItem in this.m_itemList)
               {
                  if(avItem.buyable && this.isValidFeaturedItem(avItem.itemId))
                  {
                     for each(gender in avItem.matchedKeywords(genders))
                     {
                        if(!this.m_featuredAvatarItemByGender[gender])
                        {
                           this.m_featuredAvatarItemByGender[gender] = avItem;
                           avItem.featured = true;
                           for(i = 0; i < genders.length; i++)
                           {
                              if(genders[i] == gender)
                              {
                                 genders.splice(i,1);
                              }
                           }
                        }
                     }
                  }
                  if(genders.length == 0)
                  {
                     break;
                  }
               }
            }
         }
      }
      
      private function parseNewItems() : void
      {
         var avItem:AvatarItem = null;
         var appearanceItemRef:XML = null;
         var itemId:String = null;
         this.m_newItems = new Array();
         if(this.m_xml.newItems)
         {
            for each(appearanceItemRef in this.m_xml.newItems.descendants("appearanceItemRef"))
            {
               itemId = appearanceItemRef.@itemId;
               if(!itemId)
               {
                  itemId = appearanceItemRef.itemId;
               }
               avItem = this.getItemById(itemId);
               if(!avItem)
               {
                  itemId = appearanceItemRef.itemId;
                  avItem = this.getItemById(itemId);
               }
               avItem.featured = true;
               this.m_newItems.push(avItem);
            }
         }
      }
      
      private function isValidItem(appearanceItem:Object) : Boolean
      {
         return true;
      }
      
      private function isValidFeaturedItem(itemId:String) : Boolean
      {
         var startDate:String = null;
         var endDate:String = null;
         var referencedItem:AvatarItem = this.m_itemHash[itemId];
         if(referencedItem)
         {
            if(referencedItem.isLimited)
            {
               startDate = referencedItem.limitedStartDate;
               endDate = referencedItem.limitedEndDate;
               return this.checkDateRange(startDate,endDate);
            }
            return true;
         }
         return false;
      }
      
      private function checkDateRange(startDate:String, endDate:String) : Boolean
      {
         var now:Date = new Date();
         var start:Date = startDate ? new Date(startDate) : now;
         var end:Date = endDate ? new Date(endDate) : new Date(now.time + 1);
         return start.time <= now.time && now.time < end.time;
      }
      
      public function get clothingLevelGate() : Number
      {
         return this.m_clothingLevelGate;
      }
      
      public function get itemList() : Array
      {
         return this.m_itemList;
      }
      
      public function randomSurfacableItem(gender:int) : AvatarItem
      {
         var genderCode:int = gender - 1;
         var returnValue:AvatarItem = this.m_itemNameHash[Global.player.avatarSurfacingItem];
         if(returnValue == null && this.m_surfacableItemList[genderCode] != null && this.m_surfacableItemList[genderCode].length > 0)
         {
            returnValue = this.m_surfacableItemList[genderCode][Math.floor(Math.random() * this.m_surfacableItemList[genderCode].length)];
         }
         return returnValue;
      }
      
      public function getItemById(id:String) : AvatarItem
      {
         var result:AvatarItem = null;
         if(this.m_itemHash.hasOwnProperty(id))
         {
            result = this.m_itemHash[id];
         }
         return result;
      }
      
      public function getItemByName(name:String) : AvatarItem
      {
         var result:AvatarItem = null;
         if(this.m_itemNameHash.hasOwnProperty(name))
         {
            result = this.m_itemNameHash[name];
         }
         return result;
      }
      
      public function getItemsByCategory(category:String) : Array
      {
         var avatarItem:AvatarItem = null;
         var result:Array = [];
         for(var i:int = 0; i < this.m_itemList.length; i++)
         {
            avatarItem = this.m_itemList[i];
            if(avatarItem.category == category)
            {
               result.push(avatarItem);
            }
         }
         return result;
      }
      
      public function getItemsByKeywords(keywords:Array = null) : Array
      {
         var avatarItem:AvatarItem = null;
         var matches:Boolean = false;
         var j:int = 0;
         var result:Array = [];
         for(var i:int = 0; i < this.m_itemList.length; i++)
         {
            avatarItem = this.m_itemList[i];
            matches = true;
            if(keywords != null)
            {
               for(j = 0; j < keywords.length; j++)
               {
                  if(!avatarItem.hasKeyword(keywords[j]))
                  {
                     matches = false;
                  }
               }
            }
            if(matches)
            {
               result.push(avatarItem);
            }
         }
         return result;
      }
      
      public function getRawItemsByKeyword(keywords:Array = null) : Array
      {
         var avatarItem:AvatarItem = null;
         var result:Array = [];
         var avatarItems:Array = this.getItemsByKeywords(keywords);
         for(var i:int = 0; i < avatarItems.length; i++)
         {
            avatarItem = avatarItems[i];
            result.push(avatarItem.toRawObject());
         }
         return result;
      }
      
      public function getClothingItemCategories() : Object
      {
         return this.m_clothingCategoryHash;
      }
      
      public function getRawNonClothingItems() : Array
      {
         var avatarItem:AvatarItem = null;
         var category:String = null;
         var result:Array = [];
         var avatarItems:Array = this.getItemsByKeywords();
         for(var i:int = 0; i < avatarItems.length; i++)
         {
            avatarItem = avatarItems[i];
            category = avatarItem.category;
            if(!this.isClothingCategory(category))
            {
               result.push(avatarItem.toRawObject());
            }
         }
         return result;
      }
      
      public function isClothingCategory(category:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_clothingCategoryHash.hasOwnProperty(category) && Boolean(this.m_clothingCategoryHash[category]))
         {
            result = true;
         }
         return result;
      }
      
      public function isCategoryRemovable(category:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_removableCategories.indexOf(category) >= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getDisplaySubtypes() : Array
      {
         return this.m_displaySubtypes;
      }
      
      public function getDefaultAppearanceItems(gender:String) : Object
      {
         return this.m_genderDefaults[gender];
      }
      
      public function getDefaultClothingItems(gender:String) : Object
      {
         var avatarItem:AvatarItem = null;
         var avatarObj:Object = {};
         for each(avatarItem in this.getDefaultAppearanceItems(gender))
         {
            if(this.isClothingCategory(avatarItem.category))
            {
               avatarObj[avatarItem.category] = avatarItem;
            }
         }
         return avatarObj;
      }
      
      public function getDefaultRawCustomizationData(gender:String = "female", includeNonClothing:Boolean = true) : Object
      {
         var avatarItem:AvatarItem = null;
         var genderDefaults:Object = this.getDefaultAppearanceItems(gender);
         var avatarObj:Object = {};
         for each(avatarItem in genderDefaults)
         {
            if(includeNonClothing || avatarItem.isClothing)
            {
               avatarObj[avatarItem.category] = avatarItem.toRawObject();
            }
         }
         return avatarObj;
      }
      
      public function getCategories() : Array
      {
         var key:String = null;
         var categories:Array = [];
         for(key in this.m_categoryHash)
         {
            categories.push(key);
         }
         return categories;
      }
      
      public function isCategory(category:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_categoryHash.hasOwnProperty(category) && Boolean(this.m_categoryHash[category]))
         {
            result = true;
         }
         return result;
      }
      
      public function getXpPerCash() : Number
      {
         return this.m_xpPerCash;
      }
      
      public function getFeaturedAvatarItem(genderCode:int) : AvatarItem
      {
         var gender:String = AvatarConfigSettings.GENDER_CODES[genderCode - 1];
         return this.m_featuredAvatarItemByGender[gender];
      }
      
      public function getNewAvatarItems() : Array
      {
         return this.m_newItems;
      }
   }
}

