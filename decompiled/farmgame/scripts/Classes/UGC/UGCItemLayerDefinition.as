package Classes.UGC
{
   public class UGCItemLayerDefinition
   {
      
      private static const XML_KEY_NAME:String = "@name";
      
      private static const XML_KEY_TYPE:String = "@type";
      
      private static const XML_KEY_LAYERKEY:String = "@layerKey";
      
      private static const XML_KEY_COLORIZE:String = "@colorize";
      
      private static const XML_KEY_PRIORITY:String = "@priority";
      
      private static const XML_KEY_RANDOMIZE:String = "@randomizeChance";
      
      private static const XML_KEY_ITEMS:String = "items";
      
      private static const XML_KEY_IMAGES:String = "images";
      
      private static const DEFAULT_RANDOMIZE_CHANCE:Number = 0.5;
      
      private static const DEFAULT_IMAGE_NAME:String = "static";
      
      private var m_name:String;
      
      private var m_type:String;
      
      private var m_itemNames:Array;
      
      private var m_itemPriorityByItemNameHash:Object = null;
      
      private var m_colorable:Boolean;
      
      private var m_images:Array;
      
      private var m_layerKey:String;
      
      private var m_randomizeChance:Number;
      
      public function UGCItemLayerDefinition(layerXML:XML)
      {
         var imagesList:XMLList = null;
         var imageXML:XML = null;
         var itemsList:XMLList = null;
         var itemXML:XML = null;
         var tmpItemName:String = null;
         super();
         if(layerXML == null)
         {
            throw new Error("Cannot construct a UGCItemLayer from null XML.");
         }
         this.m_name = layerXML[XML_KEY_NAME].toString();
         if(layerXML.hasOwnProperty(XML_KEY_LAYERKEY))
         {
            this.m_layerKey = layerXML[XML_KEY_LAYERKEY].toString();
         }
         if(layerXML.hasOwnProperty(XML_KEY_TYPE))
         {
            this.m_type = layerXML[XML_KEY_TYPE].toString();
         }
         if(layerXML.hasOwnProperty(XML_KEY_RANDOMIZE))
         {
            this.m_randomizeChance = Number(layerXML[XML_KEY_RANDOMIZE]);
         }
         else
         {
            this.m_randomizeChance = DEFAULT_RANDOMIZE_CHANCE;
         }
         this.m_colorable = false;
         if(layerXML.hasOwnProperty(XML_KEY_COLORIZE))
         {
            this.m_colorable = layerXML[XML_KEY_COLORIZE].toString() == "true";
         }
         var layerPriority:int = 0;
         if(layerXML.hasOwnProperty(XML_KEY_PRIORITY))
         {
            layerPriority = parseInt(layerXML[XML_KEY_PRIORITY].toString());
         }
         this.m_images = new Array();
         if(layerXML.hasOwnProperty(XML_KEY_IMAGES))
         {
            imagesList = layerXML.images.image;
            for each(imageXML in imagesList)
            {
               this.m_images.push(new UGCItemLayerImageDefinition(this,imageXML[XML_KEY_NAME],imageXML[XML_KEY_PRIORITY]));
            }
         }
         else
         {
            this.m_images.push(new UGCItemLayerImageDefinition(this,DEFAULT_IMAGE_NAME,layerPriority));
         }
         this.m_itemNames = new Array();
         this.m_itemPriorityByItemNameHash = new Object();
         if(layerXML.hasOwnProperty(XML_KEY_ITEMS))
         {
            itemsList = layerXML.items.item;
            for each(itemXML in itemsList)
            {
               tmpItemName = itemXML[XML_KEY_NAME].toString();
               this.m_itemNames.push(tmpItemName);
               if(itemXML.hasOwnProperty(XML_KEY_PRIORITY))
               {
                  this.m_itemPriorityByItemNameHash[tmpItemName] = parseInt(itemXML[XML_KEY_PRIORITY].toString());
               }
               else
               {
                  this.m_itemPriorityByItemNameHash[tmpItemName] = layerPriority;
               }
            }
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get itemNames() : Array
      {
         return this.m_itemNames;
      }
      
      public function get itemPriorityByItemNameHash() : Object
      {
         return this.m_itemPriorityByItemNameHash;
      }
      
      public function get isColorable() : Boolean
      {
         return this.m_colorable;
      }
      
      public function get images() : Array
      {
         return this.m_images;
      }
      
      public function get layerKey() : String
      {
         return this.m_layerKey;
      }
      
      public function get randomizeChance() : Number
      {
         return this.m_randomizeChance;
      }
      
      public function get isItemCustomizable() : Boolean
      {
         return this.m_itemNames.length > 0;
      }
      
      public function isCustomizable() : Boolean
      {
         return this.hasLayerKey() && (this.isItemCustomizable || this.isColorable);
      }
      
      public function hasLayerKey() : Boolean
      {
         return this.m_layerKey != null && this.m_layerKey != "";
      }
      
      public function get items() : Array
      {
         var len:uint = this.m_itemNames.length;
         var items:Array = new Array(len);
         for(var idx:uint = 0; idx < len; idx++)
         {
            items[idx] = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemNames[idx]);
         }
         return items;
      }
      
      public function isItemValid(itemName:String) : Boolean
      {
         return this.m_itemNames.length > 0 && itemName != null && this.m_itemNames.indexOf(itemName) >= 0 || this.m_itemNames.length == 0 && itemName == null;
      }
      
      public function validateState(state:UGCItemLayerState) : Boolean
      {
         var itemName:String = null;
         var result:Boolean = true;
         if(state != null && this.isCustomizable())
         {
            itemName = null;
            if(state.itemCode != null)
            {
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(state.itemCode);
            }
            if(!this.isItemValid(itemName))
            {
               result = false;
            }
            if(state.isCustomColor && !this.isColorable)
            {
               result = false;
            }
         }
         else
         {
            result = false;
            if(state != null)
            {
               GlobalEngine.error("UGC","UGCItemLayerState failed validation, ");
            }
         }
         return result;
      }
   }
}

