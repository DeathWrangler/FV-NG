package Classes.UGC
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.UGCDecoManager;
   
   public class UGCItemDefinition
   {
      
      private static const XML_ATTR_ITEMNAME:String = "@itemName";
      
      private static const XML_ATTR_FEATURENAME:String = "@featureName";
      
      private static const XML_ATTR_SHOWRECYCLEBUTTON:String = "@showRecycleButton";
      
      private static const XML_TAG_BASE:String = "base";
      
      private static const XML_TAG_EDITOR:String = "editor";
      
      private static const XML_TAG_HUD:String = "hud";
      
      private var m_itemName:String;
      
      private var m_baseLayer:UGCItemLayerDefinition;
      
      private var m_layers:Array;
      
      private var m_layerHash:Object;
      
      private var m_editorConfig:UGCItemEditorConfig;
      
      private var m_featureName:String = null;
      
      private var m_showRecycleButton:Boolean = true;
      
      private var m_hudConfig:UGCItemHudConfig;
      
      private var m_colorable:Boolean;
      
      public function UGCItemDefinition(xml:XML)
      {
         var featureName:String = null;
         var showRecycleButton:Boolean = false;
         var layerIdx:int = 0;
         var layersList:XMLList = null;
         var tablist:XMLList = null;
         var layer:UGCItemLayerDefinition = null;
         var layerXML:XML = null;
         super();
         if(xml.hasOwnProperty(XML_ATTR_ITEMNAME))
         {
            this.m_itemName = xml[XML_ATTR_ITEMNAME].toString();
            this.m_baseLayer = new UGCItemLayerDefinition(xml[XML_TAG_BASE][0] as XML);
            this.m_colorable = this.m_baseLayer.isColorable;
            this.m_editorConfig = new UGCItemEditorConfig(xml[XML_TAG_EDITOR][0] as XML);
            if(xml.hasOwnProperty(XML_TAG_HUD))
            {
               this.m_hudConfig = new UGCItemHudConfig(xml[XML_TAG_HUD][0] as XML);
            }
            featureName = UGCDecoManager.DEFAULT_FEATURE_NAME;
            if(xml[XML_TAG_EDITOR].hasOwnProperty(XML_ATTR_FEATURENAME))
            {
               featureName = xml[XML_TAG_EDITOR][XML_ATTR_FEATURENAME].toString();
            }
            this.m_featureName = featureName;
            showRecycleButton = true;
            if(xml[XML_TAG_EDITOR].hasOwnProperty(XML_ATTR_SHOWRECYCLEBUTTON))
            {
               showRecycleButton = Boolean(xml[XML_TAG_EDITOR][XML_ATTR_SHOWRECYCLEBUTTON].toString() == "true");
            }
            this.m_showRecycleButton = showRecycleButton;
            layerIdx = 0;
            layersList = xml.layers.layer as XMLList;
            tablist = xml[XML_TAG_EDITOR].tabs.tab.(@name == "blueprints");
            if(tablist.length() > 0)
            {
               layersList += UGCDecoManager.instance.getBlueprints(this.m_featureName);
            }
            this.m_layers = new Array(layersList.length() + 1);
            this.m_layerHash = new Object();
            this.m_layers[layerIdx++] = this.m_baseLayer;
            if(this.m_layerHash.hasOwnProperty(this.m_baseLayer.layerKey))
            {
               if(Config.DEBUG_MODE)
               {
                  UI.displayMessage("@Design: XML ERROR in gamesettings.xml UGC building config. More than one <base layerKey=\"" + this.m_baseLayer.layerKey + "\">");
               }
            }
            else
            {
               this.m_layerHash[this.m_baseLayer.layerKey] = this.m_baseLayer;
            }
            for each(layerXML in layersList)
            {
               layer = new UGCItemLayerDefinition(layerXML);
               var _loc6_:Number;
               this.m_layers[_loc6_ = layerIdx++] = layer;
               if(layer.hasLayerKey())
               {
                  if(this.m_layerHash.hasOwnProperty(layer.layerKey))
                  {
                     if(Config.DEBUG_MODE)
                     {
                        UI.displayMessage("@Design: XML ERROR in gamesettings.xml UGC building config. More than one <layer layerKey=\"" + layer.layerKey + "\">");
                     }
                  }
                  else
                  {
                     this.m_layerHash[layer.layerKey] = layer;
                  }
               }
               this.m_colorable = this.m_colorable || layer.isColorable;
            }
            return;
         }
         throw new Error("Invalid UGCItemDefinition, no itemName found.");
      }
      
      public static function getDefinitionForState(state:UGCItemState) : UGCItemDefinition
      {
         var itemName:String = null;
         var result:UGCItemDefinition = null;
         if(state != null && state.itemCode != null)
         {
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(state.itemCode);
            if(itemName)
            {
               result = Global.farmGameSettingsManager.getUGCItemDefinition(itemName);
            }
            else
            {
               GlobalEngine.error("UGC","Failed to find UGCItemDefinition for state with item code = " + state.itemCode);
            }
         }
         return result;
      }
      
      public function get showRecycleButton() : Boolean
      {
         return this.m_showRecycleButton;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get colorable() : Boolean
      {
         return this.m_colorable;
      }
      
      public function get base() : UGCItemLayerDefinition
      {
         return this.m_baseLayer;
      }
      
      public function get layers() : Array
      {
         return this.m_layers;
      }
      
      public function getLayerByKey(layerKey:String) : UGCItemLayerDefinition
      {
         return this.m_layerHash[layerKey] as UGCItemLayerDefinition;
      }
      
      public function get editorConfig() : UGCItemEditorConfig
      {
         return this.m_editorConfig;
      }
      
      public function validateUGCItemState(state:UGCItemState) : Boolean
      {
         var stateLayers:Object = null;
         var farmItem:FarmItem = null;
         var layerDef:UGCItemLayerDefinition = null;
         var layerState:UGCItemLayerState = null;
         var layerKey:String = null;
         var result:Boolean = true;
         if(state != null)
         {
            if(state.itemCode == null)
            {
               result = false;
            }
            else
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(state.itemCode);
               if(farmItem == null || farmItem.name != this.itemName)
               {
                  result = false;
               }
            }
            if(state.name != null && state.name.length > UGCConstants.NAME_MAX_LENGTH)
            {
               result = false;
            }
            stateLayers = state.layers;
            if(stateLayers != null)
            {
               for(layerKey in stateLayers)
               {
                  layerState = stateLayers[layerKey];
                  layerDef = this.getLayerByKey(layerKey);
                  if(layerDef == null)
                  {
                     result = false;
                  }
                  else if(!layerDef.validateState(layerState))
                  {
                     result = false;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function get hudConfig() : UGCItemHudConfig
      {
         return this.m_hudConfig;
      }
   }
}

