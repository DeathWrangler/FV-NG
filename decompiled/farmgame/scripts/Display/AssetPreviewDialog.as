package Display
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Display.Dialogs.GenericDialog;
   import Init.FarmGameSettingsInit;
   import Managers.ArtUploadManager;
   import Managers.FarmStatsManager;
   import Managers.ToolModeManager;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   
   public class AssetPreviewDialog extends FarmDynamicDialog
   {
      
      private static const STAT_KINGDOM:String = "asset_preview_dialog";
      
      private static const TYPE_ANIMAL:String = "animal";
      
      private static const TYPE_BUILDING:String = "building";
      
      private static const TYPE_BUILDING_ANIMATED:String = "animated_building";
      
      private static const TYPE_DECO:String = "decoration";
      
      private static const TYPE_ROTATEABLE_DECO:String = "rotatable_decoration";
      
      private static const TYPE_TREE:String = "tree";
      
      private static const DEFAULT_ANIMAL:String = "cow";
      
      private static const DEFAULT_BUILDING:String = "adobefarmhouse";
      
      private static const DEFAULT_BUILDING_ANIMATED:String = "valentinebrokenheartcottage";
      
      private static const DEFAULT_DECO:String = "colonialcarriage";
      
      private static const DEFAULT_ROTATEABLE_DECO:String = "woolspinningwheel";
      
      private static const DEFAULT_TREE:String = "corneliancherry";
      
      private static const MARKERS_ANIMAL:Array = ["_frt_idle","_bk_idle"];
      
      private static const MARKERS_BUILDING:Array = ["_built","_built_rotatable"];
      
      private static const MARKERS_ROTATABLE_DECO:Array = ["_horizontal","_vertical"];
      
      private static const MARKERS_TREE:Array = ["_bare","_mature"];
      
      private static const TOOL_EXPORT_EXEMPT_STATIC:String = "static";
      
      private static const TOOL_EXPORT_EXEMPT_BUILT:String = "built";
      
      private var m_assetUrl:String = null;
      
      private var m_assetName:String = "";
      
      private var m_assetFile:String = "";
      
      private var m_exportNames:Array = [];
      
      private var m_requireExportNames:Array = [];
      
      private var m_baseXml:XML = null;
      
      private var m_onCloseCallback:Function = null;
      
      public function AssetPreviewDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function init(exportNames:Array, assetUrl:String, assetName:String, onCloseCb:Function, xml:XML = null, itemName:String = null) : void
      {
         var scaleDialog:AssetPreviewDialog = FarmDynamicDialog.createDialog("ToolPreviewDialog",AssetPreviewDialog) as AssetPreviewDialog;
         if(scaleDialog != null)
         {
            scaleDialog.setupDialog(exportNames,assetUrl,assetName,onCloseCb,xml,itemName);
            scaleDialog.show();
            FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,STAT_KINGDOM,"view",assetName);
         }
      }
      
      public static function createNewItemXml(newName:String, xml:XML, exportName:String, imageScale:Number, sizeX:int, sizeY:int, assetUrl:String = "") : XML
      {
         var itemCode:String = null;
         var images:XMLList = null;
         var exportNameNode:String = null;
         var node:XML = null;
         var errorMessage:String = "";
         var result:Boolean = true;
         if(imageScale < 0)
         {
            UI.showMessage("imageScale must be a number 1 or greater");
            result = false;
         }
         if(sizeX < 1)
         {
            UI.showMessage("sizeX is the horizontal size of the item (a haybale is size 1). Must be a number 1 or greater");
            result = false;
         }
         if(sizeY < 1)
         {
            UI.showMessage("sizeY is the vertical size of the item (a haybale is size 1). Must be a number 1 or greater");
            result = false;
         }
         if(!newName || newName.length < 1)
         {
            UI.showMessage("You must enter a name for this new item. A name must be only letters or underscores.Any item name that is not already being used will work.");
            result = false;
         }
         if(result)
         {
            if(xml)
            {
               itemCode = ToolModeManager.getTempItemCode();
               if(Boolean(itemCode) && itemCode.length > 0)
               {
                  xml = xml.copy();
                  xml.@name = newName;
                  xml.@code = itemCode;
                  xml.@toolGenerated = "true";
                  if(xml.hasOwnProperty("overrideExportName"))
                  {
                     delete xml.overrideExportName;
                  }
                  if(Boolean(exportName) && exportName.length > 1)
                  {
                     exportNameNode = "<overrideExportName>" + exportName + "</overrideExportName>";
                     xml.appendChild(new XML(exportNameNode));
                  }
                  if(xml.hasOwnProperty("imageScale"))
                  {
                     delete xml.imageScale;
                  }
                  if(xml.hasOwnProperty("sizeX"))
                  {
                     delete xml.sizeX;
                  }
                  if(xml.hasOwnProperty("sizeY"))
                  {
                     delete xml.sizeY;
                  }
                  xml.appendChild(new XML("<imageScale>" + imageScale.toString() + "</imageScale>"));
                  xml.appendChild(new XML("<sizeX>" + sizeX.toString() + "</sizeX>"));
                  xml.appendChild(new XML("<sizeY>" + sizeY.toString() + "</sizeY>"));
                  images = xml.image;
                  if(assetUrl.length > 1)
                  {
                     if(assetUrl.indexOf(Global.DONTHASH_ASSET_PREFIX) < 0)
                     {
                        assetUrl = Global.DONTHASH_ASSET_PREFIX + assetUrl;
                     }
                     for each(node in images)
                     {
                        if(node.@name != "icon")
                        {
                           node.@url = assetUrl;
                        }
                     }
                  }
               }
               else
               {
                  result = false;
                  UI.showMessage("Failed creating item XML: Could not get a temporary item code, refresh the game to try again.");
               }
            }
            else
            {
               result = false;
               UI.showMessage("Failed creating item XML: template xml not found");
            }
         }
         if(!result)
         {
            xml = null;
         }
         return xml;
      }
      
      protected function getDefaultItemNameForType(itemType:String) : String
      {
         var result:String = "";
         switch(itemType)
         {
            case TYPE_ANIMAL:
               result = DEFAULT_ANIMAL;
               break;
            case TYPE_DECO:
               result = DEFAULT_DECO;
               break;
            case TYPE_BUILDING:
               result = DEFAULT_BUILDING;
               break;
            case TYPE_ROTATEABLE_DECO:
               result = DEFAULT_ROTATEABLE_DECO;
               break;
            case TYPE_TREE:
               result = DEFAULT_TREE;
               break;
            case TYPE_BUILDING_ANIMATED:
               result = DEFAULT_BUILDING_ANIMATED;
               break;
            default:
               result = DEFAULT_DECO;
         }
         return result;
      }
      
      protected function getExportNamesReport(exportNames:Array, type:String, name:String, shouldCheckForMissing:Boolean = true) : Array
      {
         var expectedNames:Array = this.getExpectedExportNames(name,type);
         var result:Array = expectedNames.filter(function(search:String, index:int, a:Array):Boolean
         {
            var isInList:* = false;
            if(shouldCheckForMissing)
            {
               isInList = exportNames.indexOf(search) < 0;
            }
            else
            {
               isInList = exportNames.indexOf(search) >= 0;
            }
            return isInList;
         });
         return result;
      }
      
      protected function getExpectedExportNames(name:String, type:String) : Array
      {
         var imageName:String = null;
         var suffixes:Array = [];
         if(this.m_requireExportNames == null)
         {
            switch(type)
            {
               case TYPE_ANIMAL:
                  suffixes = MARKERS_ANIMAL;
                  break;
               case TYPE_DECO:
                  break;
               case TYPE_BUILDING:
                  suffixes = MARKERS_BUILDING;
                  break;
               case TYPE_ROTATEABLE_DECO:
                  suffixes = MARKERS_ROTATABLE_DECO;
                  break;
               case TYPE_TREE:
                  suffixes = MARKERS_TREE;
                  break;
               case TYPE_BUILDING_ANIMATED:
            }
            suffixes = suffixes.map(function(s:String, i:int, a:Array):String
            {
               return name + s;
            });
         }
         else
         {
            for each(imageName in this.m_requireExportNames)
            {
               suffixes.push(name + "_" + imageName);
            }
         }
         return suffixes;
      }
      
      protected function getCandidateName(exportTypes:Array, exports:Array, fileName:String = "") : String
      {
         var exportSuffix:String = null;
         var j:int = 0;
         var itemName:String = Boolean(fileName) && fileName.length > 0 ? fileName.split(".")[0] : fileName;
         for(var i:int = 0; i < exportTypes.length; i++)
         {
            exportSuffix = exportTypes[i];
            for(j = 0; j < exports.length; j++)
            {
               if(exports[j].indexOf(exportSuffix) != -1)
               {
                  itemName = exports[j].replace("_" + exportSuffix,"");
                  break;
               }
            }
         }
         return itemName;
      }
      
      protected function setupDialog(exportNames:Array, assetUrl:String, assetName:String, onCloseCb:Function, xml:XML = null, itemName:String = null) : void
      {
         var images:XMLList = null;
         var image:XML = null;
         var imageURL:String = null;
         var imageName:String = null;
         this.m_baseXml = xml;
         if(Boolean(this.m_baseXml) && this.m_baseXml.hasOwnProperty("image"))
         {
            images = this.m_baseXml.image;
            for each(image in images)
            {
               imageURL = image.@url.toString();
               if(FarmGameUtil.isStringSWFUrl(imageURL))
               {
                  imageName = image.@name.toString();
                  if(imageName != TOOL_EXPORT_EXEMPT_STATIC && imageName != TOOL_EXPORT_EXEMPT_BUILT)
                  {
                     this.m_requireExportNames.push(imageName);
                  }
               }
            }
         }
         if(assetUrl.charAt(0) == "/")
         {
            assetUrl = assetUrl.substr(1);
         }
         var assetPath:Array = assetUrl.split("/");
         this.m_assetFile = assetPath[assetPath.length - 1];
         assetUrl = ToolModeManager.getSaltAssetUrl(this.m_assetFile);
         this.m_assetUrl = assetUrl;
         this.m_assetName = assetName;
         this.m_exportNames = exportNames;
         this.m_onCloseCallback = onCloseCb;
         setShortcutListener("okButton",WidgetControllerEvent.BUTTON_PRESSED,this.onPreviewOk);
         setShortcutListener("cancelButton",WidgetControllerEvent.BUTTON_PRESSED,this.onPreviewCancel);
         var candidateType:String = "no type found";
         if(this.m_baseXml)
         {
            candidateType = this.m_baseXml.@type.toString();
         }
         var candidateName:String = "no name found";
         if(itemName != null)
         {
            candidateName = itemName;
         }
         else
         {
            candidateName = this.getCandidateName(this.m_requireExportNames,this.m_exportNames,this.m_assetName);
         }
         var imageScale:String = "1";
         var sizeX:String = "2";
         var sizeY:String = "2";
         if(Boolean(this.m_baseXml) && this.m_baseXml.hasOwnProperty("imageScale"))
         {
            imageScale = this.m_baseXml.imageScale.toString();
         }
         if(Boolean(this.m_baseXml) && Boolean(this.m_baseXml.hasOwnProperty("sizeX")) && this.m_baseXml.hasOwnProperty("sizeY"))
         {
            sizeX = this.m_baseXml.sizeX.toString();
            sizeY = this.m_baseXml.sizeY.toString();
         }
         getChildController("templateTextField").setAttribute(TextFieldView.ATTRIBUTE_TEXT,candidateType);
         getChildController("nameTextField").setAttribute(TextFieldView.ATTRIBUTE_TEXT,candidateName);
         getChildController("exportTextField").setAttribute(TextFieldView.ATTRIBUTE_TEXT,"");
         getChildController("dynamicTextFieldImageScale").setAttribute(TextFieldView.ATTRIBUTE_TEXT,imageScale);
         getChildController("dynamicTextFieldSizeX").setAttribute(TextFieldView.ATTRIBUTE_TEXT,sizeX);
         getChildController("dynamicTextFieldSizeY").setAttribute(TextFieldView.ATTRIBUTE_TEXT,sizeY);
         var foundExportNames:String = "No required export names found :(";
         var missingExportNames:String = "No missing export names found :)";
         var missingExports:Array = this.getExportNamesReport(exportNames,candidateType,candidateName);
         var foundExports:Array = this.getExportNamesReport(exportNames,candidateType,candidateName,false);
         if(foundExports.length > 0)
         {
            foundExportNames = foundExports.join(", ");
         }
         if(missingExports.length > 0)
         {
            missingExportNames = missingExports.join(", ");
            FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,STAT_KINGDOM,"missing_export",assetName,"",missingExports.length);
         }
         setShortcutAttribute("foundExports",TextFieldView.ATTRIBUTE_TEXT,foundExportNames);
         setShortcutAttribute("missingExports",TextFieldView.ATTRIBUTE_TEXT,missingExportNames);
         setShortcutAttribute("itemImage",ImageController.ATTRIBUTE_SOURCE,this.m_assetUrl);
      }
      
      private function onPreviewCancel(e:Event) : void
      {
         this.m_onCloseCallback();
         destroy();
      }
      
      private function checkExportNameExists(exportName:String) : Boolean
      {
         var i:int = 0;
         var checkExportName:String = null;
         var result:Boolean = true;
         if(Boolean(exportName) && exportName.length > 1)
         {
            if(Boolean(this.m_exportNames) && this.m_exportNames.length > 0)
            {
               result = false;
               for(i = 0; i < this.m_exportNames.length; i++)
               {
                  checkExportName = this.m_exportNames[i];
                  if(checkExportName.indexOf(exportName) == 0)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      private function onPreviewOk(e:Event) : void
      {
         var baseXml:XML = null;
         var xml:XML = null;
         var name:String = getChildController("nameTextField").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         var templateType:String = getChildController("templateTextField").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         var templateItemName:String = this.getDefaultItemNameForType(templateType);
         var exportName:String = getChildController("exportTextField").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         var imageScale:Number = parseFloat(getChildController("dynamicTextFieldImageScale").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         var newSizeX:int = parseInt(getChildController("dynamicTextFieldSizeX").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         var newSizeY:int = parseInt(getChildController("dynamicTextFieldSizeY").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         var templateItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(templateItemName);
         if(!this.checkExportNameExists(exportName))
         {
            UI.showMessage("Failed creating item XML:export name:" + exportName + " does not exist in:" + this.m_exportNames.join(","));
         }
         else
         {
            baseXml = null;
            if(this.m_baseXml)
            {
               baseXml = this.m_baseXml;
            }
            else
            {
               baseXml = templateItem.getActiveXml();
            }
            xml = createNewItemXml(name,baseXml,exportName,imageScale,newSizeX,newSizeY,this.m_assetUrl);
            ExternalUtil.instance.call(ArtUploadManager.JS_UPDATE_ITEM_XML,xml.toXMLString(),name);
            if(xml)
            {
               this.previewAssetCheck(xml,this.m_exportNames,this.m_assetUrl);
            }
         }
      }
      
      protected function previewAssetCheck(itemXML:XML, exportNames:Array, assetUrl:String) : void
      {
         var checkName:String;
         var overrideExportName:String;
         var type:String;
         var missingNames:Array;
         var message:String;
         var hasErrors:Boolean;
         var hasNamingErrors:Boolean;
         var newItem:FarmItem = null;
         var confirmDialog:GenericDialog = null;
         newItem = FarmGameSettingsInit.createItemConfigInstance(itemXML);
         newItem.toolGeneratedFile = this.m_assetFile;
         checkName = newItem.name;
         overrideExportName = newItem.overrideExportName;
         if(Boolean(overrideExportName) && overrideExportName.length > 0)
         {
            checkName = overrideExportName;
         }
         type = newItem.type;
         missingNames = this.getExportNamesReport(exportNames,type,checkName);
         message = "Item name:" + newItem.name + "\n";
         message += "  type:" + type + "\n";
         if(Boolean(overrideExportName) && overrideExportName.length > 0)
         {
            message += "  overrideExportName:" + overrideExportName + "\n";
         }
         hasErrors = false;
         hasNamingErrors = false;
         if(Global.farmGameSettingsManager.getFarmItemByName(checkName))
         {
            message += "You are overriding the asset for an item that already exists in the game:\n";
            hasErrors = true;
         }
         if(Boolean(missingNames) && missingNames.length > 0)
         {
            message += "The following export names were expected but missing:\n";
            message += missingNames.join(",");
            message += "\n";
            hasErrors = true;
            hasNamingErrors = true;
         }
         if(this.m_assetUrl.indexOf(newItem.name) < 0)
         {
            message += "\nThe name of the swf file and the name given for the asset do not appear to match.\n";
            hasErrors = true;
         }
         if(!hasNamingErrors)
         {
            ExternalUtil.instance.call(ArtUploadManager.JS_AUTH_ASSETS,assetUrl);
         }
         if(hasErrors)
         {
            message += "\nDo you want to try to place this item anyway?\n";
            confirmDialog = UI.showMessage(message,UI.BUTTON_LAYOUT_YES_NO,"WARNING",null,false,function(e:Boolean):void
            {
               confirmDialog.destroy();
               finishNewItemPlacement(newItem,itemXML);
            });
         }
         else
         {
            this.finishNewItemPlacement(newItem,itemXML);
         }
      }
      
      protected function finishNewItemPlacement(newItem:FarmItem, xml:XML) : void
      {
         Global.farmGameSettingsManager.addFarmItem(newItem,xml,newItem.name);
         newItem.onUse(0,{
            "isGift":true,
            "repopGift":false
         });
         this.m_onCloseCallback();
         destroy();
      }
   }
}

