package Display
{
   import Classes.Yimf.YimfManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class TileCustomizationDialog extends FarmDynamicDialog
   {
      
      private static var m_bgColor:String = "";
      
      private static var m_skyColor:String = "";
      
      private static var m_outlineColor:String = "";
      
      private static var m_outlineAlpha:Number = 0;
      
      private static var m_tileDialog:TileCustomizationDialog = null;
      
      private static const TOOL_TILESET_NAME:String = "art_tool_generated_tileset";
      
      private var m_backgroundUrl:String = "";
      
      private var m_horizonUrl:String = "";
      
      public function TileCustomizationDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      public static function init(backgroundUrl:String, horizonUrl:String) : void
      {
         if(m_tileDialog == null)
         {
            m_tileDialog = FarmDynamicDialog.createDialog("TileCustomizationDialog",TileCustomizationDialog) as TileCustomizationDialog;
            if(m_tileDialog != null)
            {
               m_tileDialog.setupDialog(backgroundUrl,horizonUrl);
               m_tileDialog.show();
            }
         }
      }
      
      private function setupDialog(backgroundUrl:String, horizonUrl:String) : void
      {
         this.m_backgroundUrl = backgroundUrl;
         this.m_horizonUrl = horizonUrl;
         var baseTileSet:String = Global.world.getFarmTileMap().tileSet;
         if(m_bgColor.length > 0)
         {
            getChildController("tfBgColor").setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_bgColor);
         }
         if(m_skyColor.length > 0)
         {
            getChildController("tfSkyColor").setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_skyColor);
         }
         if(m_outlineColor.length > 0)
         {
            getChildController("tfOutlineColor").setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_outlineColor);
         }
         getChildController("tfOutlineAlpha").setAttribute(TextFieldView.ATTRIBUTE_TEXT,m_outlineAlpha);
         setShortcutListener("updateButton",WidgetControllerEvent.BUTTON_PRESSED,this.onUpdatePressed);
         setShortcutListener("cancelButton",WidgetControllerEvent.BUTTON_PRESSED,this.onCancelPressed);
      }
      
      private function onUpdatePressed(event:WidgetControllerEvent) : void
      {
         var tileSetXml:XML;
         m_bgColor = getChildController("tfBgColor").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         m_skyColor = getChildController("tfSkyColor").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         m_outlineColor = getChildController("tfOutlineColor").getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         m_outlineAlpha = parseFloat(getChildController("tfOutlineAlpha").getAttribute(TextFieldView.ATTRIBUTE_TEXT));
         var bgColor:Number = parseInt(m_bgColor);
         var skyColor:Number = parseInt(m_skyColor);
         if(isNaN(parseInt(m_bgColor)))
         {
            UI.showMessage.("Invalid background color entered");
            return;
         }
         if(isNaN(parseInt(m_skyColor)))
         {
            UI.showMessage.("Invalid sky color entered");
            return;
         }
         if(isNaN(parseInt(m_outlineColor)))
         {
            UI.showMessage.("Invalid outline color entered");
            return;
         }
         tileSetXml = this.createNewTilesetXML(TOOL_TILESET_NAME,m_bgColor,m_skyColor,m_outlineColor,m_outlineAlpha,this.m_backgroundUrl,this.m_horizonUrl);
         YimfManager.getInstance().addConfigXml(tileSetXml);
         Global.world.getFarmTileMap().setBackgroundTileAndColor(TOOL_TILESET_NAME);
         destroy();
         m_tileDialog = null;
      }
      
      private function createNewTilesetXML(type:String, bgColor:String, skyColor:String, outlineColor:String, outlineAlpha:Number, bgUrl:String, horizonUrl:String) : XML
      {
         var xmlStr:String = ( <![CDATA[
								<yimf>
									<toolGenerated>1</toolGenerated>
									<renderBackgroundAtBottom>true</renderBackgroundAtBottom>
									<drawOutline>true</drawOutline>
								</yimf>
							]]>).toString();
         var xml:XML = new XML(xmlStr);
         xml["type"] = type;
         var bgColorNode:String = "<bgColor>" + bgColor + "</bgColor>";
         xml.appendChild(new XML(bgColorNode));
         var skyColorNode:String = "<skyColor>" + skyColor + "</skyColor>";
         xml.appendChild(new XML(skyColorNode));
         var outlineColorNode:String = "<outlineColor>" + outlineColor + "</outlineColor>";
         xml.appendChild(new XML(outlineColorNode));
         var outlineAlphaNode:String = "<outlineAlpha>" + outlineAlpha + "</outlineAlpha>";
         xml.appendChild(new XML(outlineAlphaNode));
         var horizonNode:String = "<horizon>" + horizonUrl + "</horizon>";
         xml.appendChild(new XML(horizonNode));
         var bgNode:String = "<backgroundPath>" + bgUrl + "</backgroundPath>";
         xml.appendChild(new XML(bgNode));
         return xml;
      }
      
      private function onCancelPressed(event:WidgetControllerEvent) : void
      {
         destroy();
         m_tileDialog = null;
      }
   }
}

