package Widgets.Slots.TerrainEditor
{
   import Classes.Terrain.Terrain;
   import Classes.Terrain.TerrainConfigManager;
   import Classes.util.ZLocUtils;
   import Managers.UDTManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.TerrainEditor.TerrainEditorWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class TerrainEditorSlot extends ZwSlotFrame
   {
      
      private var m_terrainEditorWindow:TerrainEditorWindow = null;
      
      private var m_titleText:ZwTextField = null;
      
      private var m_useButton:FarmAnimatedTextButton = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_iconPermit:ZwWidget = null;
      
      private var m_data:Terrain;
      
      public function TerrainEditorSlot(element:DisplayObject, terrainEditorWindow:TerrainEditorWindow)
      {
         this.m_terrainEditorWindow = terrainEditorWindow;
         super(element);
         this.m_titleText = addWidget(new ZwTextField(m_element.title_tf)) as ZwTextField;
         this.m_useButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","TerrainEditor_use"),this.onUseClick)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.x -= 25;
         this.m_icon.y -= 65;
         this.m_iconPermit = addWidget(new ZwWidget(m_element.iconPermit_mc)) as ZwWidget;
      }
      
      override public function populate(data:Object) : void
      {
         this.m_data = data as Terrain;
         this.m_titleText.visible = true;
         this.m_useButton.visible = true;
         this.m_titleText.text = ZLocUtils.t("Dialogs","TerrainEditor_" + data.name);
         if(data.icon)
         {
            this.m_icon.loadIcon(data.icon);
            this.m_icon.visible = true;
         }
         this.m_iconPermit.visible = true;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_data = null;
         this.m_terrainEditorWindow = null;
         this.m_titleText = null;
         this.m_useButton = null;
      }
      
      private function onUseClick(event:MouseEvent) : void
      {
         UDTManager.enterTerrainEditor(UDTManager.PLACEMENT,TerrainConfigManager.getInstance().getConfigByName(this.m_data.name).code);
      }
   }
}

