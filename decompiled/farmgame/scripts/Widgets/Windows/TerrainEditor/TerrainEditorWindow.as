package Widgets.Windows.TerrainEditor
{
   import Classes.Constants.WorldsConstants;
   import Classes.UserDrivenTerrain.UDTConfig;
   import Display.UI;
   import Managers.UDTManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.TerrainEditor.TerrainEditorSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class TerrainEditorWindow extends FarmWindow
   {
      
      private var m_slotFrame:TerrainEditorSlotFrame = null;
      
      public function TerrainEditorWindow()
      {
         super("assets/dialogs/FV_terrainEditor.swf",false);
      }
      
      override protected function postLoadComplete() : void
      {
         if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            addWidget(new ZwWidget(m_window.background_mc));
         }
         else
         {
            addWidget(new ZwWidget(m_window.englandBackground_mc));
         }
         this.m_slotFrame = addWidget(new TerrainEditorSlotFrame(m_window.slotFrame_mc,UDTConfig.getTerrains(),this)) as TerrainEditorSlotFrame;
         visible = true;
         UI.alignTerrainEditor(m_window.height);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_slotFrame = null;
      }
      
      override protected function onClose(event:Event) : void
      {
         this.closeWindow(event);
      }
      
      public function closeWindow(event:Event) : void
      {
         super.onClose(event);
         UDTManager.exitTerrainEditor();
      }
   }
}

