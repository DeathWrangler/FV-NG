package Display
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Init.FarmGameSettingsInit;
   import Managers.ArtUploadManager;
   import Managers.FarmStatsManager;
   import Managers.ToolModeManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class DebugScaleDialog extends FarmDynamicDialog
   {
      
      private static const STAT_KINGDOM:String = "debug_scale_dialog";
      
      private var m_scaleValue:Number = 1;
      
      private var m_currentDebugScale:Number = 1;
      
      private var m_resource:MapResource;
      
      private var m_sizeX:int = 1;
      
      private var m_sizeY:int = 1;
      
      public function DebugScaleDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function init(resource:MapResource, currentScale:Number, currentSizeX:int = 0, currentSizeY:int = 0) : void
      {
         var m_scaleDialog:DebugScaleDialog = FarmDynamicDialog.createDialog("DebugScaleDialog",DebugScaleDialog) as DebugScaleDialog;
         if(m_scaleDialog != null)
         {
            m_scaleDialog.m_resource = resource;
            m_scaleDialog.currentScale = currentScale;
            m_scaleDialog.m_sizeX = currentSizeX;
            m_scaleDialog.m_sizeY = currentSizeY;
            m_scaleDialog.setupDialog();
            m_scaleDialog.show();
            FarmStatsManager.count(StatsTrackingConstants.COUNTER_NAME_TOOLS,StatsTrackingConstants.KINGDOM_NAME_SAND_BOX,STAT_KINGDOM,"view");
         }
      }
      
      private function setupDialog() : void
      {
         setShortcutAttribute("dynamicTextFieldScale",TextFieldView.ATTRIBUTE_TEXT,this.m_currentDebugScale.toString());
         getChildController("dynamicTextFieldSizeX").setAttribute(TextFieldView.ATTRIBUTE_TEXT,this.m_sizeX.toString());
         getChildController("dynamicTextFieldSizeY").setAttribute(TextFieldView.ATTRIBUTE_TEXT,this.m_sizeY.toString());
         setShortcutListener("updateButton",WidgetControllerEvent.BUTTON_PRESSED,this.onUpdatePressed);
         setShortcutListener("cancelButton",WidgetControllerEvent.BUTTON_PRESSED,this.onCancelPressed);
      }
      
      private function onUpdatePressed(event:WidgetControllerEvent) : void
      {
         var item:FarmItem;
         var assetFile:String;
         var assetUrl:String = null;
         var newXml:XML = null;
         var newItem:FarmItem = null;
         this.m_scaleValue = parseFloat(getChildController("dynamicTextFieldScale").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         this.m_sizeX = parseInt(getChildController("dynamicTextFieldSizeX").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         this.m_sizeY = parseInt(getChildController("dynamicTextFieldSizeY").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         if(!this.m_scaleValue || this.m_scaleValue <= 0)
         {
            UI.showMessage.("Invalid scale entered");
            return;
         }
         if(!this.m_sizeX || this.m_sizeX < 1)
         {
            UI.showMessage.("Invalid sizeX entered");
            return;
         }
         if(!this.m_sizeY || this.m_sizeY < 1)
         {
            UI.showMessage.("Invalid sizeY entered");
            return;
         }
         item = this.m_resource.getItem();
         assetFile = item.toolGeneratedFile;
         if(item.sizeX != this.m_sizeX || item.sizeY != this.m_sizeY || item.size != this.m_scaleValue)
         {
            assetUrl = ToolModeManager.getSaltAssetUrl(assetFile);
            newXml = AssetPreviewDialog.createNewItemXml(item.name,item.getActiveXml(),item.overrideExportName,this.m_scaleValue,this.m_sizeX,this.m_sizeY,assetUrl);
            ExternalUtil.instance.call(ArtUploadManager.JS_UPDATE_ITEM_XML,newXml.toXMLString(),item.name);
            if(newXml)
            {
               this.m_resource.detach();
               newItem = FarmGameSettingsInit.createItemConfigInstance(newXml);
               newItem.toolGeneratedFile = assetFile;
               Global.farmGameSettingsManager.addFarmItem(newItem,newXml,newItem.name,true);
               item.onUse(0,{
                  "isGift":true,
                  "repopGift":false
               });
            }
            else
            {
               UI.showMessage("There was an error resizing the asset");
            }
         }
         destroy();
      }
      
      private function onCancelPressed(event:WidgetControllerEvent) : void
      {
         destroy();
      }
      
      private function set currentScale(scale:Number) : void
      {
         this.m_currentDebugScale = scale;
      }
   }
}

