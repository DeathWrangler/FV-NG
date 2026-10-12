package Managers
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Display.AssetPreviewDialog;
   import Display.DebugScaleDialog;
   import Display.IconPreviewTool;
   import Display.TileCustomizationDialog;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.ErrorManager;
   import Init.FarmGameSettingsInit;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class ToolModeManager
   {
      
      private static var m_reservedItemCount:Number = 0;
      
      protected static var m_instance:ToolModeManager = null;
      
      private static var m_backgroundUrl:String = "";
      
      private static var m_horizonUrl:String = "";
      
      private static const OVER_NINE_THOUSAND:Number = 9000;
      
      private var m_jsonLoader:URLLoader;
      
      protected var readyForJS:Boolean = false;
      
      private var m_assetUrl:String = "";
      
      private var m_isIconFlow:Boolean = false;
      
      private var m_assetName:String = "";
      
      private var m_xmlStr:String = null;
      
      private var m_itemName:String = null;
      
      public function ToolModeManager()
      {
         super();
         this.readyForJS = true;
      }
      
      public static function getInstance() : ToolModeManager
      {
         if(m_instance == null)
         {
            m_instance = new ToolModeManager();
         }
         return m_instance;
      }
      
      public static function initMode() : void
      {
         initJS();
      }
      
      public static function initJS() : void
      {
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("loadSandboxAsset",loadSandboxAsset);
               ExternalInterface.addCallback("loadTilesetBackground",loadTilesetBackground);
               ExternalInterface.addCallback("loadTilesetHorizon",loadTilesetHorizon);
               ExternalInterface.addCallback("addArtToolItem",ToolModeManager.addArtToolItem);
               ExternalInterface.addCallback("addArtToolItemFromXml",ToolModeManager.addArtToolItemFromXml);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      public static function loadSandboxAsset(candidateSwfUrl:String, name:String = null, xmlStr:String = null, itemName:String = null) : Boolean
      {
         getInstance().loadAssetInfo(candidateSwfUrl,name,xmlStr,false,itemName);
         return true;
      }
      
      public static function loadSandboxIcon(candidatePngUrl:String, name:String = null, xmlStr:String = null) : Boolean
      {
         getInstance().loadAssetInfo(candidatePngUrl,name,xmlStr,true);
         return true;
      }
      
      public static function getSandboxIconUrlFromShortUrl(shortUrl:String) : String
      {
         var result:String = shortUrl;
         result = result.slice(result.lastIndexOf("/") + 1,result.lastIndexOf("."));
         result = "/ugcImages/" + result + "." + Global.player.uid + ".png";
         return ToolModeManager.getSaltAssetUrl(result);
      }
      
      public static function loadTilesetBackground(candidateSwfUrl:String) : Boolean
      {
         m_backgroundUrl = Global.DONTHASH_ASSET_PREFIX + getSaltAssetUrl(candidateSwfUrl);
         Global.world.setBackground(m_backgroundUrl);
         if(m_backgroundUrl.length > 0 && m_horizonUrl.length > 0)
         {
            TileCustomizationDialog.init(m_backgroundUrl,m_horizonUrl);
         }
         return true;
      }
      
      public static function loadTilesetHorizon(candidateSwfUrl:String) : Boolean
      {
         m_horizonUrl = Global.DONTHASH_ASSET_PREFIX + getSaltAssetUrl(candidateSwfUrl);
         Global.world.setHorizon(m_horizonUrl);
         if(m_backgroundUrl.length > 0 && m_horizonUrl.length > 0)
         {
            TileCustomizationDialog.init(m_backgroundUrl,m_horizonUrl);
         }
         return true;
      }
      
      public static function showScaleDialog(resource:MapResource, initialScale:Number, sizeX:int, sizeY:int) : void
      {
         DebugScaleDialog.init(resource,initialScale,sizeX,sizeY);
      }
      
      public static function showDebugInfo(item:FarmItem, debugScale:Number, sizeX:int, sizeY:int) : void
      {
         var message:String = "";
         message = "Summary info for item:\n";
         message += "  name:" + item.name + "\n";
         message += "  scale:" + debugScale + "\n";
         message += "  sizeX:" + sizeX + "\n";
         message += "  sizeY:" + sizeY + "\n";
         message += "  imageHorizontalOffset:" + item.getDisplayHorizontalOffset() + "\n";
         message += "  imageVerticalOffset:" + item.getDisplayVerticalOffset() + "\n";
         if(Boolean(item.overrideExportName) && item.overrideExportName.length > 0)
         {
            message += "  overrideExportName:" + item.overrideExportName + "\n";
         }
         UI.showMessage(message);
         FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,"debug_info_dialog","view");
      }
      
      public static function getTempItemCode() : String
      {
         var tempCount:Number = m_reservedItemCount + OVER_NINE_THOUSAND;
         var result:String = "temp" + tempCount.toString();
         ++m_reservedItemCount;
         return result;
      }
      
      public static function assignDummyObjectId() : Number
      {
         var id:Number = m_reservedItemCount + OVER_NINE_THOUSAND;
         ++m_reservedItemCount;
         return id;
      }
      
      public static function getSaltAssetUrl(assetFile:String) : String
      {
         return Config.BASE_PATH + "sandboxProxy.php?ts=" + Global.worldTime + "&swf=" + assetFile + "&uid=" + Global.player.uid;
      }
      
      public static function addArtToolItem(itemName:String) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var xml:XML = item.xml.copy();
         xml.@toolGenerated = "true";
         var newItem:FarmItem = FarmGameSettingsInit.createItemConfigInstance(xml);
         Global.farmGameSettingsManager.addFarmItem(newItem,xml,newItem.name);
         newItem.onUse(0,{
            "isGift":true,
            "repopGift":false
         });
      }
      
      public static function addArtToolItemFromXml(itemXmlStr:String, objId:Number = 0) : void
      {
         var item:FarmItem = null;
         var oldWorldObject:WorldObject = null;
         var itemXml:XML = new XML(itemXmlStr);
         if(itemXml != null)
         {
            if(objId > 0)
            {
               oldWorldObject = Global.world.getObjectById(objId);
               if(oldWorldObject)
               {
                  oldWorldObject.detach();
               }
            }
            itemXml.@toolGenerated = "true";
            item = FarmGameSettingsInit.createItemConfigInstance(itemXml);
            if(item != null)
            {
               FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,"loading_item_xml_from_js");
               Global.farmGameSettingsManager.addFarmItem(item,itemXml,item.name);
               item.onUse(0,{
                  "isGift":true,
                  "repopGift":false
               });
            }
         }
      }
      
      public static function viewItemXml(mapResouce:MapResource) : void
      {
         var id:Number = mapResouce.getId();
         ExternalUtil.instance.call("viewItemXmlInArtTool",mapResouce.getItem().xml.toXMLString(),id);
         FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,"load_item_xml_to_js");
      }
      
      private function loadAssetInfo(txtPath:String, name:String = "", xmlStr:String = null, iconFlow:Boolean = false, itemName:String = null) : void
      {
         var url:String = null;
         if(this.readyForJS)
         {
            this.readyForJS = false;
            this.m_assetUrl = txtPath;
            this.m_assetName = name;
            url = getSaltAssetUrl(txtPath + ".json");
            this.m_jsonLoader = new URLLoader(new URLRequest(url));
            this.m_jsonLoader.dataFormat = URLLoaderDataFormat.TEXT;
            this.m_isIconFlow = iconFlow;
            this.m_itemName = itemName;
            this.m_xmlStr = xmlStr;
            this.m_jsonLoader.addEventListener(Event.COMPLETE,this.onAssetInfoLoaded);
            this.m_jsonLoader.addEventListener(IOErrorEvent.IO_ERROR,function(event:Event):void
            {
               var xml:XML = null;
               var classes:Array = null;
               if(m_isIconFlow)
               {
                  UI.clearPopupQueue();
                  UI.displayPopup(new IconPreviewTool(m_assetUrl) as DisplayObject);
               }
               else
               {
                  xml = null;
                  if(m_xmlStr)
                  {
                     xml = new XML(m_xmlStr);
                  }
                  classes = [];
                  AssetPreviewDialog.init(classes,m_assetUrl,m_assetName,onPreviewCloseCb,xml,itemName);
               }
            });
         }
      }
      
      private function onAssetInfoLoaded(e:Event) : void
      {
         var urlLoader:URLLoader = URLLoader(e.currentTarget);
         urlLoader.removeEventListener(Event.COMPLETE,this.onAssetInfoLoaded);
         var rawData:String = URLLoader(e.currentTarget).data as String;
         var data:Object = {"exports":[]};
         if(rawData)
         {
            data = com.adobe.serialization.json.JSON.decode(rawData);
         }
         var classes:Array = data.hasOwnProperty("exports") ? data.exports : [];
         this.m_jsonLoader = null;
         var xml:XML = null;
         if(this.m_xmlStr)
         {
            xml = new XML(this.m_xmlStr);
         }
         if(this.m_isIconFlow)
         {
            UI.clearPopupQueue();
            UI.displayPopup(new IconPreviewTool(this.m_assetUrl) as DisplayObject,false);
            this.readyForJS = true;
            this.m_assetUrl = "";
         }
         else
         {
            AssetPreviewDialog.init(classes,this.m_assetUrl,this.m_assetName,this.onPreviewCloseCb,xml,this.m_itemName);
         }
      }
      
      private function onPreviewCloseCb() : void
      {
         this.readyForJS = true;
         this.m_assetUrl = "";
      }
   }
}

