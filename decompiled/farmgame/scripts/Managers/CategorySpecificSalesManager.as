package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import flash.utils.Dictionary;
   
   public class CategorySpecificSalesManager
   {
      
      private var m_saleObject:Object;
      
      private var m_subTypeSet:Dictionary = new Dictionary();
      
      private const MIN_FC:uint = 4;
      
      private var m_motdItems:Array = new Array();
      
      public function CategorySpecificSalesManager()
      {
         super();
      }
      
      public function setCategorySpecificSale(sale:Object) : void
      {
         var itemsArr:Array = null;
         var i:uint = 0;
         var item:FarmItem = null;
         this.m_saleObject = sale;
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("motditems"))
         {
            itemsArr = (this.m_saleObject.motditems as String).split(",");
            for(i = 0; i < itemsArr.length; i++)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemsArr[i]);
               if(Boolean(item) && this.inSale(item))
               {
                  this.m_motdItems.push(item);
               }
            }
         }
      }
      
      public function get category() : String
      {
         var category:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("category"))
         {
            category = this.m_saleObject.category;
         }
         return category;
      }
      
      public function get subcategory() : String
      {
         var subcategory:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("subcategory"))
         {
            subcategory = this.m_saleObject.subcategory;
         }
         return subcategory;
      }
      
      public function get discount() : String
      {
         var discount:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("discount"))
         {
            discount = this.m_saleObject.discount;
         }
         return discount;
      }
      
      public function get maxFC() : int
      {
         var maxFC:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("maxfc"))
         {
            maxFC = this.m_saleObject.maxfc;
         }
         return parseInt(maxFC);
      }
      
      public function get motdTitle() : String
      {
         var motdTitle:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("motdtitle"))
         {
            motdTitle = this.m_saleObject.motdtitle;
         }
         return motdTitle;
      }
      
      public function get motdBody() : String
      {
         var motdBody:String = "";
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("motdbody"))
         {
            motdBody = this.m_saleObject.motdbody;
         }
         return motdBody;
      }
      
      public function inSale(item:FarmItem) : Boolean
      {
         var catMatch:Boolean = false;
         var marketEntriesTypeArray:Object = null;
         var typeArray:Array = null;
         var inSale:Boolean = false;
         if(item)
         {
            catMatch = false;
            marketEntriesTypeArray = item.market3EntriesTypeArray;
            for each(typeArray in marketEntriesTypeArray)
            {
               if(this.subcategory != "all")
               {
                  if(typeArray[0] == this.category && typeArray[1] == this.subcategory)
                  {
                     catMatch = true;
                  }
               }
               else if(typeArray[0] == this.category)
               {
                  catMatch = true;
               }
            }
            if(catMatch && item.isVisible && item.buyableWithCash() && item.cash < this.maxFC && item.cash > this.MIN_FC)
            {
               inSale = true;
            }
         }
         return inSale;
      }
      
      public function price(cash:int) : int
      {
         var price:int = cash;
         if(Boolean(this.m_saleObject) && this.m_saleObject.hasOwnProperty("discount"))
         {
            price = cash - cash * parseInt(this.m_saleObject.discount) / 100;
         }
         return price;
      }
      
      public function isActive() : Boolean
      {
         var isActive:Boolean = false;
         if(this.m_saleObject)
         {
            isActive = true;
         }
         return this.inExperiment() && isActive;
      }
      
      public function inExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CATEGORY_SPECIFIC_SALE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
      
      public function get timeLeft() : Number
      {
         var endTime:Number = NaN;
         var prereqs:Array = null;
         var now:Number = NaN;
         var prereq:Object = null;
         var type:String = null;
         var rv:Number = 0;
         if(this.isActive())
         {
            endTime = 0;
            prereqs = this.m_saleObject.prereqs;
            if(prereqs)
            {
               for each(prereq in prereqs)
               {
                  type = prereq.type as String;
                  if(Boolean(type) && type == PrerequisiteConstants.PREREQUISITE_END_TIME)
                  {
                     endTime = Number(prereq[PrerequisiteConstants.KEY_VALUE]);
                     break;
                  }
               }
            }
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            rv = endTime - now > 0 ? endTime - now : 0;
         }
         return rv;
      }
      
      public function getItemsInSale() : Array
      {
         var index:uint = 0;
         var item:FarmItem = null;
         var j:uint = 0;
         var saleItems:Array = Global.farmGameSettingsManager.getFarmItemsArray(this.category,this.subcategory);
         var remCount:uint = 3 - this.m_motdItems.length;
         for(var i:uint = 0; i < remCount; i++)
         {
            j = 0;
            do
            {
               index = Math.floor(Math.random() * saleItems.length);
               item = saleItems[index];
            }
            while(!this.inSale(item) && j++ < 10);
            this.m_motdItems.push(item);
         }
         return this.m_motdItems;
      }
      
      public function getSaleSubTypes() : Array
      {
         var subType:String = null;
         var result:Array = new Array();
         result.push("all");
         for(subType in this.m_subTypeSet)
         {
            result.push(subType);
         }
         return result;
      }
      
      public function setSaleSubType(item:FarmItem) : void
      {
         var marketEntriesTypeArray:Object = null;
         var subType:String = null;
         var typeArray:Array = null;
         if(Boolean(item) && item.isVisible)
         {
            marketEntriesTypeArray = item.market3EntriesTypeArray;
            subType = null;
            for each(typeArray in marketEntriesTypeArray)
            {
               subType = typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX];
               if(subType != "" && subType != "limited" && !this.m_subTypeSet.hasOwnProperty(subType))
               {
                  this.m_subTypeSet[subType] = 1;
               }
            }
         }
      }
   }
}

