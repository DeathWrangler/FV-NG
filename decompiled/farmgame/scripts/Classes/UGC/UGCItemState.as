package Classes.UGC
{
   import Classes.ZItem.FarmItem;
   
   public class UGCItemState
   {
      
      private static const VALIDITY_UNKNOWN:int = 0;
      
      private static const VALIDITY_VALID:int = 1;
      
      private static const VALIDITY_INVALID:int = 2;
      
      private var m_uuid:String;
      
      private var m_itemCode:String;
      
      private var m_name:String;
      
      private var m_layers:Object;
      
      private var m_lastValidityResult:int;
      
      public function UGCItemState()
      {
         super();
         this.m_layers = new Object();
         this.m_lastValidityResult = VALIDITY_UNKNOWN;
      }
      
      public static function createFromServerState(data:Object) : UGCItemState
      {
         var state:UGCItemState = new UGCItemState();
         state.loadData(data);
         return state;
      }
      
      public static function createFromDefinition(def:UGCItemDefinition) : UGCItemState
      {
         var state:UGCItemState = new UGCItemState();
         state.m_itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(def.itemName);
         return state;
      }
      
      public function clone() : UGCItemState
      {
         return createFromServerState(this.packData());
      }
      
      public function reset() : void
      {
         this.m_name = null;
         this.m_layers = new Object();
         this.m_lastValidityResult = VALIDITY_UNKNOWN;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set name(value:String) : void
      {
         this.m_name = value;
         this.m_lastValidityResult = VALIDITY_UNKNOWN;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function hasItemCode() : Boolean
      {
         return this.m_itemCode != null && this.m_itemCode.length > 0;
      }
      
      public function get uuid() : String
      {
         return this.m_uuid;
      }
      
      public function hasUUID() : Boolean
      {
         return this.m_uuid != null && this.m_uuid.length > 0;
      }
      
      public function get layers() : Object
      {
         return this.m_layers;
      }
      
      public function insertInitialUuid(value:String) : void
      {
         if(this.m_uuid == null)
         {
            this.m_uuid = value;
         }
      }
      
      public function getLayerStateByDefinition(layerDef:UGCItemLayerDefinition, clone:Boolean = true) : UGCItemLayerState
      {
         var result:UGCItemLayerState = null;
         if(Boolean(layerDef) && layerDef.hasLayerKey())
         {
            result = this.getLayerStateByKey(layerDef.layerKey,clone);
         }
         return result;
      }
      
      public function getLayerStateByKey(layerKey:String, clone:Boolean = true) : UGCItemLayerState
      {
         var result:UGCItemLayerState = null;
         if(Boolean(layerKey) && this.m_layers.hasOwnProperty(layerKey))
         {
            result = this.m_layers[layerKey] as UGCItemLayerState;
            if(result == null)
            {
               delete this.m_layers[layerKey];
            }
            else if(clone)
            {
               result = result.clone();
            }
            else
            {
               this.m_lastValidityResult = VALIDITY_UNKNOWN;
            }
         }
         return result;
      }
      
      public function addLayerState(layerDef:UGCItemLayerDefinition, layerState:UGCItemLayerState) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(layerState) && Boolean(layerDef) && layerDef.hasLayerKey())
         {
            this.m_layers[layerDef.layerKey] = layerState;
            this.m_lastValidityResult = VALIDITY_UNKNOWN;
         }
         return result;
      }
      
      public function removeLayerState(layerDef:UGCItemLayerDefinition, layerState:UGCItemLayerState) : Boolean
      {
         var currentState:UGCItemLayerState = null;
         var result:Boolean = false;
         if(Boolean(layerState) && Boolean(layerDef) && layerDef.hasLayerKey())
         {
            currentState = this.m_layers[layerDef.layerKey] as UGCItemLayerState;
            if(currentState == layerState)
            {
               delete this.m_layers[layerDef.layerKey];
               result = true;
               if(this.m_lastValidityResult == VALIDITY_INVALID)
               {
                  this.m_lastValidityResult = VALIDITY_UNKNOWN;
               }
            }
         }
         return result;
      }
      
      public function loadData(data:Object) : void
      {
         var layerData:Object = null;
         var layerKey:String = null;
         if(data)
         {
            if(data[UGCConstants.DATA_KEY_UUID])
            {
               this.m_uuid = data[UGCConstants.DATA_KEY_UUID] as String;
            }
            if(data[UGCConstants.DATA_KEY_ITEMCODE])
            {
               this.m_itemCode = data[UGCConstants.DATA_KEY_ITEMCODE] as String;
            }
            if(data[UGCConstants.DATA_KEY_NAME])
            {
               this.m_name = data[UGCConstants.DATA_KEY_NAME] as String;
            }
            this.m_layers = new Object();
            if(data[UGCConstants.DATA_KEY_LAYERS])
            {
               layerData = data[UGCConstants.DATA_KEY_LAYERS] as Object;
               if(layerData != null)
               {
                  for(layerKey in layerData)
                  {
                     this.m_layers[layerKey] = UGCItemLayerState.createFromServerState(layerData[layerKey]);
                  }
               }
            }
         }
         if(!this.isValid())
         {
            GlobalEngine.error("UGC","UGCItemState#loadData failed validation.");
            throw new Error("Attempt to load invalid UGCItemState from server, validation failed");
         }
      }
      
      public function packData() : Object
      {
         var layerData:Object = null;
         var layerCount:int = 0;
         var layerKey:String = null;
         var result:Object = null;
         if(this.isValid())
         {
            result = new Object();
            result[UGCConstants.DATA_KEY_UUID] = this.m_uuid;
            result[UGCConstants.DATA_KEY_ITEMCODE] = this.m_itemCode;
            if(this.m_name != null && this.m_name != "")
            {
               result[UGCConstants.DATA_KEY_NAME] = this.m_name;
            }
            layerData = new Object();
            layerCount = 0;
            for(layerKey in this.m_layers)
            {
               layerData[layerKey] = (this.m_layers[layerKey] as UGCItemLayerState).packData();
               layerCount++;
            }
            if(layerCount > 0)
            {
               result[UGCConstants.DATA_KEY_LAYERS] = layerData;
            }
         }
         else
         {
            GlobalEngine.error("UGC","UGCItemState#packData failed validation check.");
         }
         return result;
      }
      
      public function isValid() : Boolean
      {
         var farmItem:FarmItem = null;
         var ugcItemDef:UGCItemDefinition = null;
         if(this.m_lastValidityResult == VALIDITY_UNKNOWN)
         {
            this.m_lastValidityResult = VALIDITY_INVALID;
            if(this.m_itemCode != null && this.m_itemCode != "")
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
               if(farmItem)
               {
                  ugcItemDef = Global.farmGameSettingsManager.getUGCItemDefinition(farmItem.name);
                  if(ugcItemDef)
                  {
                     if(ugcItemDef.validateUGCItemState(this))
                     {
                        this.m_lastValidityResult = VALIDITY_VALID;
                     }
                  }
               }
            }
         }
         return this.m_lastValidityResult == VALIDITY_VALID;
      }
      
      public function isCustom() : Boolean
      {
         var layerState:UGCItemLayerState = null;
         var result:Boolean = false;
         for each(layerState in this.m_layers)
         {
            if(layerState.isCustom)
            {
               result = true;
               break;
            }
         }
         return result;
      }
   }
}

